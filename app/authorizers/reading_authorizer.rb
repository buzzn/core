class ReadingAuthorizer < ApplicationAuthorizer

  def self.creatable_by?(user, meter)
    meter.updatable_by?(user)
  end

  def readable_by?(user)
    meter = resource.meter
    if meter
      meter.readable_by?(user)
    else
      false
    end
  end

  def updatable_by?(user)
    false
  end

  def deletable_by?(user)
    false
  end

end
