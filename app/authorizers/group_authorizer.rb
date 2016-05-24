class GroupAuthorizer < ApplicationAuthorizer


  def self.creatable_by?(user)
    MeteringPoint.editable_by_user(user).outputs.without_group.any?
  end

  def readable_by?(user)
    resource.readable_by_world? ||
    (user && resource.readable_by_community? ) ||
    resource.members.include?(user) ||
    user.has_role?(:manager, resource) ||
    user.has_role?(:admin) ||
    resource.readable_by_friends? && resource.managers.map(&:friends).flatten.uniq.include?(user)
  end

  def updatable_by?(user)
    user.has_role?(:admin) ||
    user.has_role?(:manager, resource)
  end

  def deletable_by?(user)
    user.has_role?(:admin) ||
    user.has_role?(:manager, resource)
  end

  # def commentable_by?(user)
  #   user_signed_in? #TODO: undefined mehtod user_signed_in? for GroupAuthorizer
  # end


end
