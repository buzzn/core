class ContractAuthorizer < ApplicationAuthorizer

  def self.readable_by?(user)
    true
  end

  def self.creatable_by?(user)
    true
  end

  def updatable_by?(user)
    user.has_role?(:admin) || user.has_role?(:manager, resource.metering_point)
  end

  def deletable_by?(user)
    user.has_role?(:admin) || user.has_role?(:manager, resource.metering_point)
  end

end