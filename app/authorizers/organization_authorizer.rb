class OrganizationAuthorizer < ApplicationAuthorizer

  def self.creatable_by?(user)
    User.admin?(user)
  end

  def readable_by?(user)
    readable?(Organization, user)
  end

  def updatable_by?(user)
    User.any_role?(user, admin: nil, manager: resource)
  end

  def deletable_by?(user)
    User.admin?(user)
  end

end
