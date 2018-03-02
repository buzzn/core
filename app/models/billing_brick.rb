#
# A billing brick stores a part of the energy consumption within a billing.
#
require_relative 'concerns/with_date_range'

class BillingBrick < ActiveRecord::Base

  include WithDateRange

  belongs_to :billing

  # clarify if this will stay here (it can be inferred through the billing)
  attr_accessor :market_location

  enum status: %i(open closed).each_with_object({}).each { |k, map| map[k] = k.to_s }
  enum type: %i(power_taker third_party gap).each_with_object({}).each { |k, map| map[k] = k.to_s }

end
