class MeterAuthorizer < ApplicationAuthorizer

  def self.creatable_by?(user)
    !!user
  end

  def readable_by?(user)
    !!user && (user.has_role?(:manager, resource) ||
               user.has_role?(:admin))
  end

  def updatable_by?(user)
     !!user && (user.has_role?(:manager, resource) ||
                user.has_role?(:admin))
  end

  def deletable_by?(user)
    !!user && (user.has_role?(:manager, resource) ||
               user.has_role?(:admin))
  end

end
