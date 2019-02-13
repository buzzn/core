# coding: utf-8
require_relative 'generator'

module Pdf
  class Invoice < Generator

    def initialize(billing)
      super
      @billing = billing
      # byebug.byebug
    end

    protected

    def build_struct
      billing_config = CoreConfig.load(Types::BillingConfig)
      {
        title_text: @billing.full_invoice_number,
        tax_number: contract.localpool.localpool_processing_contract.tax_number,
        contractor: build_contractor,
        powertaker: build_powertaker,
        localpool: build_localpool,
        billing: build_billing,
        items: build_billing_items,
        vat: ((billing_config.vat - 1.0) * 100).round,
        contract: {
          number: contract.full_contract_number,
        },
        current_tariff: build_current_tariff,
        abschlag: build_abschlag,
        meter: build_meter
      }
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
                 when 'F'
                   'Sehr geehrte Frau'
                 when 'M'
                   'Sehr geehrter Herr'
                 else
                   'Hallo'
                 end
        "#{prefix} #{person_or_organization.title} #{person_or_organization.last_name}"
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
        hash[:netto] = to_euro(netto)
        hash[:brutto] = to_euro(brutto)
        hash[:vat_amount] = to_euro(brutto-netto)
        hash[:balance_at_invoice] = to_euro(balance_at / 10)
        hash[:to_pay] = to_euro(to_pay_cents.abs)
        hash[:forderung] = to_pay_cents.positive? ? 'Erstattung' : 'Forderung'
        hash[:rueck_nach] = to_pay_cents.positive? ? 'Rück' : 'Nach'
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
      {
        was_changed: !@billing.adjusted_payment.nil?,
      }.merge(build_payment(@billing.adjusted_payment || @billing.contract.current_payment))
    end

    def build_payment(payment)
      {
        energy_consumption_kwh_pa: payment.energy_consumption_kwh_pa,
        cycle: payment.cycle == 'monthly' ? 'Monat' : 'Jahr',
        amount_euro: to_euro(payment.price_cents)
      }
    end

    def build_meter
      {
        mpsn_ZählerNr_alt: contract.register_meta.registers.first.meter.legacy_buzznid
      }
    end

  end
end
