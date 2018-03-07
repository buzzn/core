# FIXME: Billing should become a module, so we don't have to add < ActiveRecord::Base here
class Billing < ActiveRecord::Base
  class BrickBuilder

    class << self

      def from_contract(contract, max_date_range)
        date_range = date_range(contract, max_date_range)
        attrs = {
          contract_type:   contract_type(contract),
          date_range:      date_range,
          tariff:          tariff(contract),
          begin_reading:   reading_at(contract, date_range.first),
          end_reading:     reading_at(contract, date_range.last)
        }
        BillingBrick.new(attrs)
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
      # Later on we'll need to find the tariff that was active on the contract at the begin and end dates of the brick
      def tariff(contract)
        contract.tariffs.last
      end

      def reading_at(contract, date)
        contract.market_location.register.reading_at(date)
      end

    end

  end
end
