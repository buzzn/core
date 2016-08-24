class AddressAuthorizer < ApplicationAuthorizer

  def self.creatable_by?(user)
    true
  end

  def readable_by?(user)
    resource.metering_point.readable_by_friends? ||
    user.has_role?(:manager, resource.metering_point) ||
    User.with_role(:manager, resource.metering_point).first.friend?(user) ||
    user.has_role?(:admin)
  end

  def updatable_by?(user)
    User.any_role?(user, admin: nil, manager: resource)
  end

  def deletable_by?(user)
    User.any_role?(user, admin: nil, manager: resource)
  end

end
