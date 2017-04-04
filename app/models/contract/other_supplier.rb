module Contract
  class OtherSupplier < Contract::LocalpoolPowerTaker

    def self.new(*args)
      a = super
      # HACK to fix the problem that the type gets not set by AR
      a.type ||= a.class.to_s
      a
    end

    def validate_invariants
      super
      if contractor
        if contractor == Organization.buzzn_energy
          errors.add(:contractor, MUST_NOT_BE_BUZZN)
        elsif contractor == Organization.buzzn_systems
          errors.add(:contractor, MUST_NOT_BE_BUZZN_SYSTEMS)
        end
      end
    end
  end
end