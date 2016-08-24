class GroupAuthorizer < ApplicationAuthorizer

  def self.creatable_by?(user)
    MeteringPoint.editable_by_user(user).outputs.without_group.any?
  end

  def readable_by?(user)
    resource.readable_by_world? ||
      !!user && (resource.readable_by_community? ||
                 User.any_role?(user, admin: nil, manager: resource) ||
                 resource.readable_by_friends? && resource.managers.map(&:friends).flatten.uniq.include?(user))
  end

  def updatable_by?(user)
    User.any_role?(user, admin: nil, manager: resource)
  end

  def deletable_by?(user)
    User.any_role?(user, admin: nil, manager: resource)
  end

end
