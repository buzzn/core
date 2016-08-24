class ContractingPartyAuthorizer < ApplicationAuthorizer

  def self.creatable_by?(user)
    true
  end

  def readable_by?(user)
    # TODO ???? why does a ContractingParty needs to have members
    User.with_role(:member, resource) ||
    user.has_role?(:admin)
  end

  def updatable_by?(user)
    # TODO ???? why does a ContractingParty needs to have members
     User.with_role(:member, resource) ||
     user.has_role?(:admin)
  end

  def deletable_by?(user)
    # TODO ???? why does a ContractingParty needs to have members
    User.with_role(:member, resource) ||
    user.has_role?(:admin)
  end

end
