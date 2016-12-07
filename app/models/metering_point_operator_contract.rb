class MeteringPointOperatorContract < Contract

  def self.new(*args)
    super
  end

  belongs_to :localpool, class_name: 'Group'
  belongs_to :register, class_name: Register::Base

  validates :register, presence: false
  validates :localpool, presence: false
  validates :begin_date, presence: true
  validates :metering_point_operator_name, presence: true

  def validate_invariants
    super
    if localpool && register
      errors.add(:localpool, CAN_NOT_BE_PRESENT + Register::Base.to_s)
      errors.add(:register, CAN_NOT_BE_PRESENT + 'Localpool') #TODO use class constant for type-safety
    end
    if localpool.nil? && register.nil?
      errors.add(:localpool, IS_MISSING)
      errors.add(:register, IS_MISSING)
    end
    if status != WAITING
      errors.add(:contractor, CAN_NOT_BELONG_TO_DUMMY) if contractor == Organization.dummy.contracting_party
    end
  end
end
