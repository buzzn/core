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
      @meta = {}
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

    def retrieve_with_slug(id)
      if id =~ /[a-f0-9]{8}-[a-f0-9]{4}-4[a-f0-9]{3}-[89aAbB][a-f0-9]{3}-[a-f0-9]{12}/
        do_retrieve(id, 'id=? or slug=?', id, id.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, ''))
      else
        do_retrieve(id, slug: id)
      end
    end

    def retrieve(id)
      do_retrieve(id, id: id)
    end

    def do_retrieve(id, *args)
      if result = @enum.where(*args).first
        @to_resource.call(@current_user, current_roles(id),
                          @permissions, result, @class)
      else
        clazz = @enum.class.to_s.sub(/::ActiveRecord_.*/,'').safe_constantize
        clazz ||= @class && @class.model
        clazz ||= @enum.first.class if @enum.first
        if clazz && clazz.where(*args).size > 0
          raise Buzzn::PermissionDenied.new(clazz.where(*args).first, :retrieve, @current_user)
        else
          raise Buzzn::RecordNotFound.create(clazz, id, @current_user)
        end
      end
    end
    private :do_retrieve
        
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
      @enum.each do |model|
        if m = cache[model.class]
          m.instance_variable_set(:@object, model)
          m.instance_variable_set(:@current_roles, current_roles(model.id))
        else
          m = @to_resource.call(@current_user, current_roles(model.id),
                                @permissions, model, @class)
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
  end
end
