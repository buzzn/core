# coding: utf-8
require_relative 'generator'
require_relative 'serializers'

module Pdf
  class A0xGeneral < Generator

    include Serializers

    attr_reader :contract

    def initialize(contract)
      super
      @contract = contract
    end

    protected

    def title
      "#{Buzzn::Utils::Chronos.now.strftime('%Y-%m-%d-%H-%M-%S')}-Auftragseingangsbestätigung-#{contract.localpool.slug}-#{contract.contract_number}-#{contract.contract_number_addition}"
    end

    def build_struct
      {
        localpool: build_localpool(contract.localpool),
        powergiver: build_powergiver(@contract.contractor, @contract),
        powertaker: build_powertaker(@contract.customer, @contract),
        contract: build_contract,
        today: Date.today,
        payment: build_payment(@contract.current_payment),
        tariff: build_tariff(@contract.current_tariff),
        lpc_creditor_identification: some_or(contract.localpool.localpool_processing_contract.creditor_identification, '-'),
        # if the contract is not yet fully finished, don't print some
        # information, even though it is already set
        is_pre_contract: false
      }.tap do |h|
        h[:powergiver][:bank_account] = build_bank_account(@contract.contractor_bank_account)
        h[:powergiver][:tax_number] = @contract.localpool.localpool_processing_contract.tax_number
        h[:powergiver][:sales_tax_number] = @contract.localpool.localpool_processing_contract.sales_tax_number
      end
    end

    def build_contract
      {
        begin_date: german_date(@contract.begin_date),
        contractor: build_powergiver(@contract.contractor, @contract),
        full_contract_number: @contract.full_contract_number,
        market_location_name: @contract.register_meta.name,
        meters: build_meters,
        forecast_kwh_pa: @contract.forecast_kwh_pa,
        old_supplier_name: some_or(@contract.old_supplier_name, '-'),
        old_customer_number: some_or(@contract.old_customer_number, '-'),
        old_account_number: some_or(@contract.old_account_number, '-'),
        mandate_reference: some_or(@contract.mandate_reference, @contract.full_contract_number),
        customer_bank_account: build_bank_account(@contract.customer_bank_account),
      }
    end

    def build_meters
      @contract.register_meta.registers.collect { |x| x.meter }.uniq.collect do |meter|
        {
          product_serialnumber: meter.product_serialnumber,
          location_description: meter.location_description
        }
      end
    end

    def build_tariff(tariff)
      {
        baseprice_euro_netto: german_div(tariff.baseprice_cents_per_month_before_taxes),
        baseprice_euro_brutto: german_div(tariff.baseprice_cents_per_month_after_taxes),
        energyprice_cents_netto: german_div(tariff.energyprice_cents_per_kwh_before_taxes*100),
        energyprice_cents_brutto: german_div(tariff.energyprice_cents_per_kwh_after_taxes*100),
      }
    end

    def build_payment(payment)
      if payment.nil?
        {
          disabled: true
        }
      else
        {
          energy_consumption_kwh_pa: payment.energy_consumption_kwh_pa,
          cycle: payment.cycle == 'monthly' ? 'Monat' : 'Jahr',
          amount_euro: german_div(BigDecimal(payment.price_cents, 4)),
          netto: german_div(payment.price_cents_before_taxes),
          brutto: german_div(payment.price_cents_after_taxes),
          taxes: german_div(payment.price_cents_after_taxes - payment.price_cents_before_taxes),
          disabled: payment.price_cents.negative?,
          begin_date: payment.begin_date
        }
      end
    end

    def build_localpool(localpool)
      {
        name: localpool.name,
        address: build_address(localpool.address)
      }
    end

  end
end
