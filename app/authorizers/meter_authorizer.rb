class MeterAuthorizer < ApplicationAuthorizer

  def self.creatable_by?(user)
    true
  end

  def readable_by?(user)
    user.has_role?(:admin) ||
    user.has_role?(:manager, resource.metering_points.first) ||
    User.with_role(:manager, resource.metering_points.first).first.friend?(user)
  end

  def updatable_by?(user)
     user.has_role?(:admin) ||
     user.has_role?(:manager, resource.metering_points.first)
  end

  def deletable_by?(user)
    user.has_role?(:admin) ||
    user.has_role?(:manager, resource.metering_points.first)
  end

end
