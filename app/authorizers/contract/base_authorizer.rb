class Contract::BaseAuthorizer < ApplicationAuthorizer

  def self.creatable_by?(user)
    false # all needs to go through the ContractFactory, and
          # each Contract subclass needs to decide
  end

  def readable_by?(user)
    # uses scope Contract.readable_by(user)
    readable?(Contract::Base, user)
  end

  def updatable_by?(user)
    User.any_role?(user, admin: nil, manager: _resources)
  end

  def deletable_by?(user)
    User.any_role?(user, admin: nil, manager: _resources)
  end

  private

  def _resources
    resources = []
    if resource.respond_to? :register
      resources << resource.register
      resources << resource.register.group if resource.register
    end
    resources << resource.localpool if resource.respond_to? :localpool
    resources.compact!
  end
end
