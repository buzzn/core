module Contract
  class MeteringPointOperator < Localpool

    def self.new(*args)
      a = super
      # HACK to fix the problem that the type gets not set by AR
      a.type ||= a.class.to_s
      a
    end

    belongs_to :localpool, class_name: Group::Localpool

    belongs_to :register, class_name: Register::Base

    validates :register, presence: false
    validates :localpool, presence: false
    validates :metering_point_operator_name, presence: true

    def validate_invariants
      super
      if localpool && register
        errors.add(:localpool, CAN_NOT_BE_PRESENT + Register::Base.to_s)
        errors.add(:register, CAN_NOT_BE_PRESENT + Group::Localpool.to_s)
      end
      if localpool.nil? && register.nil?
        errors.add(:localpool, IS_MISSING)
        errors.add(:register, IS_MISSING)
      end
    end
  end
end
