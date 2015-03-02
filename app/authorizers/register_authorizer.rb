class RegisterAuthorizer < ApplicationAuthorizer

  def self.creatable_by?(user)
    true
  end

  def readable_by?(user)
    user.has_role?(:admin) ||
    user.has_role?(:manager, resource.metering_point) ||
    user.has_role?(:manager, resource.metering_point.root)
  end

  def updatable_by?(user)
     user.has_role?(:admin) || user.has_role?(:manager, resource.metering_point)
  end

  def deletable_by?(user)
    user.has_role?(:admin) || user.has_role?(:manager, resource.metering_point)
  end


end