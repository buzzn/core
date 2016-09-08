class MeterAuthorizer < ApplicationAuthorizer

  def self.creatable_by?(user)
    !!user
  end

  def readable_by?(user)
    # uses scope Meter.readable_by(user)
    readable?(Meter, user)
  end

  def updatable_by?(user)
    readable_by?(user)
  end

  def deletable_by?(user)
    readable_by?(user)
  end

end
