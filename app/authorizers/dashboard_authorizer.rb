class DashboardAuthorizer < ApplicationAuthorizer

  def self.creatable_by?(user)
    true
  end

  def readable_by?(user)
    user == resource.user || User.admin?(user)
  end

  def updatable_by?(user)
    user == resource.user || User.admin?(user)
  end

  def deletable_by?(user)
    user == resource.user || User.admin?(user)
  end

end
