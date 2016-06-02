class ContractAuthorizer < ApplicationAuthorizer

  def self.creatable_by?(user)
    true
  end

  def readable_by?(user)
    user.has_role?(:manager, resource.metering_point) ||
    user.has_role?(:manager, resource.group) ||
    user.has_role?(:admin)
  end

  def updatable_by?(user)
    user.has_role?(:manager, resource.metering_point) ||
    user.has_role?(:manager, resource.group) ||
    user.has_role?(:admin)
  end

  def deletable_by?(user)
    user.has_role?(:manager, resource.metering_point) ||
    user.has_role?(:manager, resource.group) ||
    user.has_role?(:admin)
  end

end
