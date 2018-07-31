require_relative '../constraints/billing_item'
module Schemas
  module Invariants

    BillingItem = Schemas::Support.Form(Schemas::Constraints::BillingItem) do
      configure do
        def in_contract_tariffs?(contract, tariff)
          contract.tariffs.include?(tariff.model)
        end

        def belongs_to_contract?(contract, register)
          contract.register_meta.register == register.model
        end

        def match_register?(register, reading)
          reading.register == register.model
        end

        def inside_period?(date_range, thing)
          thing.begin_date <= date_range.first && (thing.end_date.nil? || thing.end_date >= date_range.last)
        end
      end

      required(:billing).filled
      required(:tariff).filled
      required(:contract).filled
      required(:register).filled
      required(:date_range).filled
      required(:begin_reading).maybe
      required(:end_reading).maybe

      rule(tariff: [:tariff, :contract, :date_range]) do |tariff, contract, date_range|
        tariff.in_contract_tariffs?(contract).and(tariff.inside_period?(date_range))
      end

      rule(register: [:register, :contract, :date_range]) do |register, contract, date_range|
        register.belongs_to_contract?(contract)
      end

      rule(contract: [:contract, :billing, :date_range]) do |contract, billing, date_range|
        contract.inside_period?(date_range)
      end

      rule(begin_reading: [:register, :begin_reading]) do |register, begin_reading|
        begin_reading.filled?.then(begin_reading.match_register?(register))
      end

      rule(end_reading: [:register, :end_reading]) do |register, end_reading|
        end_reading.filled?.then(end_reading.match_register?(register))
      end

    end

  end
end
