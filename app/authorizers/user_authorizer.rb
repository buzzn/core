class UserAuthorizer < ApplicationAuthorizer

  def self.creatable_by?(user)
    User.admin?(user)
  end

  def readable_by?(user)
    # uses scope User.readable_by(user)
    readable?(User, user)
  end

  def updatable_by?(user)
    # TODO what is the manager of a user ?
    user == resource || User.any_role?(user, admin: nil, manager: resource)
  end

  def deletable_by?(user)
    user == resource || User.admin?(user)
  end

end
