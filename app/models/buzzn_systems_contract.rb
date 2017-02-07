class BuzznSystemsContract < Contract

  validates :begin_date, presence: true

  def initialize(*args)
    super
    self.contractor = Organization.buzzn_systems
  end

  def validate_invariants
    super
    if contractor
      errors.add(:contractor, MUST_BE_BUZZN_SYSTEMS) unless contractor == Organization.buzzn_systems
    end
  end
end
