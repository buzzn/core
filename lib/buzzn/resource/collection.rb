require_relative 'context'
require 'ruby_regex'

module Buzzn::Resource
  class Collection

    include Enumerable

    attr_reader :current_user, :permisions, :objects, :instance_class

    def initialize(objects, to_resource_method, current_user, unbound_roles, permissions, clazz = nil)
      @current_user = current_user
      @unbound_roles = unbound_roles
      @permissions = permissions
      @objects = objects
      @to_resource = to_resource_method
      @instance_class = clazz
      @meta = {}
    end

    def context
      Context.new(@current_user, @unbound_roles, @permissions)
    end

    def current_roles(uid)
      @unbound_roles | (@current_user ? @current_user.uids_to_rolenames.fetch(uid, []) : [])
    end

    def each(&block)
      @objects.each do |model|
        block.call(@to_resource.call(@current_user, current_roles(uid(model)),
                                     @permissions, model, @instance_class))
      end
    end

    def filter(query)
      # FIXME Collection should be immutable !
      @objects = @objects.filter(query)
      self
    end

    def retrieve_with_slug(id)
      if id =~ /^[0-9]+$/
        do_retrieve(id, id: id)
      else
        do_retrieve(id, slug: id)
      end
    end

    def retrieve(id)
      do_retrieve(id, id: id)
    end

    def retrieve_or_nil(id)
      do_retrieve_or_nil(id, id: id)
    end

    def do_retrieve_or_nil(id, *args)
      if result = @objects.where(*args).first
        @to_resource.call(@current_user,
                          current_roles("#{clazz}:#{id}"),
                          @permissions, result, @instance_class)
      end
    end

    def do_retrieve(id, *args)
      if result = do_retrieve_or_nil(id, *args)
        result
      elsif clazz && clazz.where(*args).size > 0
        raise Buzzn::PermissionDenied.new(clazz.where(*args).first, :retrieve, @current_user)
      else
        raise Buzzn::RecordNotFound.new(clazz, id, @current_user)
      end
    end
    private :do_retrieve

    def to_a
      collect { |i| i }
    end
    alias :to_ary :to_a

    def size
      @objects.size
    end

    def createable?
      allowed?(:create)
    end

    def any_roles
      (collect { |a| a.current_roles }.flatten | @unbound_roles).uniq
    end

    def allowed?(method)
      (@permissions.send(method) & any_roles).size > 0
    end

    def []=(k, v)
      @meta[k] = v
    end

    def to_json(options = {})
      json = ''
      json(json, options.fetch(:include, {}))
      json
    end

    def json(json, includes)
      cache = {}
      meta = false
      @meta.each do |k, v|
        if ! meta
          meta = true
        else
          json << ','
        end
        # TODO case v.is_a? Hash
        json << '{"' << k.to_s << '":' << v.to_json
      end
      json <<
        if meta
          ',"array":['
        else
          '{"array":['
        end
      first = true
      @objects.each do |model|
        if m = cache[model.class]
          m.instance_variable_set(:@object, model)
          m.instance_variable_set(:@current_roles, current_roles(uid(model)))
        else
          m = @to_resource.call(@current_user, current_roles(uid(model)),
                                @permissions, model, @instance_class)
          cache[model.class] = m
        end
        if first
          first = false
        else
          json << ','
        end
        m.json(json, includes)
      end
      json << ']}'
      json
    end

    private

    def clazz
      @clazz ||= @objects.class.to_s.sub(/::ActiveRecord_.*/, '').safe_constantize
      @clazz ||= @instance_class && @instance_class.model
    end

    def uid(model)
      "#{model.class}:#{model.id}"
    end

  end
end
