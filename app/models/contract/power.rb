module Contract
  class Power < Base

    validates :feedback, presence: false
    validates :attention_by, presence: false
    validates :forecast_kwh_pa, numericality: { only_integer: true, greater_than: 0 }


    def initialize(*args)
      super
      self.contractor = Organization.buzzn_energy
    end

    def validate_invariants
      super
      errors.add(:contractor, MUST_BE_BUZZN) if contractor && contractor.buzzn_energy?
    end
  end
end
