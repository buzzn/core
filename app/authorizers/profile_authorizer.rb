class ProfileAuthorizer < ApplicationAuthorizer

  def readable_by?(user)
    resource.user.friend?(user) || resource.user == user
  end


end