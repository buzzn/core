module Buzzn::Resource
  class Collection
    include Enumerable

    def initialize(enum, to_resource_method, current_user, unbound_roles, permissions, clazz = nil)
      @current_user = current_user
      @unbound_roles = unbound_roles
      @permissions = permissions
      @enum = enum
      @to_resource = to_resource_method
      @class = clazz
    end

    def current_roles(id)
      @unbound_roles | (@current_user ? @current_user.uuids_to_rolenames.fetch(id, []) : [])
    end

    def each(&block)
      @enum.each do |model|
        block.call(@to_resource.call(@current_user, current_roles(model.id),
                                     @permissions, model, @class))
      end
    end

    def retrieve(id)
      if result = @enum.where(id: id).first
        @to_resource.call(@current_user, current_roles(id),
                          @permissions, result, @class)
      else
        clazz = @enum.class.to_s.sub(/::ActiveRecord_.*/,'').safe_constantize
        clazz ||= @class && @class.model
        clazz ||= @enum.first.class if @enum.first
        if clazz && clazz.exists?(id)
          raise Buzzn::PermissionDenied.new(clazz.find(id), :retrieve, @current_user)
        else
          raise Buzzn::RecordNotFound.create(clazz, id, @current_user)
        end
      end
    end

    def to_a
      collect { |i| i }
    end
    alias :to_ary :to_a

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
