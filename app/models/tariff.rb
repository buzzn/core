class Tariff < ActiveRecord::Base

  validates :name, presence: true
  validates :begin_date, presence: true
  validates :end_date, presence: false
  validates :energyprice_cents_per_kwh, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :baseprice_cents_per_month, presence: true, numericality: { only_integer: true, greater_than: 0 }
  
end
