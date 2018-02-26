#
# A billing brick stores a part of the energy consumption and price of a market location.
#
# NOTICE: it's a simple value object for now, but will likely become an ActiveRecord model
# to be persisted along with the completed billings. Not using dry-struct here because of that.
#
class BillingBrick

  extend Dry::Initializer
  option :start_date, default: proc { nil }
  option :end_date, default: proc { nil }
  option :type, default: proc { nil }
  option :status, default: proc { 'open' } # can also be 'closed'

end
