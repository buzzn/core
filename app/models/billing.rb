class Billing < ActiveRecord::Base
  include Authority::Abilities
  include Buzzn::GuardedCrud

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

  validates :start_reading_id, presence: true
  validates :end_reading_id, presence: true
  validates :device_change_reading_1_id, presence: false
  validates :device_change_reading_2_id, presence: false
  validates :total_energy_consumption_kWh, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :total_price_cents, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :prepayments_cents, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :receivables_cents, presence: true, numericality: { only_integer: true } #may be negative if LSG has to pay back money
  validates :invoice_number, presence: false
  validates :status, inclusion: {in: self.all_stati}
  validates :billing_cycle_id, presence: true
  validates :localpool_power_taker_contract_id, presence: true

  validate :validate_invariants

  def self.readable_by_query(user)
    billing = Billing.arel_table
    billing_cycle = BillingCycle.arel_table
    contract = Contract::Base.arel_table

    # workaround to produce false always
    return billing[:id].eq(billing[:id]).not if user.nil?

    # assume all IDs are globally unique
    sqls = [
      billing_cycle.where(BillingCycle.readable_by_query(user)
                      .and(billing_cycle[:id].eq(billing[:billing_cycle_id]))),
      contract.where(Contract::Base.readable_by_query(user)
                      .and(contract[:id].eq(billing[:localpool_power_taker_contract_id]))),
      User.roles_query(user, admin: nil)
    ]
    sqls = sqls.collect{|s| s.project(1).exists}
    sqls[0].or(sqls[1]).or(sqls[2])
  end

  scope :readable_by, -> (user) do
    where(readable_by_query(user))
  end

  def validate_invariants
    # check lifecycle changes
    if change = changes['status']
      errors.add(:status, WAS_ALREADY_CLOSED) if change[0] == CLOSED
    end
  end

  def start_reading
    Reading.find(self.start_reading_id)
  end

  def end_reading
    Reading.find(self.end_reading_id)
  end

  def device_change_reading_1
    Reading.find(self.device_change_reading_1_id)
  end

  def device_change_reading_2
    Reading.find(self.device_change_reading_2_id)
  end
end
