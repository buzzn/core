require_relative 'concerns/last_date'
require_relative 'concerns/with_date_range'

class BillingCycle < ActiveRecord::Base

  include LastDate
  include WithDateRange

  belongs_to :localpool, class_name: 'Group::Localpool'
  has_many :billings, dependent: :destroy

  def status
    billing_statuses = billings.collect(&:status).uniq
    if billing_statuses.count == 1
      billing_statuses.first
    elsif billing_statuses.count == 2 && billing_statuses.include?(['closed', 'void'])
      'closed'
    elsif billing_statuses.include?('open')
      'open'
    elsif billing_statuses.include?('calculated')
      'calculated'
    elsif billing_statuses.include?('documented')
      'documented'
    else
      'open'
    end
  end

  # TODO broken as uids are '{class_name}:{id}' now
  scope :permitted, ->(uids) { where(localpool_id: uids) }

end
