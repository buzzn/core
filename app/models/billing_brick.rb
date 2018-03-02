#
# A billing brick stores a part of the energy consumption within a billing.
#
require_relative 'concerns/with_date_range'

class BillingBrick < ActiveRecord::Base

  include WithDateRange

  belongs_to :billing

  enum type: %i(power_taker third_party gap).each_with_object({}).each { |k, map| map[k] = k.to_s }

  def status
    if billing
      %w(open calculated).include?(billing.status.to_s) ? 'open' : 'closed'
    else
      'open'
    end
  end

end
