class ProfileAuthorizer < ApplicationAuthorizer

  def readable_by?(user)
    user.has_role?(:admin) || resource.user.friend?(user) || resource.user == user
  end

  def updatable_by?(user)
    user == resource.user || user.has_role?(:admin)
  end


end