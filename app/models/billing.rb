class Billing < ActiveRecord::Base

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

  belongs_to :billing_cycle
  belongs_to :localpool_power_taker_contract, class_name: Contract::LocalpoolPowerTaker
  belongs_to :start_reading, class_name: SingleReading, foreign_key: :start_reading_id
  belongs_to :end_reading, class_name: SingleReading, foreign_key: :end_reading_id
  belongs_to :device_change_1_reading, class_name: SingleReading, foreign_key: :device_change_1_reading_id
  belongs_to :device_change_2_reading, class_name: SingleReading, foreign_key: :device_change_2_reading_id

  validates :start_reading_id, presence: true
  validates :end_reading_id, presence: true
  validates :device_change_1_reading_id, presence: false
  validates :device_change_2_reading_id, presence: false
  validates :total_energy_consumption_kwh, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :total_price_cents, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :prepayments_cents, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :receivables_cents, presence: true, numericality: { only_integer: true } #may be negative if LSG has to pay back money
  validates :invoice_number, presence: false
  validates :status, inclusion: {in: self.all_stati}
  validates :billing_cycle_id, presence: true
  validates :localpool_power_taker_contract_id, presence: true

  validate :validate_invariants

  def validate_invariants
    # check lifecycle changes
    if change = changes['status']
      errors.add(:status, WAS_ALREADY_CLOSED) if change[0] == CLOSED
    end
  end
end
