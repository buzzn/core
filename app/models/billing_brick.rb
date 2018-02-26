#
# A billing brick stores a part of the energy consumption and price of a market location.
#
# NOTICE: it's a simple value object for now, but will likely become an ActiveRecord model
# to be persisted along with the completed billings. Not using dry-struct here because of that.
#
class BillingBrick

  extend Dry::Initializer
  option :market_location, default: proc { nil }
  option :start_date, default: proc { nil }
  option :end_date, default: proc { nil }
  # can be :power_taker, :third_party or :gap.
  # TODO: put it in an enum
  option :type, default: proc { nil }
  # can be :open or :closed
  option :status, default: proc { :open }

  def ==(other)
    same_simple_attrs = %i(start_date end_date type status).all? { |attr| send(attr) == other.send(attr) }
    same_market_location = market_location.id == other.market_location.id
    same_simple_attrs && same_market_location
  end

end
