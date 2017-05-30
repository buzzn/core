module Buzzn
  class ResourceCollection
    include Enumerable

    def initialize(enum, to_resource_method, current_user, unbound_roles, permissions)
      @current_user = current_user
      @unbound_roles = unbound_roles
      @permissions = permissions
      @enum = enum
      @to_resource = to_resource_method
    end

    def current_roles(id)
      @unbound_roles | (@current_user ? @current_user.uuids_to_rolenames.fetch(id, []) : [])
    end

    def each(&block)
      @enum.each do |model|
        block.call(@to_resource.call(@current_user, current_roles(model.id),
                                     @permissions, model))
      end
    end

    def retrieve(id)
      if result = @enum.where(id: id).first
        @to_resource.call(@current_user, current_roles(id),
                          @permissions, result)
      else
        p @enum.class.to_s
        clazz = @enum.class.to_s.sub(/::ActiveRecord_.*/,'').safe_constantize
        if clazz && clazz.exists?(id)
          raise Buzzn::PermissionDenied.new(clazz, :retrieve, @current_user)
        else
          raise Buzzn::RecordNotFound.create(clazz, id, @current_user)
        end
      end
    end

    def to_a
      collect { |i| i }
    end

    def size
      @enum.size
    end

    def method_missing(method, *args)
      if @enum.respond_to?(method)
        @enum = @enum.send(method, *args)
        self
      else
        super
      end
    end

    def respond_to?(method)
      @enum.respond_to?(method) || super
    end
  end
end
