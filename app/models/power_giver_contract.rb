class PowerGiverContract < PowerContract

  def self.new(*args)
    super
  end

  belongs_to :register

  validates :register, presence: true
  validates :confirm_pricing_model, presence: true
  validates :begin_date, presence: true
  validates :distibution_system_operator, presence: false

  def validate_invariants
    super
    if register
      errors.add(:register, 'needs to have `out` mode') if register.mode != 'out'
    end
    errors.add(:confirm_pricing_model, MUST_BE_TRUE) unless confirm_pricing_model
  end
end
