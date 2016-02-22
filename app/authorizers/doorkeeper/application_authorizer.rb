class Doorkeeper::ApplicationAuthorizer < ApplicationAuthorizer

  def self.creatable_by?(user)
    true
  end

  def updatable_by?(user)
    user.has_role?(:admin) ||
    resource.owner == user
  end

  def deletable_by?(user)
    user.has_role?(:admin) ||
    resource.owner == user
  end

  def readable_by?(user)
    user.has_role?(:admin) ||
    resource.owner == user
  end

end
