require_relative 'concerns/last_date'

class BillingCycle < ActiveRecord::Base

  include LastDate

  belongs_to :localpool, class_name: 'Group::Localpool'

  def status
    :open
  end

  scope :permitted, ->(uids) { where(localpool_id: uids) }

end
