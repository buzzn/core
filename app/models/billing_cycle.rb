require_relative 'concerns/last_date'
require_relative 'concerns/with_date_range'

class BillingCycle < ActiveRecord::Base

  include LastDate
  include WithDateRange

  belongs_to :localpool, class_name: 'Group::Localpool'
  has_many :billings, dependent: :destroy

  def status
    :open
  end

  scope :permitted, ->(uids) { where(localpool_id: uids) }

end
