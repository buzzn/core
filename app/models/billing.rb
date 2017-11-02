class Billing < ActiveRecord::Base

  enum status: %i(open calculated delivered settled closed).each_with_object({}) { |i, o| o[i] = i.to_s }

  belongs_to :billing_cycle
  belongs_to :localpool_power_taker_contract, class_name: Contract::LocalpoolPowerTaker
  belongs_to :start_reading, class_name: Reading::Single, foreign_key: :start_reading_id
  belongs_to :end_reading, class_name: Reading::Single, foreign_key: :end_reading_id
  belongs_to :device_change_1_reading, class_name: Reading::Single, foreign_key: :device_change_1_reading_id
  belongs_to :device_change_2_reading, class_name: Reading::Single, foreign_key: :device_change_2_reading_id

end
