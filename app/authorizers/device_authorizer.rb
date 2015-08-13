class DeviceAuthorizer < ApplicationAuthorizer

  def self.creatable_by?(user)
    true
  end

  def updatable_by?(user)
    user.has_role?(:admin) ||
    user.has_role?(:manager, resource)
  end

  def deletable_by?(user)
    user.has_role?(:admin) ||
    user.has_role?(:manager, resource)
  end

  def readable_by?(user)
    (resource.output? && resource.metering_point && resource.metering_point.group) || user.has_role?(:admin) || user.has_role?(:manager, resource) || User.with_role(:manager, resource).first.friend?(user)
  end
end