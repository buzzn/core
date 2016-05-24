class MeteringPointAuthorizer < ApplicationAuthorizer

  def self.creatable_by?(user)
    true
  end

  def readable_by?(user)
    resource.readable_by_world? ||
    (user && resource.readable_by_community? ) ||
    user.has_role?(:member, resource) ||
    user.has_role?(:manager, resource) ||
    user.has_role?(:admin) ||
    (resource.readable_by_friends? && resource.managers.map(&:friends).flatten.uniq.include?(user)) ||
    (!resource.group.nil? && user.can_update?(resource.group)) ||
    (!resource.existing_group_request.nil? && user.can_update?(resource.existing_group_request.group))
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