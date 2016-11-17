class ContractAuthorizer < ApplicationAuthorizer

  def self.creatable_by?(user)
    !!user
  end

  def readable_by?(user)
    # uses scope Contract.readable_by(user)
    readable?(Contract, user)
  end

  def updatable_by?(user)
    User.any_role?(user, admin: nil, manager: [resource.register, resource.group])
  end

  def deletable_by?(user)
    User.any_role?(user, admin: nil, manager: [resource.register, resource.group])
  end

end
