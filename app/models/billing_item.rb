#
# A billing item stores a part of the energy consumption within a billing.
#
require_relative 'concerns/with_date_range'
require_relative 'concerns/last_date'
require_relative 'concerns/date_range_scope'

class BillingItem < ActiveRecord::Base

  include LastDate
  include WithDateRange
  include DateRangeScope

  belongs_to :billing
  belongs_to :register, class_name: 'Register::Base'
  belongs_to :tariff, class_name: 'Contract::Tariff'
  belongs_to :begin_reading, class_name: 'Reading::Single'
  belongs_to :end_reading, class_name: 'Reading::Single'

  has_one :contract, through: :billing
  has_one :meter, through: :register, foreign_key: :meter_id

  enum contract_type: %i(power_taker third_party gap).each_with_object({}).each { |k, map| map[k] = k.to_s }

  def status
    if billing
      %w(open calculated).include?(billing.status.to_s) ? 'open' : 'closed'
    else
      # we can't say if a third_party contract is paid, and we don't need to know, either.
      contract_type == 'third_party' ? nil : 'open'
    end
  end

  def in_date_range?(date_range)
    if date_range.first > self.begin_date && date_range.first < self.end_date
      true
    elsif date_range.last > self.begin_date && date_range.last <= self.end_date
      true
    else
      false
    end
  end

  def consumed_energy
    return unless end_reading && begin_reading
    BigDecimal(end_reading.value) - BigDecimal(begin_reading.value)
  end

  def consumed_energy_kwh
    return unless end_reading && begin_reading
    (consumed_energy / 1000).round
  end

  def length_in_days
    return unless end_date && begin_date
    (end_date - begin_date).to_i
  end

  # FIXME: move to tariff
  def baseprice_cents_per_day_before_taxes
    return unless tariff
    (BigDecimal(tariff.baseprice_cents_per_month, 4) * 12) / 365
  end

  # FIXME: move to tariff
  def baseprice_cents_per_day_after_taxes
    return unless tariff
    (tariff.baseprice_cents_per_month_after_taxes * 12) / 365
  end

  def baseprice_cents_before_taxes
    return unless length_in_days && baseprice_cents_per_day_before_taxes
    (length_in_days * baseprice_cents_per_day_before_taxes).round(0)
  end

  def baseprice_cents_after_taxes
    return unless length_in_days && baseprice_cents_per_day_after_taxes
    (length_in_days * baseprice_cents_per_day_after_taxes).round(0)
  end

  def price_cents_before_taxes
    return unless baseprice_cents_before_taxes && energyprice_cents_before_taxes
    baseprice_cents_before_taxes + energyprice_cents_before_taxes
  end

  def price_cents_after_taxes
    return unless baseprice_cents_after_taxes && energyprice_cents_after_taxes
    baseprice_cents_after_taxes + energyprice_cents_after_taxes
  end

  def energyprice_cents_before_taxes
    return unless consumed_energy_kwh && tariff
    (consumed_energy_kwh * BigDecimal(tariff.energyprice_cents_per_kwh, 4)).round(0)
  end

  def energyprice_cents_after_taxes
    return unless consumed_energy_kwh && tariff
    (consumed_energy_kwh * tariff.energyprice_cents_per_kwh_after_taxes).round(0)
  end

end
