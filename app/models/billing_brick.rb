#
# A billing brick stores a part of the energy consumption within a billing.
#
# NOTICE: it's a simple value object for now, but will likely become an ActiveRecord model
# to be persisted along with the completed billings. Not using dry-struct here because of that.
#
class BillingBrick < ActiveRecord::Base

  self.inheritance_column = '_type' # we use type as a regular attribute, not for STI

  belongs_to :billing

  # clarify if this will stay here (it can be inferred through the billing)
  attr_accessor :market_location

  enum status: %i(open closed).each_with_object({}).each {|k, map| map[k] = k.to_s }
  enum type: %i(power_taker third_party gap).each_with_object({}).each {|k, map| map[k] = k.to_s }

  # Minimal table
  # [x] - begin_date
  # [x] - end_date
  # [x] - status (with enum)
  # [x] - type (with enum)
  # [x] - create PG enum
  # Associations
  # [x] - billing_brick --> billing
  # [x] - billing --> billing_brick
  # Implement date range
  # [x] set with range
  # [x] set with dates
  # -----
  # [ ] set status from billing in brickbuilder

  def date_range=(new_range)
    self[:begin_date] = new_range.first
    self[:end_date]   = new_range.last
  end

  def date_range
    begin_date..end_date
  end

  def ==(other)
    equal_simple_attrs = %i(date_range type status).all? { |attr| send(attr) == other.send(attr) }
    equal_market_location = market_location.id == other.market_location.id
    equal_simple_attrs && equal_market_location
  end

end
