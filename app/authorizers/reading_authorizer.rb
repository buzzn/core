class ReadingAuthorizer < ApplicationAuthorizer

  def creatable_by?(user)
    resource.meter.creatable_by?(user) ||
    user.has_role?(:admin)
  end

  def readable_by?(user)
    resource.meter.readable_by?(user) ||
    user.has_role?(:admin)
  end

  def updatable_by?(user)
    resource.meter.updatable_by?(user) ||
    user.has_role?(:admin)
  end

  def deletable_by?(user)
    resource.meter.deletable_by?(user) ||
    user.has_role?(:admin)
  end

end
