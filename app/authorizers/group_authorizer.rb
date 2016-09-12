class GroupAuthorizer < ApplicationAuthorizer

  def self.creatable_by?(user)
    MeteringPoint.editable_by_user(user).outputs.without_group.any?
  end

  def readable_by?(user)
    # uses scope Group.readable_by(user)
    readable?(Group, user)
  end

  def updatable_by?(user, variant = nil)
    case variant
    when :replace_managers
      !!user && (resource.managers.include?(user) || user.has_role?(:admin))
    when User
      !!user && (variant == user || user.has_role?(:admin))
    else
      User.any_role?(user, admin: nil, manager: resource)
    end
  end

  def deletable_by?(user)
    User.any_role?(user, admin: nil, manager: resource)
  end

end
