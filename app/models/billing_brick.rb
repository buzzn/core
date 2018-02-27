#
# A billing brick stores a part of the energy consumption within a billing.
#
# NOTICE: it's a simple value object for now, but will likely become an ActiveRecord model
# to be persisted along with the completed billings. Not using dry-struct here because of that.
#
class BillingBrick

  extend Dry::Initializer
  option :market_location
  option :begin_date, Types::Strict::Date
  option :end_date, Types::Strict::Date
  option :type, Types::Strict::Symbol.enum(:power_taker, :third_party, :gap)
  option :status, Types::Strict::Symbol.enum(:open, :closed), default: proc { :open }

  class << self

    # Factory method; for now in the brick itself.
    def from_contract(contract, min_begin_date, max_end_date)
      new(type:            brick_type(contract),
          begin_date:      brick_begin_date(contract, min_begin_date),
          end_date:        brick_end_date(contract, max_end_date),
          market_location: contract.market_location)
    end

    private

    # Example: Contract::LocalpoolPowerTaker => 'power_taker'
    def brick_type(contract)
      contract.model_name.name.sub('Contract::Localpool', '').underscore.to_sym
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

  def date_range
    begin_date..end_date
  end

  def ==(other)
    equal_simple_attrs = %i(begin_date end_date type status).all? { |attr| send(attr) == other.send(attr) }
    equal_market_location = market_location.id == other.market_location.id
    equal_simple_attrs && equal_market_location
  end

end
