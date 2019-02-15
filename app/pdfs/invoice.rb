# coding: utf-8
require_relative 'generator'

module Pdf
  class Invoice < Generator

    def initialize(billing)
      super
      @billing = billing
    end

    protected

    def build_struct
      billing_config = CoreConfig.load(Types::BillingConfig)
      {
        title_text: @billing.full_invoice_number,
        sales_tax_number: contract.localpool.localpool_processing_contract.sales_tax_number,
        contractor: build_contractor,
        powertaker: build_powertaker,
        no_contact: contact(powertaker).nil?,
        org_email: powertaker.email,
        localpool: build_localpool,
        billing: build_billing,
        items: build_billing_items,
        vat: ((billing_config.vat - 1.0) * 100).round,
        contract: {
          number: contract.full_contract_number,
        },
        current_tariff: build_current_tariff,
        billing_year: billing_year,
        consumption_last_year: consumption(billing_year.nil? ? nil : billing_year-1),
        consumption_year: consumption(billing_year),
        abschlag: build_abschlag,
        meter: build_meter,
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
      summed[0] * 365.00 / summed[1]
    end

    def contractor_address
      @caddress ||= contractor.address
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
          "#{prefix} #{person_or_organization.first_name}"
        else
          "#{prefix} #{person_or_organization.title} #{person_or_organization.last_name}"
        end
      when Organization
      when Organization::General
        'Sehr geehrte Damen und Herren'
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
      date.to_s
    end

    def to_euro(cents)
      (cents/100.0).round(2)
    end

    def build_contractor
      data = {
        name: name(contractor),
        contact: name(contact(contractor)),
      }
      %i(phone fax email).each do |field|
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
      contact(powertaker).tap do |contact|
        %i(title first_name last_name email).each do |field|
          data[field] = contact.send(field)
        end
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
        baseprice: to_euro(last_tariff.baseprice_cents_per_month),
        energyprice: to_euro(last_tariff.energyprice_cents_per_kwh),
        consumed_energy_kwh: @billing.items.first.consumed_energy_kwh,
      }.tap do |hash|
        netto = @billing.total_amount_before_taxes
        brutto = @billing.total_amount_after_taxes
        balance_at = @billing.balance_before
        to_pay_cents = (balance_at - @billing.total_amount_after_taxes * 10)/10
        has_bank_and_direct_debit = @billing.contract.customer_bank_account && @billing.contract.customer_bank_account.direct_debit
        hash[:netto] = to_euro(netto)
        hash[:brutto] = to_euro(brutto)
        hash[:vat_amount] = to_euro(brutto-netto)
        hash[:balance_at_invoice] = to_euro(balance_at / 10)
        hash[:to_pay] = to_euro(to_pay_cents.abs)
        hash[:forderung] = to_pay_cents.positive? ? 'Erstattung' : 'Forderung'
        hash[:rueck_nach] = to_pay_cents.positive? ? 'Rück' : 'Nach'
        hash[:satz_forderung] = if has_bank_and_direct_debit
                                  if to_pay_cents.positive?
                                    'Der Betrag wird in den nächsten Wochen auf ihrem Bankkonto gutgeschrieben.'
                                  elsif to_pay_cents.negative?
                                    'Der Betrag wird in den nächsten Wochen von ihrem Bankkonto eingezogen.'
                                  else
                                    ''
                                  end
                                else
                                  if to_pay_cents.positive?
                                    'Bitte geben Sie uns Ihre Bankverbindung (IBAN, BIC) für die Erstattung Ihres Guthabens an'
                                  elsif to_pay_cents.negative?
                                    'Bitte überweisen Sie den Betrag unter Angabe der Rechnungsnummer auf das oben angegebene Konto'
                                  else
                                    ''
                                  end
                                end
      end
    end

    def build_localpool
      {
        name: contract.localpool.name
      }
    end

    def build_billing_items
      @billing.items.collect do |item|
        {
          begin_date: to_date(item.begin_date),
          last_date: to_date(item.last_date),
          begin_kwh: to_kwh(item.begin_reading.value),
          last_kwh: to_kwh(item.end_reading.value),
          consumed_energy_kwh: item.consumed_energy_kwh,
          energy_price_cents_per_kwh: item.tariff.energyprice_cents_per_kwh,
          energy_price_euros: to_euro(item.energy_price_cents),
          length_in_days: item.length_in_days,
          base_price_euros_per_day: to_euro(item.baseprice_cents_per_day),
          base_price_euros: to_euro(item.base_price_cents),
          meter_name: item.meter.name
        }
      end
    end

    def build_current_tariff
      {
        energyprice_cents_per_kwh: @contract.current_tariff.energyprice_cents_per_kwh,
        baseprice_euros_per_month:  to_euro(@contract.current_tariff.baseprice_cents_per_month),
      }
    end

    def build_abschlag
      abschlag = {
        was_changed: !@billing.adjusted_payment.nil?,
      }.merge(build_payment(@billing.adjusted_payment || @billing.contract.current_payment))
      has_bank_and_direct_debit = @billing.contract.customer_bank_account && @billing.contract.customer_bank_account.direct_debit
      payment_amounts_to = "Abschlag beträgt #{'%.2f' % abschlag[:amount_euro]}"
      abschlag[:satz] = if has_bank_and_direct_debit
                          every_month = 'jeden Monat von Ihrem Konto eingezogen'
                          if abschlag[:was_changed]
                            "Ihr neuer #{payment_amounts_to}. Er wird ab dem #{abschlag[:begin_date]} #{every_month}."
                          else
                            "Ihr #{payment_amounts_to}. Er wird wie gewohnt #{every_month}."
                          end
                        else
                          if abschlag[:was_changed]
                            "Ihr neuer #{payment_amounts_to}. Bitte überweisen Sie zu dem 01. eines Monats, erstmalig zum #{abschlag.begin_date} den neuen Abschlag auf das oben angegebene Konto."
                          else
                            "Ihr #{payment_amounts_to}. Bitte überweisen Sie den Abschlag wie gewohnt auf das oben angegebene Konto"
                          end
                        end
      abschlag
    end

    def build_payment(payment)
      {
        energy_consumption_kwh_pa: payment.energy_consumption_kwh_pa,
        cycle: payment.cycle == 'monthly' ? 'Monat' : 'Jahr',
        amount_euro: to_euro(payment.price_cents),
        begin_date: payment.begin_date
      }
    end

    def build_meter
      {
        buzzn_ids: contract.register_meta.registers.map { |x| x.meter.legacy_buzznid }
      }
    end

    def build_labels1(consumption_last_year)
      labels = [
                 "Ihr Jahresverbrauch in #{billing_year} (1)",
                 "Ihr Jahresverbrauch in #{billing_year-1} (2)",
                 'Referenz 1-Personen-Haushalt',
                 'Referenz 2-Personen-Haushalt',
                 'Referenz 3 und mehr Personen-Haushalt'
               ]
      if consumption_last_year
        labels.delete(1)
      end
      '[' + labels.map {|x| "'#{x}'"}.join(',') + ']'
    end

  end
end
