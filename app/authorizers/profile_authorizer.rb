class ProfileAuthorizer < ApplicationAuthorizer

  def self.creatable_by?(user)
    User.admin?(user)
  end

  def readable_by?(user)
    # uses scope Profile.readable_by(user)
    readable?(Profile, user)
  end

  def updatable_by?(user)
    (user == resource.user && !!user) || User.admin?(user)
  end

  def deletable_by?(user)
    User.admin?(user)
  end

end
