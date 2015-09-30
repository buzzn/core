class MeteringPointAuthorizer < ApplicationAuthorizer

  def self.creatable_by?(user)
    true
  end

  def readable_by?(user)
    !user.nil? &&
    (user.has_role?(:admin) ||
    user.has_role?(:manager, resource) ||
    resource.users.include?(user) ||
    resource.readable_by_world? ||
    resource.readable != 'me' ||
    (resource.readable_by_friends? && User.with_role(:manager, resource).first.friend?(user)) ||
    resource.output? ||
    (!resource.group.nil? && user.can_update?(resource.group)) ||
    (!resource.existing_group_request.nil? && user.can_update?(resource.existing_group_request.group))
    )
  end

  def updatable_by?(user, options = {})
    if options.empty?
      user.has_role?(:admin) ||
      user.has_role?(:manager, resource)
    else
      if options[:action] == 'edit_devices' || options[:action] == 'edit_users'
        user.has_role?(:admin) ||
        user.has_role?(:manager, resource) ||
        resource.users.include?(user)
      end
    end
  end

  def deletable_by?(user)
    user.has_role?(:admin) ||
    user.has_role?(:manager, resource)
  end

end