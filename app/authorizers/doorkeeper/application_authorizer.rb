class Doorkeeper::ApplicationAuthorizer < ApplicationAuthorizer

  def self.creatable_by?(user)
    true
  end

  def readable_by?(user)
    resource.owner == user ||
    user.has_role?(:admin)
  end

  def updatable_by?(user)
    resource.owner == user ||
    user.has_role?(:admin)
  end

  def deletable_by?(user)
    resource.owner == user ||
    user.has_role?(:admin)
  end

end
