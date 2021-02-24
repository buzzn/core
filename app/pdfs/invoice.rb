require_relative 'generator'

module Pdf
  class Invoice < Generator

    include Serializers

    def initialize(billing)
      super
      @billing = billing
      @de_stats = Organization::EnergyClassification.where(tariff_name: 'Energy Mix Germany').first
    end

    protected

    def build_struct
      {
        title_text: @billing.full_invoice_number,
        sales_tax_number: processing_contract.sales_tax_number,
        tax_number: processing_contract.tax_number,
        issues_vat: contract.localpool.billing_detail.issues_vat,
        contractor: build_contractor,
        powertaker: build_powertaker,
        no_contact: contact(powertaker).nil?,
        org_email: powertaker.email,
        localpool: build_localpool,
        billing: build_billing,
        items: build_billing_items.sort {|x, y| Time.parse(x[:last_date]) <=> Time.parse(y[:last_date]) },
        billing_ends_contract: contract.end_date.nil? ? false : @billing.end_date == contract.end_date,
        contract: {
          number: contract.full_contract_number,
          market_location_name: contract.register_meta.name,
        },
        current_tariff: build_current_tariff(Vat.current),
        billing_year: billing_year,
        consumption_last_year: consumption(billing_year.nil? || @billing.billing_cycle.nil? ? nil : billing_year-1),
        consumption_year: consumption(billing_year) || 0,
        meter: build_meter,
        waste_de: build_waste_de,
        ratios_de: build_ratios_de,
        waste_local: build_waste_local,
        ratios_local: build_ratios_local,
        energy_report: build_report
      }.tap do |h|
        h[:labels1] = build_labels1(h[:consumption_last_year])
        h[:billing_type] = h[:billing_ends_contract] ? 'Schlussabrechnung' : 'Turnusabrechnung'
        h[:tense] = h[:billing_ends_contract] ? 'bezogen haben' : 'beziehen'
        h[:abschlag] = build_abschlag(h)
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
      @billing.billing_cycle&.begin_date&.year || @billing.begin_date&.year
    end

    def processing_contract
      @processing_contract ||= contract.localpool.active_localpool_processing_contract(@billing.begin_date)
    end

    def consumption(year)
      return nil unless year

      collected = @billing.billing_cycle ? @billing.contract.billings.to_a.keep_if(&:billing_cycle).keep_if { |x| x.billing_cycle.begin_date.year == year }.map { |x| [x.total_consumed_energy_kwh, x.total_days] } : [[@billing.total_consumed_energy_kwh, @billing.total_days]]
      return nil if collected.flatten.include?(nil)

      summed = collected.inject { |x, n| [x[0] + n[0], x[1] + n[1]] }
      return nil unless summed

      consumption_result = summed[0] * 365 / summed[1]
      if consumption_result.nan?
        return nil
      end

      consumption_result
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
        person_name = ''
        person_name += person_or_organization.title + ' ' if person_or_organization.title
        person_name += person_or_organization.first_name + ' ' + person_or_organization.last_name
        person_name
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

    def last_tariff
      @tariff ||= @billing.items.last.tariff
    end

    def to_kwh(value)
      (BigDecimal(value)/ 1000).round
    end

    def to_date(date)
      date.strftime('%d.%m.%Y')
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
        addressing: addressing_full(powertaker),
      }
      if contact(powertaker).nil?
        data[:name] = powertaker.name
      else
        contact(powertaker).tap do |contact|
          %i(title first_name last_name email).each do |field|
            data[field] = contact.send(field)
          end
        end
        data[:name] = powertaker.respond_to?(:name) && powertaker.class != Person ? powertaker.name : ''
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

    def calculate_taxes(amount_brutto, vat)
      issues_vat = contract.localpool.billing_detail.issues_vat
      vat = issues_vat ? BigDecimal(vat, 4) : 0
      amount_netto = vat > 0 ? 1/vat * amount_brutto : amount_brutto
      amount_taxes = vat > 0 ? amount_brutto - amount_netto: 0
      {
        amount_before_taxes: amount_netto,
        amount_after_taxes: amount_brutto,
        amount_taxes: amount_taxes,
        vat: vat
      }
    end

    def build_billing
      issues_vat = contract.localpool.billing_detail.issues_vat
      vat = Vat.current.amount
      {
        date: @billing.last_date,
        number: @billing.full_invoice_number,
        baseprice: german_div(BigDecimal(last_tariff.baseprice_cents_per_month, 4)),
        energyprice: german_div(BigDecimal(last_tariff.energyprice_cents_per_kwh, 4)),
        consumed_energy_kwh: @billing.items.first.consumed_energy_kwh,
      }.tap do |hash|
        netto  = @billing.total_amount_before_taxes.round(0)
        brutto = @billing.total_amount_after_taxes.round(0)
        balance_at = BigDecimal(@billing.balance_before) / 10

        balance_at_before_taxes = calculate_taxes(balance_at, vat)[:amount_before_taxes]
        balance_at_after_taxes = calculate_taxes(balance_at, vat)[:amount_after_taxes]
        balance_at_taxes = calculate_taxes(balance_at, vat)[:amount_taxes]
        forderung_net = netto - balance_at_before_taxes
        forderung_tax = (brutto-netto) - balance_at_taxes

        to_pay_cents = balance_at - brutto
        has_bank_and_direct_debit = @billing.contract.customer_bank_account&.direct_debit
        hash[:netto] = german_div(netto)
        hash[:brutto] = german_div(brutto)
        hash[:vat] = @billing.items.map(&:vat).map(&:amount).compact.uniq.map {|v| v*100-100}.map(&:to_i).map {|v| "#{v}%"}.join ', '
        hash[:vat_amount] = german_div(brutto-netto)
        hash[:balance_at_before_taxes] = german_div(balance_at_before_taxes)
        hash[:balance_at_after_taxes] = german_div(balance_at_after_taxes)
        hash[:balance_at_taxes] = german_div(balance_at_taxes)
        hash[:to_pay] = german_div(to_pay_cents.abs)
        hash[:forderung_net] = german_div(forderung_net.abs)
        hash[:forderung_tax] = german_div(forderung_tax.abs)
        hash[:forderung]  = to_pay_cents.positive? ? 'Erstattung' : 'Forderung'
        hash[:rueck_nach] = to_pay_cents.positive? ? 'Rück' : 'Nach'
        hash[:satz_forderung] = if has_bank_and_direct_debit
                                  if to_pay_cents.positive?
                                    'Der Betrag wird in Kürze auf Ihrem Bankkonto gutgeschrieben.'
                                  elsif to_pay_cents.negative?
                                    'Der Betrag wird in Kürze von Ihrem Bankkonto eingezogen.'
                                  else
                                    ''
                                  end
                                else
                                  if to_pay_cents.positive?
                                    'Bitte geben Sie uns Ihre Bankverbindung (IBAN, BIC) für die Erstattung Ihres Guthabens.'
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
          consumed_energy_kwh: item.consumed_energy_kwh,
          length_in_days: item.length_in_days,
          meter_serial_number: item.meter.product_serialnumber
        }.tap do |h|
          rounded_consumed = h[:last_kwh] - h[:begin_kwh]
          if rounded_consumed-h[:consumed_energy_kwh] != 0
            raise 'Unexpected'
          end

          if localpool.billing_detail.issues_vat
            h[:base_price_cents_per_day]   = german_div(item.baseprice_cents_per_day_before_taxes*100, prec: 4)
            h[:base_price_euros]           = german_div(item.baseprice_cents_before_taxes)
            h[:energy_price_cents_per_kwh] = german_div(item.tariff.energyprice_cents_per_kwh_before_taxes*100, prec: 4)
            h[:energy_price_euros]         = german_div(item.energyprice_cents_before_taxes.round(0))
            h[:price_cents_after_taxes]    = german_div(item.price_cents_after_taxes.round(0))
            h[:price_cents_before_taxes]   = german_div(item.price_cents_before_taxes.round(0))
            h[:vat_amount]                 = german_div(item.price_cents_after_taxes.round(0) - item.price_cents_before_taxes.round(0))
            h[:vat]                        = ((item.vat.amount - 1) * 100).to_i.to_s + "%"
          else # brutto
            h[:base_price_cents_per_day]   = german_div(item.baseprice_cents_per_day_after_taxes*100, prec: 4)
            h[:base_price_euros]           = german_div(item.baseprice_cents_before_taxes*item.vat.amount)
            h[:energy_price_cents_per_kwh] = german_div(item.tariff.energyprice_cents_per_kwh_before_taxes*item.vat.amount*100, prec: 4)
            h[:energy_price_euros]         = german_div(item.energyprice_cents_before_taxes.round(0) * item.vat.amount)
            h[:price_cents_after_taxes]    = german_div(item.price_cents_before_taxes.round(0))
            h[:price_cents_before_taxes]   = german_div(item.price_cents_before_taxes.round(0))
            h[:vat_amount]                 = "0%"
            h[:vat]                        = german_div(0)
          end
        end
      end
    end

    def build_current_tariff(vat)
      {
        energyprice_cents_per_kwh_netto: german_div(@contract.current_tariff.energyprice_cents_per_kwh_before_taxes*100),
        baseprice_euros_per_month_netto: german_div(@contract.current_tariff.baseprice_cents_per_month_before_taxes),
        energyprice_cents_per_kwh_brutto: german_div(@contract.current_tariff.energyprice_cents_per_kwh_before_taxes*vat.amount*100),
        baseprice_euros_per_month_brutto: german_div(@contract.current_tariff.baseprice_cents_per_month_before_taxes*vat.amount),
      }
    end

    def build_abschlag(billing_hash)
      payment = @billing.adjusted_payment || @billing.contract.current_payment
      abschlag = {
        was_changed: !@billing.adjusted_payment.nil?,
        satz: ''
      }.merge(build_payment(payment))
      return abschlag if payment.nil?

      vat = billing_hash[:vat]
      has_bank_and_direct_debit = @billing.contract.customer_bank_account&.direct_debit
      payment_amounts_to = "Abschlag beträgt #{abschlag[:amount_euro_netto]} € netto +  #{abschlag[:amount_euro_vat]} € USt (#{((Vat.current.amount - 1)*100).to_i} %) = <strong>#{abschlag[:amount_euro]} € brutto</strong>"
      abschlag_begin_date = to_date(abschlag[:begin_date])
      # negative means it's disabled for this powertaker
      abschlag[:satz] = if abschlag[:disabled]
                          ''
                        else
                          if has_bank_and_direct_debit
                            every_month = 'am Anfang eines jeden Monats von Ihrem Konto eingezogen'
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
      payment = payment.respond_to?(:first) ? payment.first : payment
      if payment.nil?
        {
          disabled: true
        }
      else
        {
          energy_consumption_kwh_pa: payment.energy_consumption_kwh_pa,
          cycle: payment.cycle == 'monthly' ? 'Monat' : 'Jahr',
          amount_euro: german_div(payment.price_cents_after_taxes),
          amount_euro_netto: german_div(payment.price_cents_before_taxes),
          amount_euro_vat: german_div(payment.price_cents_after_taxes-payment.price_cents_before_taxes),
          disabled: payment.price_cents.negative?,
          begin_date: payment.begin_date
        }
      end
    end

    def build_meter
      {
        buzzn_ids: contract.register_meta.registers.map { |x| x.meter.legacy_buzznid }
      }
    end

    def build_waste_de
      {
        nuclear_waste_miligramm_per_kwh: format('%.4f', (@de_stats[:nuclear_waste_miligramm_per_kwh] / 1000.00)),
        co2_emission_gramm_per_kwh: @de_stats[:co2_emission_gramm_per_kwh]
      }
    end

    def build_ratios_de
      [:nuclearRatio, :coalRatio, :gasRatio, :otherFossilesRatio, :otherRenewablesRatio, :renewablesEegRatio].map { |type| @de_stats[type.to_s.underscore] }.to_json
    end

    def build_waste_local
      {
        nuclear_waste_miligramm_per_kwh: format('%.4f', localpool.fake_stats['nuclearWasteMiligrammPerKwh'] || 0.0),
        co2_emission_gramm_per_kwh: localpool.fake_stats['co2EmissionGrammPerKwh'].to_i
      }
    end

    def build_ratios_local
      [:nuclearRatio, :coalRatio, :gasRatio, :otherFossilesRatio, :otherRenewablesRatio, :renewablesEegRatio, :renterPowerEeg].map { |type| localpool.fake_stats[type.to_s] }.to_json
    end

    def build_report
      Hash[[:selfSufficiencyReport, :utilizationReport, :gasReport, :sunReport, :waterReport, :windReport, :electricitySupplier, :tech].collect { |k| [k.to_s.underscore, localpool.fake_stats[k.to_s]]}].tap do |h|
        h['tech'] = h['tech'].gsub('##', '<br />') if h['tech']
      end
    end

    def build_labels1(consumption_last_year)
      labels = if billing_year
                 [
                   "Ihr Jahresverbrauch in #{billing_year}",
                   "Ihr Jahresverbrauch in #{billing_year-1}",
                   'Referenz 1-Personen-Haushalt',
                   'Referenz 2-Personen-Haushalt',
                   'Referenz 3 und mehr Personen-Haushalt'
                 ]
               else
                 []
               end
      unless consumption_last_year
        labels.delete_at(1)
      end
      '[' + labels.map {|x| "'#{x}'"}.join(',') + ']'
    end

  end
end
