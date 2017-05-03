class BillingCycleAuthorizer < ApplicationAuthorizer

  def self.creatable_by?(user, localpool)
    localpool.is_a?(Group::Localpool) ? localpool.updatable_by?(user) : false
  end

  def readable_by?(user)
    # uses scope BillingCycle.readable_by(user)
    readable?(BillingCycle, user)
  end

  def updatable_by?(user)
    resource.localpool && resource.localpool.updatable_by?(user)
  end

  def deletable_by?(user)
    resource.localpool && resource.localpool.updatable_by?(user)
  end
end