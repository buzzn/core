require 'dry-initializer'
require_relative '../permissions/no_permission'

module Buzzn::Resource
  class SecurityContext

    extend Dry::Initializer

    param :current_user, default: proc { nil }
    param :permissions, default: proc { NoPermission }
    param :current_roles, default: proc {
      roles = ['ANONYMOUS'] #[Role::ANONYMOUS]
      roles += current_user.unbound_rolenames if current_user
      roles
    }

    def method_missing(method, *args)
      if permissions.respond_to?(method)
        self.class.new(current_user, permissions.send(method), current_roles)
      else
        super
      end
    end

    def respond_to_missing?(method, *args)
      super || permissions.respond_to?(method)
    end

    def to_h
      self.class.dry_initializer.attributes(self)
    end

  end
end
