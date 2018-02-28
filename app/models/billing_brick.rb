#
# A billing brick stores a part of the energy consumption within a billing.
#
# NOTICE: it's a simple value object for now, but will likely become an ActiveRecord model
# to be persisted along with the completed billings. Not using dry-struct here because of that.
#
class BillingBrick

  extend Dry::Initializer
  option :market_location
  option :date_range, Types.Instance(Range)
  option :type, Types::Strict::Symbol.enum(:power_taker, :third_party, :gap)
  option :status, Types::Strict::Symbol.enum(:open, :closed), default: proc { :open }

  def ==(other)
    equal_simple_attrs = %i(date_range type status).all? { |attr| send(attr) == other.send(attr) }
    equal_market_location = market_location.id == other.market_location.id
    equal_simple_attrs && equal_market_location
  end

end
