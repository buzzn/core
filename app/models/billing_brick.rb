#
# A billing brick stores a part of the energy consumption within a billing.
#
# NOTICE: it's a simple value object for now, but will likely become an ActiveRecord model
# to be persisted along with the completed billings. Not using dry-struct here because of that.
#
class BillingBrick < ActiveRecord::Base

  belongs_to :billing

  attr_accessor :market_location, :type, :date_range

  # Minimal table
  # [x] - begin_date
  # [x] - end_date
  # [ ] - type (with enum) # (power_taker third_party gap)
  # [ ] - status (from billing)  (with enum)
  # [ ] - create PG enum
  # Associations
  # [x] - billing_brick --> billing
  # [x] - billing --> billing_brick
  # Implement date range
  # [ ] set with range
  # [ ] set with dates
  # set up enums

  # enum type: %i(power_taker third_party gap).each_with_object({}).each {|k, map| map[k] = k.to_s }
  # enum status: %i(open closed).each_with_object({}).each {|k, map| map[k] = k.to_s }

  # TODO
  # def begin_date
  #   date_range.first
  # end

  # def end_date
  #   date_range.last
  # end

  # def end_date=(new_end_date)
  #   date_range = date_range.first..new_end_date
  # end

  # def begin_date=(new_begin_date)
  #   date_range = new_begin_date..date_range.last
  # end

  def ==(other)
    equal_simple_attrs = %i(date_range type status).all? { |attr| send(attr) == other.send(attr) }
    equal_market_location = market_location.id == other.market_location.id
    equal_simple_attrs && equal_market_location
  end

end
