module Contract
  class LocalpoolPowerTaker < Localpool

    def self.new(*args)
      a = super
      # HACK to fix the problem that the type gets not set by AR
      a.type ||= a.class.to_s
      a
    end

    belongs_to :register, class_name: Register::Input

    validates :register, presence: true
    validates :forecast_kwh_pa, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
    validates :renewable_energy_law_taxation, presence: true, inclusion: {in: Contract::RenewableEnergyLawTaxation.all}
    validates :third_party_billing_number, presence: false
    validates :third_party_renter_number, presence: false

    def validate_invariants
      super
      if !register.group.is_a?(Group::Localpool)
        errors.add(:register, MUST_BELONG_TO_LOCALPOOL)
      end
    end
  end
end
