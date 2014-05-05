class MeteringPointAuthorizer < ApplicationAuthorizer

  def updatable_by?(user)
    user.has_role? :manager, resource.location
  end

  def deletable_by?(user)
    user.has_role? :manager, resource.location
  end


end