class ContractAuthorizer < ApplicationAuthorizer

  def self.creatable_by?(user)
    false # all needs to go through the ContractFactory, and
          # each Contract subclass needs to decide
  end

  def readable_by?(user)
    # uses scope Contract.readable_by(user)
    readable?(Contract, user)
  end

  def updatable_by?(user)
    User.any_role?(user, admin: nil, manager: _resources)
  end

  def deletable_by?(user)
    User.any_role?(user, admin: nil, manager: _resources)
  end

  private

  def _resources
    resources = [resource.register, resource.localpool]
    resources << resource.register.group if resource.register
    resources.compact!
  end
end
