class OrganizationAuthorizer < ApplicationAuthorizer

  def self.creatable_by?(user)
    user && user.has_role?(:admin)
  end

  def readable_by?(user)
    Organization.readable_by(user).where('organizations.id = ?', resource.id).select('id').size == 1
  end

  def updatable_by?(user)
    user && (user.has_role?(:admin) || user.has_role?(:manager, resource))
  end

  def deletable_by?(user)
    user && user.has_role?(:admin)
  end

end
