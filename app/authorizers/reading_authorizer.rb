class ReadingAuthorizer < ApplicationAuthorizer

  def creatable_by?(user)
    resource.meter.creatable_by?(user)
  end

  def readable_by?(user)
    resource.meter.readable_by?(user)
  end

  def updatable_by?(user)
    resource.meter.updatable_by?(user)
  end

  def deletable_by?(user)
    resource.meter.deletable_by?(user)
  end

end
