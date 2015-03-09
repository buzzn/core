class AddressAuthorizer < ApplicationAuthorizer

  def self.creatable_by?(user)
    true
  end

  def readable_by?(user)
    user.has_role?(:admin) ||
    user.has_role?(:manager, resource.metering_point) ||
    User.with_role(:manager, resource.metering_point).first.friend?(user)
  end

  def updatable_by?(user)
     user.has_role?(:admin) ||
     user.has_role?(:manager, resource.metering_point)
  end

  def deletable_by?(user)
    user.has_role?(:admin) ||
    user.has_role?(:manager, resource.metering_point)
  end

end
