class BillingCycle < ActiveRecord::Base

  has_many :billings, dependent: :destroy

  belongs_to :localpool

  validates :begin_date, presence: true
  validates :end_date, presence: true
  validates :name, presence: true
  validates :localpool_id, presence: true

  def status
    all_stati = billings.collect(&:status).uniq
    if all_stati.include?(Billing::OPEN)
      Billing::OPEN
    elsif all_stati.include?(Billing::CALCULATED)
      Billing::CALCULATED
    elsif all_stati.include?(Billing::DELIVERED)
      Billing::DELIVERED
    elsif all_stati.include?(Billing::SETTLED)
      Billing::SETTLED
    else
      Billing::CLOSED
    end
  end
end