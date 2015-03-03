class GroupAuthorizer < ApplicationAuthorizer


  def self.creatable_by?(user)
    MeteringPoint.by_modes_and_user_without_group(["out", "in_out"], user).any?
  end

  def updatable_by?(user)
    user.has_role?(:admin) ||
    user.has_role?(:manager, resource)
  end

  def deletable_by?(user)
    user.has_role?(:admin) ||
    user.has_role?(:manager, resource)
  end

  def commentable_by?(user)
    user_signed_in? #TODO: undefined mehtod user_signed_in? for GroupAuthorizer
  end


end