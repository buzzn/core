class BillingCycle < ActiveRecord::Base

  belongs_to :localpool, class_name: 'Group::Localpool'

  def status
    :open
  end

  private

  scope :permitted, ->(uids) { where(localpool_id: uids) }

end
