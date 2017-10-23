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
      errors.add(:contractor, MUST_NOT_BE_BUZZN) if contractor&.buzzn?
    end
  end
end
