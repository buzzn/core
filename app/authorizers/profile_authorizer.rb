class ProfileAuthorizer < ApplicationAuthorizer

  def readable_by?(user)
    resource.user.friend?(user)
  end

end