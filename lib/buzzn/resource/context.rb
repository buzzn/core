require 'dry-initializer'

module Buzzn::Resource
  class Context

    extend Dry::Initializer

    param :current_user
    param :permissions
    param :current_roles, default: proc {
      roles = [Role::ANONYMOUS]
      roles += current_user.unbound_rolenames if current_user
      roles
    }

    def method_missing(method, *args)
      if permissions.respond_to?(method)
        Context.new(current_user, permissions.send(method), current_roles)
      else
        super
      end
    end

    def respond_to?(method)
      super || permissions.respond_to?(method)
    end

    def to_h
      self.class.dry_initializer.attributes(self)
    end

  end
end
