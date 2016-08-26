class MeteringPointAuthorizer < ApplicationAuthorizer

  def self.creatable_by?(user)
    !!user
  end

  def readable_by?(user, variant = nil)
    case variant
    when :meter
      User.any_role?(user, manager: resource)
    when NilClass
      # uses scope MeteringPoint.readable_by(user)
      readable?(MeteringPoint, user)
      # resource.readable_by_world? ||
      #   (!resource.group.nil? && (resource.group.updatable_by?(user) || resource.group.readable_by?(user))) ||
      #   (!!user && (resource.readable_by_community? ||
      #               user.has_role?(:member, resource) ||
      #               user.has_role?(:manager, resource) ||
      #               (resource.readable_by_friends? && resource.managers.map(&:friends).flatten.uniq.include?(user)) ||
      #               (!resource.existing_group_request.nil? && user.can_update?(resource.existing_group_request.group)) ||
      #               user.has_role?(:admin)))
    else
      raise 'wrong argument'
    end
  end

  def updatable_by?(user, options = {})
    case options
    when :members
      User.any_role?(user, admin: nil, manager: resource, member: resource)
    when Hash
      if options.empty?
        User.any_role?(user, admin: nil, manager: resource)
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
    User.any_role?(user, admin: nil, manager: resource)
  end

end
