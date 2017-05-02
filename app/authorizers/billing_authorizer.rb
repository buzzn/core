class BillingAuthorizer < ApplicationAuthorizer

  def self.creatable_by?(user, billing_cycle)
    billing_cycle.updatable_by?(user)
  end

  def readable_by?(user)
    # uses scope Billing.readable_by(user)
    readable?(Billing, user)
  end

  def updatable_by?(user)
    resource.billing_cycle && resource.billing_cycle.updatable_by?(user)
  end

  def deletable_by?(user)
    resource.billing_cycle && resource.billing_cycle.updatable_by?(user)
  end
end