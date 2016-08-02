class ProfileAuthorizer < ApplicationAuthorizer

  def self.creatable_by?(user)
    user && user.has_role?(:admin)
  end

  def readable_by?(user)
    resource.readable_by_world? ||
      !!user && (resource.readable_by_community? ||  
                 !!resource.user && resource.user.friend?(user) ||
                 resource.user == user ||
                 user.has_role?(:admin))
  end

  def updatable_by?(user)
    user && (user == resource.user ||
             user.has_role?(:admin))
  end

  def deletable_by?(user)
    user && user.has_role?(:admin)
  end

end
