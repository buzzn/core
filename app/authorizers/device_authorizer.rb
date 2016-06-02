class DeviceAuthorizer < ApplicationAuthorizer

  def self.creatable_by?(user)
    true
  end

  def readable_by?(user)
    (resource.output? && resource.metering_point && resource.metering_point.group) ||
    user.has_role?(:manager, resource) ||
    User.with_role(:manager, resource).first.friend?(user) ||
    user.has_role?(:admin)
  end

  def updatable_by?(user)
    user.has_role?(:manager, resource) ||
    user.has_role?(:admin)
  end

  def deletable_by?(user)
    user.has_role?(:manager, resource) ||
    user.has_role?(:admin)
  end

end
