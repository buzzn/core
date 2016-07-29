class ContractAuthorizer < ApplicationAuthorizer

  def self.creatable_by?(user)
    !! user
  end

  def readable_by?(user)
    old = !!user && (user.has_role?(:manager, resource.metering_point) ||
                     user.has_role?(:manager, resource.group) ||
                     user.has_role?(:admin))
    ng = Contract.readable_by(user).where('contracts.id = ?', resource.id).select('id').size == 1
    if old != ng
      warn 'legacy query is different from sql query on device#readable_by'
      old
    else
      ng
    end
  end

  def updatable_by?(user)
    user && (user.has_role?(:manager, resource.metering_point) ||
             user.has_role?(:manager, resource.group) ||
             user.has_role?(:admin))
  end

  def deletable_by?(user)
    user && (user.has_role?(:manager, resource.metering_point) ||
             user.has_role?(:manager, resource.group) ||
             user.has_role?(:admin))
  end

end
