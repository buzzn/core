class Billing < ActiveRecord::Base

  enum status: %i(open calculated delivered settled closed).each_with_object({}) { |i, o| o[i] = i.to_s }

  belongs_to :billing_cycle
  # TODO: change or alias this to contract
  belongs_to :localpool_power_taker_contract, class_name: 'Contract::LocalpoolPowerTaker'

  has_many :bricks, class_name: 'BillingBrick'

end
