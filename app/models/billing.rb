require_relative 'concerns/last_date'
require_relative 'concerns/with_date_range'
require_relative 'concerns/date_range_scope'

class Billing < ActiveRecord::Base

  include LastDate
  include WithDateRange
  include DateRangeScope

  enum status: %i(open calculated delivered settled closed).each_with_object({}) { |i, o| o[i] = i.to_s }

  belongs_to :billing_cycle
  belongs_to :contract, -> { where(type: %w(Contract::LocalpoolPowerTaker Contract::LocalpoolGap Contract::LocalpoolThirdParty)) }, class_name: 'Contract::Base'

  has_many :bricks, class_name: 'BillingItem'

end
