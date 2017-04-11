class BillingCycle < ActiveRecord::Base
  # TODO: think about consolidating Billing constants and error messages with those from this class
  OPEN = 'open'
  CALCULATED = 'calculated'
  DELIVERED = 'delivered'
  SETTLED = 'settled'
  CLOSED = 'closed'

  class << self
    def all_stati
      @status ||= [OPEN, CALCULATED, DELIVERED, SETTLED, CLOSED]
    end
  end

  # error messages
  WAS_ALREADY_CLOSED = 'was already closed'

  has_many :billings, dependent: :destroy

  belongs_to :localpool

  validates :begin_date, presence: true
  validates :end_date, presence: true
  validates :name, presence: true
  validates :status, inclusion: { in: self.all_stati }
  validates :localpool_id, presence: true

  validate :validate_invariants

  def validate_invariants
    # check lifecycle changes
    if change = changes['status']
      errors.add(:status, WAS_ALREADY_CLOSED) if change[0] == CLOSED
    end
  end
end