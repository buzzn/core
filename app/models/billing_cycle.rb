class BillingCycle < ActiveRecord::Base
  include Authority::Abilities
  include Buzzn::GuardedCrud

  has_many :billings, dependent: :destroy

  belongs_to :localpool, class_name: 'Group::Localpool'

  validates :begin_date, presence: true
  validates :end_date, presence: true
  validates :name, presence: true
  validates :localpool_id, presence: true

  validate :validate_invariants

  def self.readable_by_query(user)
    billing_cycle = BillingCycle.arel_table
    localpool = Group::Base.arel_table

    # workaround to produce false always
    return billing_cycle[:id].eq(billing_cycle[:id]).not if user.nil?

    # assume all IDs are globally unique
    sqls = [
      User.roles_query(user, admin: nil),
      User.roles_query(user, manager: billing_cycle[:localpool_id])
    ]
    sqls = sqls.collect{|s| s.project(1).exists}
    sqls[0].or(sqls[1])
  end

  scope :readable_by, -> (user) do
    where(readable_by_query(user))
  end

  def validate_invariants
    if begin_date >= end_date
      errors.add(:end_date, "must be larger than begin_date" )
    end
  end

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

  def create_regular_billings(accounting_year)
    all_accounted_energies = Buzzn::Localpool::ReadingCalculation.get_all_energy_in_localpool(self.localpool, self.begin_date, self.end_date, accounting_year)
    result = []
    all_accounted_energies.accounted_energies.each do |accounted_energy|
      if ![Buzzn::AccountedEnergy::CONSUMPTION_LSN_FULL_EEG,
           Buzzn::AccountedEnergy::CONSUMPTION_LSN_REDUCED_EEG].include?(accounted_energy.label)
        next
      end
      energy_consumption_kWh = accounted_energy.value / 1000000.0
      contract = accounted_energy.first_reading.register.contracts.at(accounted_energy.first_reading.timestamp.to_date).first
      tariff = contract.tariffs.at(accounted_energy.first_reading.timestamp.to_date).first
      count_months = Buzzn::Localpool::ReadingCalculation.timespan_in_months(accounted_energy.first_reading.timestamp, accounted_energy.last_reading.timestamp)
      total_price_cents = tariff.baseprice_cents_per_month * count_months
      prepayments = contract.payments.in_year(accounting_year).by_source(Contract::Payment::TRANSFERRED)
      prepayments_cents = 0
      prepayments.each do |prepayment|
        prepayments_cents += prepayment.price_cents
      end
      billing = Billing.create!(status: Billing::OPEN,
                                billing_cycle: self,
                                localpool_power_taker_contract: contract,
                                start_reading_id: accounted_energy.first_reading.id,
                                end_reading_id: accounted_energy.last_reading.id,
                                device_change_reading_1_id: accounted_energy.device_change_reading_1.nil? ? nil : accounted_energy.device_change_reading_1.id,
                                device_change_reading_2_id: accounted_energy.device_change_reading_2.nil? ? nil : accounted_energy.device_change_reading_2.id,
                                total_energy_consumption_kWh: energy_consumption_kWh.to_i,
                                total_price_cents: total_price_cents,
                                prepayments_cents: prepayments_cents,
                                receivables_cents: total_price_cents - prepayments_cents)
      result << billing
    end
    return result
  end
end