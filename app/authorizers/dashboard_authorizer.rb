class DashboardAuthorizer < ApplicationAuthorizer

  def readable_by?(user)
    user.has_role?(:admin) ||
    user == resource.user
  end

  def updatable_by?(user)
     user.has_role?(:admin) ||
    user == resource.user
  end

  def deletable_by?(user)
    user.has_role?(:admin) ||
    user == resource.user
  end

end