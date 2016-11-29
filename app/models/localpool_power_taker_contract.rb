class LocalpoolPowerTakerContract < BuzznSystemsContract

  def self.new(*args)
    super
  end

  belongs_to :register

  validates :register, presence: true
  validates :forecast_kwh_pa, numericality: { only_integer: true, greater_than: 0 }
  validates :renewable_energy_law_taxation, presence: true
  validates :third_party_billing_number, presence: false
  validates :third_party_renter_number, presence: false

  def validate_invariants
    super
    errors.add(:register, 'needs to have `in` mode') if register.mode != 'in'
    if register.group.nil? || register.group.mode != 'localpool'
      errors.add(:register, MUST_BELONG_TO_LOCALPOOL)
    end
  end
end
