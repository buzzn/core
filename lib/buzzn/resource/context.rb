module Buzzn::Resource
  class Context
    extend Dry::Initializer

    param :current_user
    param :current_roles
    param :permissions

    def method_missing(method, *args)
      if permissions.respond_to?(method)
        Context.new(current_user, current_roles, permissions.send(method))
      else
        super
      end
    end

    def respond_to?(method)
      super || permissions.respond_to?(method)
    end

    def to_h
      @__options__
    end
  end
end
