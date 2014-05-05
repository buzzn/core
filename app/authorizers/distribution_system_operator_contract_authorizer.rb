class DistributionSystemOperatorContractAuthorizer < ApplicationAuthorizer

  def updatable_by?(user)
    user.has_role? :manager, resource.metering_point.location
  end

  def deletable_by?(user)
    user.has_role? :manager, resource.metering_point.location
  end

end