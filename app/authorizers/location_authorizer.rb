class LocationAuthorizer < ApplicationAuthorizer

  def updatable_by?(user)
    user.has_role? :manager, resource
  end

  def deletable_by?(user)
    user.has_role? :manager, resource
  end

end