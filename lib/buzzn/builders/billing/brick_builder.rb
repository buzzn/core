# FIXME: Billing should become a module, so we don't have to add < ActiveRecord::Base here
class Billing < ActiveRecord::Base
  class BrickBuilder

    class << self

      def from_contract(contract, max_date_range)
        attrs = {
          type: brick_type(contract),
          date_range:      brick_date_range(contract, max_date_range),
          market_location: contract.market_location
        }
        BillingBrick.new(attrs)
      end

      private

      # Example: Contract::LocalpoolPowerTaker => 'power_taker'
      def brick_type(contract)
        contract.model_name.name.sub('Contract::Localpool', '').underscore.to_sym
      end

      def brick_date_range(contract, max_date_range)
        begin_date = brick_begin_date(contract, max_date_range.first)
        end_date   = brick_end_date(contract, max_date_range.last)
        begin_date..end_date
      end

      def brick_begin_date(contract, min_begin_date)
        if contract.begin_date < min_begin_date
          min_begin_date
        else
          contract.begin_date
        end
      end

      def brick_end_date(contract, max_end_date)
        if !contract.end_date
          max_end_date
        elsif contract.end_date >= max_end_date
          max_end_date
        else
          contract.end_date
        end
      end

    end

  end
end
