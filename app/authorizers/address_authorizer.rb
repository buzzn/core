class AddressAuthorizer < ApplicationAuthorizer

  def self.creatable_by?(user)
    true
  end

  def readable_by?(user)
    # uses scope Address.readable_by(user)
    readable?(Address, user)
  end

  def updatable_by?(user)
    User.any_role?(user, admin: nil, manager: resource)
  end

  def deletable_by?(user)
    User.any_role?(user, admin: nil, manager: resource)
  end

end
