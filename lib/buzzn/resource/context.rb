module Buzzn::Resource
  class Context
    extend Dry::Initializer

    param :current_user
    param :current_roles
    param :permissions

    def sub_context(method)
      Context.new(current_user, current_roles, permissions.send(method))
    end
  end
end
