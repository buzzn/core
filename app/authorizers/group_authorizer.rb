class GroupAuthorizer < ApplicationAuthorizer

  def self.creatable_by?(user)
    MeteringPoint.editable_by_user(user).outputs.without_group.any?
  end

  def readable_by?(user)
    resource.readable_by_world? ||
      (user && (resource.readable_by_community? ||
                resource.members.include?(user) ||
                user.has_role?(:manager, resource) ||
                resource.readable_by_friends? && resource.managers.map(&:friends).flatten.uniq.include?(user) ||
                user.has_role?(:admin)))
  end

  def updatable_by?(user)
    user.has_role?(:manager, resource) ||
    user.has_role?(:admin)
  end

  def deletable_by?(user)
    user.has_role?(:manager, resource) ||
    user.has_role?(:admin)
  end

end
