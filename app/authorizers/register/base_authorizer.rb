module Register
  class BaseAuthorizer < ApplicationAuthorizer

    def self.creatable_by?(user)
      !!user
    end

    def readable_by?(user, variant = nil)
      args = [user]
      case variant
      when NilClass
        # no extra args
      when :no_group_inheritance
        args << false
      when :group_inheritance
        args << true
      else
        raise 'wrong argument'
      end
      # uses scope Register::Base.readable_by(user)
      readable?(Register::Base, *args) ||
        # TODO get this into Register::Base.readable_by(user)
        (!resource.existing_group_request.nil? && user.can_update?(resource.existing_group_request.group))
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
end
