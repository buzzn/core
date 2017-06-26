module Contract
  class PowerGiver < Power

    def self.new(*args)
      super
    end

    belongs_to :register, class_name: Register::Output

    validates :register, presence: true
    validates :confirm_pricing_model, presence: true
    validates :begin_date, presence: true
    validates :distibution_system_operator, presence: false

    def validate_invariants
      super
      errors.add(:confirm_pricing_model, MUST_BE_TRUE) unless confirm_pricing_model
    end
  end
end
