#
# A billing brick stores a part of the energy consumption within a billing.
#
require_relative 'concerns/with_date_range'

class BillingBrick < ActiveRecord::Base

  include WithDateRange

  belongs_to :billing
  belongs_to :tariff, class_name: 'Contract::Tariff'
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

  def energy_price_cents
    return unless consumed_energy_kwh && tariff
    consumed_energy_kwh * tariff.energyprice_cents_per_kwh
  end

  def base_price_cents
    length_in_days * daily_base_price
  end

  private

  def daily_base_price
    (tariff.baseprice_cents_per_month * 12) / 365.0
  end

  def length_in_days
    (end_date - begin_date).to_i
  end
end
