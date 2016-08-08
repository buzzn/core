class MeteringPointAuthorizer < ApplicationAuthorizer

  def self.creatable_by?(user)
    !!user
  end

  def readable_by?(user, variant = nil)
    case variant
    when :meter
      !!user && user.has_role?(:manager, resource)
    when NilClass
      resource.readable_by_world? ||
        (!resource.group.nil? && (resource.group.updatable_by?(user) || resource.group.readable_by?(user))) ||
        (!!user && (resource.readable_by_community? ||
                    user.has_role?(:member, resource) ||
                    user.has_role?(:manager, resource) ||
                    (resource.readable_by_friends? && resource.managers.map(&:friends).flatten.uniq.include?(user)) ||
                    (!resource.existing_group_request.nil? && user.can_update?(resource.existing_group_request.group)) ||
                    user.has_role?(:admin)))
    else
      raise 'wrong argument'
    end
  end

  def updatable_by?(user, options = {})
    case options
    when :members
      !!user && (user.has_role?(:manager, resource) ||
                 user.has_role?(:member, resource) ||
                 user.has_role?(:admin))
    when Hash
      if options.empty?
        !!user && (user.has_role?(:manager, resource) ||
                   user.has_role?(:admin))
      else
        if options[:action] == 'edit_devices' || options[:action] == 'edit_users'
          !!user && (user.has_role?(:manager, resource) ||
                     resource.users.include?(user) ||
                     user.has_role?(:admin))
        end
      end
    else
      raise 'wrong argument'
    end
  end

  def deletable_by?(user)
    !!user && (user.has_role?(:manager, resource) ||
               user.has_role?(:admin))
  end

end
