class MeterAuthorizer < ApplicationAuthorizer

  def self.creatable_by?(user)
    true
  end

  def updatable_by?(user)
    user.has_role? :manager, resource.metering_point.location
  end

  def deletable_by?(user)
    user.has_role? :manager, resource.metering_point.location
  end


end