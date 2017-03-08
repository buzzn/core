class Contract::LocalpoolProcessing < Contract::Base

  def self.new(*args)
    super
    contractor = Organization.buzzn_systems
  end

  belongs_to :localpool, class_name: Group::Localpool

  validates :localpool, presence: true
  validates :first_master_uid, presence: true
  validates :second_master_uid, presence: false
  validates :begin_date, presence: true

  def validate_invariants
    super
    if contractor
      errors.add(:contractor, MUST_BE_BUZZN_SYSTEMS) unless contractor == Organization.buzzn_systems
    end
  end

end
