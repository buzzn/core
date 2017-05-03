class PriceAuthorizer < ApplicationAuthorizer

  def self.creatable_by?(user, localpool)
    localpool.is_a?(Group::Localpool) ? localpool.updatable_by?(user) : false
  end

  def readable_by?(user)
    # uses scope Price.readable_by(user)
    readable?(Price, user)
  end

  def updatable_by?(user)
    resource.localpool && resource.localpool.updatable_by?(user)
  end

  def deletable_by?(user)
    resource.localpool && resource.localpool.updatable_by?(user)
  end
end