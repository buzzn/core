# coding: utf-8
require_relative 'generator'

module Pdf
  class Invoice < Generator

    def initialize(billing)
      super
      @billing = billing
      @de_stats = Organization::EnergyClassification.where(tariff_name: 'Energy Mix Germany').first
    end

    protected

    def build_struct
      billing_config = CoreConfig.load(Types::BillingConfig)
      {
        title_text: @billing.full_invoice_number,
        sales_tax_number: contract.localpool.localpool_processing_contract.sales_tax_number,
        tax_number: contract.localpool.localpool_processing_contract.tax_number,
        issues_vat: contract.localpool.billing_detail.issues_vat,
        contractor: build_contractor,
        powertaker: build_powertaker,
        no_contact: contact(powertaker).nil?,
        org_email: powertaker.email,
        localpool: build_localpool,
        billing: build_billing,
        items: build_billing_items,
        vat: ((BigDecimal(billing_config.vat, 4) - 1.0) * 100).round,
        contract: {
          number: contract.full_contract_number,
          market_location_name: contract.register_meta.name,
        },
        current_tariff: build_current_tariff,
        billing_year: billing_year,
        consumption_last_year: consumption(billing_year.nil? ? nil : billing_year-1),
        consumption_year: consumption(billing_year) || 0,
        abschlag: build_abschlag,
        meter: build_meter,
        waste_de: build_waste_de,
        ratios_de: build_ratios_de,
        waste_local: build_waste_local,
        ratios_local: build_ratios_local,
        energy_report: build_report
      }.tap do |h|
        h[:labels1] = build_labels1(h[:consumption_last_year])
      end
    end

    private

    def contract
      @contract ||= @billing.contract
    end

    def contractor
      @contractor ||= contract.contractor
    end

    def powertaker
      @powertaker ||= contract.customer
    end

    def billing_year
      @billing.billing_cycle&.begin_date&.year
    end

    def consumption(year)
      return nil unless year
      collected = @billing.contract.billings.to_a.keep_if { |x| x.billing_cycle.begin_date.year == year }.map { |x| [x.total_consumed_energy_kwh, x.total_days] }
      return nil if collected.flatten.include?(nil)
      summed = collected.inject { |x, n| [x[0] + n[0], x[1] + n[1]] }
      return nil unless summed
      summed[0] * 365 / summed[1]
    end

    def contractor_address
      @contractor_address ||= contractor.address
    end

    def localpool
      @localpool ||= contract.localpool
    end

    def name(person_or_organization)
      case person_or_organization
      when Person
        person_or_organization.first_name + ' ' + person_or_organization.last_name
      when Organization
      when Organization::General
        person_or_organization.name
      else
        raise "can not handle #{person_or_organization.class}"
      end
    end

    def contact(person_or_organization)
      case person_or_organization
      when Person
        person_or_organization
      when Organization
      when Organization::General
        person_or_organization.contact
      else
        raise "can not handle #{person_or_organization.class}"
      end
    end

    def addressing(person_or_organization)
      case person_or_organization
      when Person
        prefix = case person_or_organization.prefix
                 when 'female'
                   'Sehr geehrte Frau'
                 when 'male'
                   'Sehr geehrter Herr'
                 else
                   'Hallo'
                 end
        if prefix == 'Hallo'
          "#{prefix} #{person_or_organization.first_name} #{person_organization.last_name}"
        else
          "#{prefix} #{person_or_organization.title} #{person_or_organization.last_name}"
        end
      when Organization
      when Organization::General
        if person_or_organization.contact
          addressing(person_or_organization.contact)
        else
          'Sehr geehrte Damen und Herren'
        end
      else
        raise "can not handle #{person_or_organization.class}"
      end
    end

    def last_tariff
      @tariff ||= @billing.items.last.tariff
    end

    def to_kwh(value)
      (value / 1000).round
    end

    def to_date(date)
      date.strftime('%d.%m.%Y')
    end

    def german_div(cents, prec: 2)
      # round cents to precision after divison
      onesr = (cents/100).round(prec)
      sprintf("%s,%s", onesr.truncate, (onesr.remainder(1)*10).to_s.delete('.').ljust(prec, '0').first(prec))
    end

    def build_contractor
      data = {
        contact: name(contact(contractor)),
        shortname: contractor.name
      }

      data[:name] = case contractor
                    when Organization
                    when Organization::General
                      contractor.name
                    when Person
                      ''
                    end
      data[:email] = case contractor
                     when Person
                       contractor.email
                     when Organization
                     when Organization::General
                       !contractor&.contact&.email&.empty? ? contractor.contact.email : contractor.email
                     end
      %i(phone fax).each do |field|
        data[field] = contractor.send(field)
      end
      contractor.address.tap do |address|
        %i(street zip city).each do |field|
          data[field] = address.send(field)
        end
      end
      contract.contractor_bank_account.tap do |account|
        %i(iban bic bank_name).each do |field|
          data[field] = account.send(field) if account
        end
      end
      data
    end

    def build_powertaker
      data = {
        addressing: addressing(powertaker),
      }
      if contact(powertaker).nil?
        data[:name] = powertaker.name
      else
        contact(powertaker).tap do |contact|
          %i(title first_name last_name email).each do |field|
            data[field] = contact.send(field)
          end
        end
        data[:name] = ''
      end
      powertaker.address.tap do |address|
        %i(street zip city addition).each do |field|
          data[field] = address.send(field)
        end
      end
      contract.customer_bank_account.tap do |account|
        %i(iban bic bank_name).each do |field|
          data[field] = account.send(field) if account
        end
      end
      data
    end

    def build_billing
      {
        date: @billing.last_date,
        number: @billing.full_invoice_number,
        baseprice: german_div(BigDecimal(last_tariff.baseprice_cents_per_month, 4)),
        energyprice: german_div(BigDecimal(last_tariff.energyprice_cents_per_kwh, 4)),
        consumed_energy_kwh: @billing.items.first.consumed_energy_kwh,
      }.tap do |hash|
        netto =   @billing.total_amount_before_taxes
        brutto =  @billing.total_amount_after_taxes
        balance_at = BigDecimal(@billing.balance_before) / 10
        to_pay_cents = balance_at - brutto
        has_bank_and_direct_debit = @billing.contract.customer_bank_account && @billing.contract.customer_bank_account.direct_debit
        hash[:netto] = german_div(netto)
        hash[:brutto] = german_div(brutto)
        hash[:vat_amount] = german_div(brutto-netto)
        hash[:balance_at_invoice] = german_div(balance_at)
        hash[:to_pay] = german_div(to_pay_cents.abs)
        hash[:forderung]  = to_pay_cents.positive? ? 'Erstattung' : 'Forderung'
        hash[:rueck_nach] = to_pay_cents.positive? ? 'Rück' : 'Nach'
        hash[:satz_forderung] = if has_bank_and_direct_debit
                                  if to_pay_cents.positive?
                                    'Der Betrag wird in Kürze auf ihrem Bankkonto gutgeschrieben.'
                                  elsif to_pay_cents.negative?
                                    'Der Betrag wird in den nächsten Wochen von ihrem Bankkonto eingezogen.'
                                  else
                                    ''
                                  end
                                else
                                  if to_pay_cents.positive?
                                    'Bitte geben Sie uns Ihre Bankverbindung (IBAN, BIC) für die Erstattung Ihres Guthabens an.'
                                  elsif to_pay_cents.negative?
                                    'Bitte überweisen Sie den Betrag unter Angabe der Rechnungsnummer auf das oben angegebene Konto.'
                                  else
                                    ''
                                  end
                                end
      end
    end

    def build_localpool
      {
        name: contract.localpool.name
      }.tap do |h|
        %i(street zip city addition).each do |field|
          h[field] = contract.localpool.address.send(field) unless contract.localpool.address.nil?
        end
      end
    end

    def build_billing_items
      @billing.items.collect do |item|
        {
          begin_date: to_date(item.begin_date),
          last_date: to_date(item.last_date),
          begin_kwh: to_kwh(item.begin_reading.value),
          last_kwh: to_kwh(item.end_reading.value),
          consumed_energy_kwh: to_kwh(item.consumed_energy),
          length_in_days: item.length_in_days,
          meter_serial_number: item.meter.product_serialnumber
        }.tap do |h|
          rounded_consumed = h[:last_kwh] - h[:begin_kwh]
          h[:last_kwh] -= rounded_consumed-h[:consumed_energy_kwh]
          if localpool.billing_detail.issues_vat
            h[:base_price_cents_per_day]   = german_div(item.baseprice_cents_per_day_before_taxes*100, prec: 4)
            h[:base_price_euros]           = german_div(item.baseprice_cents_before_taxes)
            h[:energy_price_cents_per_kwh] = german_div(item.tariff.energyprice_cents_per_kwh_before_taxes*100, prec: 4)
            h[:energy_price_euros]         = german_div(item.energyprice_cents_before_taxes)
          else # brutto
            h[:base_price_cents_per_day]   = german_div(item.baseprice_cents_per_day_after_taxes*100, prec: 4)
            h[:base_price_euros]           = german_div(item.baseprice_cents_after_taxes)
            h[:energy_price_cents_per_kwh] = german_div(item.tariff.energyprice_cents_per_kwh_after_taxes*100, prec: 4)
            h[:energy_price_euros]         = german_div(item.energyprice_cents_after_taxes)
          end
        end
      end
    end

    def build_current_tariff
      {
        energyprice_cents_per_kwh_netto:  german_div(@contract.current_tariff.energyprice_cents_per_kwh_before_taxes*100),
        baseprice_euros_per_month_netto:  german_div(@contract.current_tariff.baseprice_cents_per_month_before_taxes),
        energyprice_cents_per_kwh_brutto: german_div(@contract.current_tariff.energyprice_cents_per_kwh_after_taxes*100),
        baseprice_euros_per_month_brutto: german_div(@contract.current_tariff.baseprice_cents_per_month_after_taxes),
      }
    end

    def build_abschlag
      abschlag = {
        was_changed: !@billing.adjusted_payment.nil?,
      }.merge(build_payment(@billing.adjusted_payment || @billing.contract.current_payment))
      has_bank_and_direct_debit = @billing.contract.customer_bank_account && @billing.contract.customer_bank_account.direct_debit
      payment_amounts_to = "Abschlag beträgt #{abschlag[:amount_euro]} €"
      abschlag_begin_date = to_date(abschlag[:begin_date])
      # negative means it's disabled for this powertaker
      if abschlag[:disabled]
        abschlag[:satz] = ''
      else
        abschlag[:satz] = if has_bank_and_direct_debit
                            every_month = 'jeden Monat von Ihrem Konto eingezogen'
                            if abschlag[:was_changed]
                              "Ihr neuer #{payment_amounts_to}. Er wird ab dem #{abschlag_begin_date} #{every_month}."
                            else
                              "Ihr #{payment_amounts_to}. Er wird wie gewohnt #{every_month}."
                            end
                          else
                            if abschlag[:was_changed]
                              "Ihr neuer #{payment_amounts_to}. Bitte überweisen Sie zu dem 01. eines Monats, erstmalig zum #{abschlag_begin_date} den neuen Abschlag auf das oben angegebene Konto."
                            else
                              "Ihr #{payment_amounts_to}. Bitte überweisen Sie den Abschlag wie gewohnt auf das oben angegebene Konto"
                            end
                          end
      end
      abschlag
    end

    def build_payment(payment)
      {
        energy_consumption_kwh_pa: payment.energy_consumption_kwh_pa,
        cycle: payment.cycle == 'monthly' ? 'Monat' : 'Jahr',
        amount_euro: german_div(BigDecimal(payment.price_cents, 4)),
        disabled: payment.price_cents.negative?,
        begin_date: payment.begin_date
      }
    end

    def build_meter
      {
        buzzn_ids: contract.register_meta.registers.map { |x| x.meter.legacy_buzznid }
      }
    end

    def build_waste_de
      {
        nuclear_waste_miligramm_per_kwh: @de_stats[:nuclear_waste_miligramm_per_kwh] / 1000.00,
        co2_emission_gramm_per_kwh: @de_stats[:co2_emission_gramm_per_kwh]
      }
    end

    def build_ratios_de
      [:nuclearRatio, :coalRatio, :gasRatio, :otherFossilesRatio, :otherRenewablesRatio, :renewablesEegRatio].map { |type| @de_stats[type.to_s.underscore] }.to_json
    end

    def build_waste_local
      {
        nuclear_waste_miligramm_per_kwh: localpool.fake_stats["nuclearWasteMiligrammPerKwh"],
        co2_emission_gramm_per_kwh: localpool.fake_stats["co2EmissionGrammPerKwh"]
      }
    end

    def build_ratios_local
      [:nuclearRatio, :coalRatio, :gasRatio, :otherFossilesRatio, :otherRenewablesRatio, :renewablesEegRatio].map { |type| localpool.fake_stats[type.to_s] }.to_json
    end

    def build_report
      Hash[[:selfSufficiencyReport, :utilizationReport, :gasReport, :sunReport, :electricitySupplier, :tech].collect { |k| [k.to_s.underscore, localpool.fake_stats[k.to_s]]}]
    end

    def build_labels1(consumption_last_year)
      labels = if billing_year
                 [
                   "Ihr Jahresverbrauch in #{billing_year} (1)",
                   "Ihr Jahresverbrauch in #{billing_year-1} (2)",
                   'Referenz 1-Personen-Haushalt',
                   'Referenz 2-Personen-Haushalt',
                   'Referenz 3 und mehr Personen-Haushalt'
                 ]
               else
                 []
               end
      if consumption_last_year
        labels.delete(1)
      end
      '[' + labels.map {|x| "'#{x}'"}.join(',') + ']'
    end

  end
end
