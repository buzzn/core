class UserAuthorizer < ApplicationAuthorizer

  def self.creatable_by?(user)
    user && user.has_role?(:admin)
  end

  def readable_by?(user)
    resource.profile.readable_by?(user)
  end

  def updatable_by?(user)
    # TODO what is the manager of a user ?
    user && (user == resource || user.has_role?(:admin) || user.has_role?(:manager, resource))
  end

  def deletable_by?(user)
    user && (user == resource || user.has_role?(:admin))
  end

end
