#
# A billing brick stores a part of the energy consumption within a billing.
#
require_relative 'concerns/with_date_range'

class BillingBrick < ActiveRecord::Base

  include WithDateRange

  belongs_to :billing
  belongs_to :begin_reading, class_name: 'Reading::Single'
  belongs_to :end_reading, class_name: 'Reading::Single'

  enum type: %i(power_taker third_party gap).each_with_object({}).each { |k, map| map[k] = k.to_s }

  def status
    if billing
      %w(open calculated).include?(billing.status.to_s) ? 'open' : 'closed'
    else
      'open'
    end
  end

  def consumed_energy_kwh
    return unless end_reading && begin_reading
    (end_reading.value - begin_reading.value) / 1_000.0
  end
end
