class ReadingAuthorizer < ApplicationAuthorizer

  def creatable_by?(user)
    resource.metering_point.creatable_by?(user)
  end

  def readable_by?(user)
    resource.metering_point.readable_by?(user)
  end

  def updatable_by?(user)
    resource.metering_point.updatable_by?(user)
  end

  def deletable_by?(user)
    resource.metering_point.deletable_by?(user)
  end

end
