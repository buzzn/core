require_relative '../constraints/billing_item'
module Schemas
  module Invariants

    BillingItem = Schemas::Support.Form(Schemas::Constraints::BillingItem) do
      configure do
        def in_contract_tariffs?(contract, tariff)
          binding.pry
          contract.tariffs.contains?(tariff)
        end

        def match_contract?(contract, billing)
          billing.contract == contract
        end

        def in_registers?(register, contract)
          contract.market_location.register == register
        end

        def match_register?(reading, register)
          reading.register == register
        end

        def inside_period?(date_range, thing)
          thing.begin_date <= date_range.begin_date && (thing.end_date.nil? || thing.end_date >= date_range.end_date )
        end
      end

      required(:tariff).filled
      required(:billing).filled
      required(:begin_date).filled
      required(:register).filled
      required(:begin_reading).maybe
      required(:end_reading).maybe

      rule(tariff: [:tariff, :contract, :date_range]) do |tariff, contract, date_range|
        tariff.in_contract_tariffs?(contract).and(tariff.inside_period?(date_range))
      end

      rule(register: [:register, :contract, :date_range]) do |register, contract, date_range|
        contract.in_registers?(register)
      end

      rule(contract: [:contract, :billing, :date_range]) do |contract, billing, date_range|
        billing.match_contract?(contract).and(contract.inside_period?(date_range))
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
