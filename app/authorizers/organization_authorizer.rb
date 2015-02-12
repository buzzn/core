class OrganizationAuthorizer < ApplicationAuthorizer

  def readable_by?(user)
    user.has_role?(:admin)
  end

  def updatable_by?(user)
    user.has_role?(:admin)
  end

  def creatable_by?(user)
    user.has_role?(:admin)
  end

  def deletable_by?(user)
    user.has_role?(:admin)
  end

end