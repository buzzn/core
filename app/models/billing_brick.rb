#
# A billing brick stores a part of the energy consumption within a billing.
#
# NOTICE: it's a simple value object for now, but will likely become an ActiveRecord model
# to be persisted along with the completed billings. Not using dry-struct here because of that.
#
class BillingBrick < ActiveRecord::Base

  belongs_to :billing

  # Generate minimal table
  # OK - begin_date
  # OK - end_date
  # - add type
  # - add status
  # - create PG enum
  # Add associations
  # OK - billing_brick --> billing
  # OK - billing --> billing_brick
  # Implement date range
  # set up enums

  # attr_accessor :date_range

  # extend Dry::Initializer
  # option :market_location
  # option :date_range, Types.Instance(Range)
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
