require_relative '../constraints/billing_item'
module Schemas
  module Invariants

    BillingItem = Schemas::Support.Form(Schemas::Constraints::BillingItem) do
      configure do
        def in_contract_tariffs?(contract, tariff)
          contract.tariffs.include?(tariff.model)
        end

        def belongs_to_contract?(contract, register)
          contract.register_meta.registers.include?(register.model)
        end

        def match_register?(register, reading)
          reading.register == register.model
        end

        def inside_period?(item, date_range, thing)
          thing.begin_date <= date_range.first && (!thing.respond_to?(:end_date) || thing.end_date.nil? || thing.end_date >= date_range.last)
        end

        def value_is_lower_than?(end_reading, begin_reading)
          end_reading.nil? || begin_reading.value <= end_reading.value
        end
      end

      optional(:id).maybe
      required(:billing).filled
      required(:tariff).filled
      required(:contract).filled
      required(:register).filled
      required(:date_range).filled
      required(:begin_reading).maybe
      required(:end_reading).maybe

      rule(tariff: [:tariff, :contract, :date_range]) do |tariff, contract, date_range|
        item = 'tariff'
        tariff.in_contract_tariffs?(contract).and(tariff.inside_period?(item, date_range))
      end

      rule(register: [:register, :contract, :date_range]) do |register, contract, date_range|
        register.belongs_to_contract?(contract)
      end

      rule(contract: [:contract, :billing, :date_range]) do |contract, billing, date_range|
        item = 'contract'
        contract.inside_period?(item, date_range)
      end

      rule(begin_reading: [:register, :begin_reading]) do |register, begin_reading|
        begin_reading.filled?.then(begin_reading.match_register?(register))
      end

      rule(end_reading: [:register, :end_reading]) do |register, end_reading|
        end_reading.filled?.then(end_reading.match_register?(register))
      end

      rule(begin_reading: [:begin_reading, :end_reading]) do |begin_reading, end_reading|
        begin_reading.filled?.then(begin_reading.value_is_lower_than?(end_reading))
      end

      validate(no_other_billings_in_range: %i[register date_range id]) do |register, date_range, id|
        register.model.billing_items.to_a.keep_if { |item| item.id != id && item.in_date_range?(date_range) }.empty?
      end

    end

  end
end
