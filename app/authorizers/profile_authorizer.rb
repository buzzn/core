class ProfileAuthorizer < ApplicationAuthorizer

  def readable_by?(user)
    user.has_role?(:admin) || resource.user.friend?(user) || resource.user == user
  end


end