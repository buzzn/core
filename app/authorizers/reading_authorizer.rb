class ReadingAuthorizer < ApplicationAuthorizer

  def self.creatable_by?(user, meter)
    !!user && (meter.updatable_by?(user) ||
               user.has_role?(:admin))
  end

  def readable_by?(user)
    !!user && (resource.meter_id && resource.meter.readable_by?(user) ||
               user.has_role?(:admin))
  end

  def updatable_by?(user)
    false
  end

  def deletable_by?(user)
    false
  end

end
