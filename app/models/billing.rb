require_relative 'concerns/in_date_range_scope'

class Billing < ActiveRecord::Base

  include InDateRangeScope

  enum status: %i(open calculated delivered settled closed).each_with_object({}) { |i, o| o[i] = i.to_s }

  belongs_to :billing_cycle
  belongs_to :contract, -> { where(type: %w(Contract::LocalpoolPowerTaker Contract::LocalpoolGap Contract::LocalpoolThirdParty)) }, class_name: 'Contract::Base'

  has_many :bricks, class_name: 'BillingBrick'

  # TODO: DRY this up when Christian has created the module for date ranges
  def date_range=(new_range)
    self.begin_date = new_range.first
    self.end_date   = new_range.last
  end

  def date_range
    begin_date..end_date
  end

end
