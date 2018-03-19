require_relative '../billing'

module Builders::Billing
  class ItemBuilder

    class << self

      def from_contract(contract, max_date_range)
        date_range = date_range(contract, max_date_range)
        attrs = {
          contract_type:   contract_type(contract),
          date_range:      date_range,
          tariff:          tariff(contract),
          begin_reading:   reading_close_to(contract, date_range.first),
          end_reading:     reading_close_to(contract, date_range.last),
          contract:        contract # transiently adding the contract to pass it on
        }
        BillingItem.new(attrs)
      end

      private

      # Example: Contract::LocalpoolPowerTaker => 'power_taker'
      def contract_type(contract)
        contract.model_name.name.sub('Contract::Localpool', '').underscore.to_sym
      end

      def date_range(contract, max_date_range)
        begin_date = begin_date(contract, max_date_range.first)
        end_date   = end_date(contract, max_date_range.last)
        begin_date..end_date
      end

      def begin_date(contract, min_begin_date)
        if contract.begin_date < min_begin_date
          min_begin_date
        else
          contract.begin_date
        end
      end

      def end_date(contract, max_end_date)
        if !contract.end_date
          max_end_date
        elsif contract.end_date >= max_end_date
          max_end_date
        else
          contract.end_date
        end
      end

      # TODO: right now we don't handle tariff changes, so we can always take the latest tariff.
      # Later on we'll need to find the tariff that was active on the contract at the begin and end dates of the item
      def tariff(contract)
        contract.tariffs.last
      end

      def reading_close_to(contract, date)
        find_reading(contract, date)
      end

      # Find reading in DB
      def find_reading(contract, date)
        query_date_range = (date - 1.day)..(date + 1.day)
        readings = contract.market_location.register.readings.where(date: query_date_range)
        readings.to_a.max_by(&:value) # if there's more than one reading, take the highest one.
      end

    end

  end
end
