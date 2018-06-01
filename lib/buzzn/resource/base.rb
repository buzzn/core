require_relative '../schemas/support/enable_dry_validation'
require_relative 'security_context'

module Buzzn::Resource
  class Base

    include Schemas::Support::DryValidationForResource

    attr_reader :object, :security_context

    class << self

      def attribute_names
        @attribute_names ||=
          begin
            a = []
            if superclass.respond_to?(:attribute_names)
              a += superclass.attribute_names
            end
            a += @attrs if @attrs
            a
          end
      end

      # DSL methods

      def attribute(*attr)
        @attrs ||= []
        @attrs += attr
      end
      alias :attributes :attribute

      def has_many(method, *clazz_and_meta)
        define_method method do
          context = security_context.send(method) rescue raise("missing permission #{method} on #{permissions} used in #{self}")
          objects =
            if block_given?
              yield(object)
            else
              object.send(method)
            end
          all(context, objects, *clazz_and_meta)
        end
      end

      def has_one(method, clazz = nil)
        # deliver nested resource if permissions allow otherwise
        # raise PermissionsDenied or RecordNotFound when not found
        define_method "#{method}!" do
          context = security_context.send(method) rescue raise("missing permission #{method} on #{permissions} used in #{self}")
          result =
            if block_given?
              yield(object)
            else
              object.send(method)
            end
          if allowed?(context.permissions.retrieve)
            if result
              self.class.to_resource(result, context, clazz)
            else
              raise Buzzn::RecordNotFound.new(self.class, method, current_user)
            end
          else
            new_clazz = clazz || self.class.send(:find_resource_class,
                                                 result.class)
            raise Buzzn::PermissionDenied.new(new_clazz, :retrieve, current_user)
          end
        end

        # deliver result if permissions allow otherwise nil
        define_method method do
          context = security_context.send(method) rescue raise("missing permission #{method} on #{permissions} used in #{self}")
          if allowed?(context.permissions.retrieve) && (result = block_given? ? yield(object) : object.send(method))
            new_clazz = clazz || self.class.send(:find_resource_class,
                                                 result.class)
            self.class.to_resource(result, context, new_clazz)
          end
        end
      end

      def model(model = nil)
        @model = model if model
        m = @model
        if m.nil? && superclass.respond_to?(:model)
          m = superclass.model
        end
        raise 'model not set' unless m
        m
      end

      def abstract
        @abstract = true if @abstract.nil?
        @abstract
      end

      def abstract?
        @abstract == true
      end

      def all(user, clazz = nil)
        permissions = (self::Permission rescue NoPermission)
        context = SecurityContext.new(user, permissions)
        objects = filter_all_allowed(context, filter_all(model.all))
        to_collection(objects, context, clazz || self)
      end

      def to_resource(instance, security_context, clazz = nil)
        clazz ||= find_resource_class(instance.class)
        raise "could not find Resource class for #{instance.class}" if clazz.nil?
        raise "could not instantiate Resource class for #{instance.class} as #{clazz} is abstract" if clazz.abstract?
        clazz.new(instance, security_context)
      end

      protected

      def filter_all(objects); objects; end

      private

      ANONYMOUS = [Role::ANONYMOUS].freeze

      def filter_all_allowed(security_context, objects)
        perms = security_context.permissions.retrieve
        user = security_context.current_user
        if user.nil?
          if allowed?(ANONYMOUS, perms)
            objects
          else
            objects.where('1=2') # deliver an empty AR relation
          end
        elsif allowed?(ANONYMOUS | security_context.current_roles | user.unbound_rolenames, perms)
          objects
        else
          objects.permitted(user.uids_for(perms)) rescue objects.restricted(user.uids_for(perms))
        end
      end

      def allowed_roles(user, perms)
        return false unless user
        roles = user.unbound_rolenames
        if (roles & perms).empty?
          false
        else
          roles
        end
      end

      def allowed?(roles, perms)
        (roles & perms).size > 0
      end

      ALL_PERMISSIONS = { '*' => :* }.freeze
      def roles_map(user)
        result = {}
        if user
          user.roles.where('resource_type = ? or resource_type IS NULL', model)
            .select(:resource_id, :name)
            .each do |r|
            (result[r.resource_id || '*'] ||= []) << r.name.to_sym
          end
        else
          result = ALL_PERMISSIONS
        end
        result
      end

      def find_resource_class(clazz)
        return nil if clazz == Object || clazz.nil?
        const = "#{clazz}Resource".safe_constantize
        if const.nil?
          find_resource_class(clazz.superclass)
        else
          const
        end
      end

      def to_collection(objects, security_context, clazz = nil)
        to_resource = (clazz || self).method(:to_resource)
        Buzzn::Resource::Collection.new(objects,
                                        to_resource,
                                        security_context,
                                        clazz)
      end

    end

    def initialize(object, security_context = nil)
      @security_context = security_context || SecurityContext.new
      @object = object
    end

    def allowed?(perms, roles = current_roles)
      self.class.send(:allowed?, roles, perms)
    end

    def to_h(options = {})
      JSON.parse(to_json(options))
    end
    alias :to_hash :to_h

    def to_yaml
      to_h.to_yaml
    end

    def to_json(options = {})
      json = ''
      json(json, options[:include])
      json
    end

    def json(json, includes)
      first = true
      self.class.attribute_names.flatten.each do |attr|
        obj = get(attr)
        if first
          first = false
          json << '{'
        else
          json << ','
        end
        json << '"' << attr.to_s << '":' << obj.to_json
      end
      includes.each do |k, v|
        if self.respond_to?(k)
          if first
            first = false
          else
            json << ','
          end
          json << '"' << k.to_s << '":'
          obj = self.send(k)
          case obj
          when Buzzn::Resource::Collection
            obj.json(json, v)
          when Array
            json << obj.to_json(include: v)
          when NilClass
            json << 'null'
          else
            obj.json(json, v)
          end
        end
      end if includes.is_a? Hash
      json << '}'
    end

    def method_missing(method, *args)
      if key?(method) && args.size == 0
        get(method)
      else
        super
      end
    end

    private

    def all(security_context, objects, *clazz_and_meta)
      clazz = clazz_and_meta.shift
      meta = clazz_and_meta
      allowed_objects = self.class.send(:filter_all_allowed, security_context, objects)
      result = self.class.send(:to_collection, allowed_objects, security_context, clazz)
      meta.each do |key|
        result[key] = send(key)
      end
      result
    end

    def current_user
      security_context.current_user
    end

    def current_roles
      security_context.current_roles
    end

    def permissions
      security_context.permissions
    end

  end
end
