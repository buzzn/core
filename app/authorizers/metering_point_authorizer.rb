class MeteringPointAuthorizer < ApplicationAuthorizer

  def updatable_by?(user)
    user.has_role? :manager, resource.location
  end

  def deletable_by?(user)
    user.has_role? :manager, resource.location
  end

  def readable_by?(user)
    resource.metering_point_users.first.user.friend?(user) || resource.metering_point_users.first.user == user
    #resource.metering_point_users.first can be nil
  end


end