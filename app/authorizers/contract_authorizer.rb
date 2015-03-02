class ContractAuthorizer < ApplicationAuthorizer

  def updatable_by?(user)
    user.has_role?(:admin) || user.has_role?(:manager, resource.metering_point)
  end

  def deletable_by?(user)
    user.has_role?(:admin) || user.has_role?(:manager, resource.metering_point)
  end

end