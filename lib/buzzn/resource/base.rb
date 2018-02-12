require_relative '../schemas/support/enable_dry_validation'
require_relative 'context'

module Buzzn::Resource
  class Base

    include Schemas::Support::DryValidationForResource

    attr_reader :object, :current_user, :current_roles, :permissions

    def context
      Context.new(current_user, current_roles, permissions)
    end

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

      def new(resource, options = {})
        # FIXME probably not needed
        @abstract = false if @abstract.nil?
        # TODO this should be the only contructor
        if options.is_a? Context
          options = options.to_h
        end
        options ||= {}
        # ActiveModel::SerializableResource does not check whether it has
        # already an serializer, so we check it here and just return it
        # FIXME check if still needed
        if resource.is_a? self
          resource
        elsif abstract?
          # FIXME find if still needed
          to_resource(options[:current_user], options[:current_roles],
                      options[:permissions], resource)
        else
          super
        end
      end

      # DSL methods

      def attribute(*attr)
        @attrs ||= []
        @attrs += attr
      end
      alias :attributes :attribute

      def has_many(method, clazz = nil)
        define_method method do
          perms = permissions.send(method) rescue raise("missing permission #{method} on #{permissions} used in #{self}")
          all(perms, object.send(method), clazz)
        end
      end

      def has_one(method, clazz = nil)
        # deliver nested resource if permissions allow otherwise
        # raise PermissionsDenied or RecordNotFound when not found
        define_method "#{method}!" do
          perms = permissions.send(method) rescue raise("missing permission #{method} on #{permissions} used in #{self}")
          if allowed?(perms.retrieve)
            if result = object.send(method)
              self.class.to_resource(current_user, current_roles, perms,
                                     result, clazz)
            else
              raise Buzzn::RecordNotFound.new(self.class, method, current_user)
            end
          else
            clazz = self.class.send(:find_resource_class,
                                    object.send(method).class)
            raise Buzzn::PermissionDenied.new(clazz, :retrieve, current_user)
          end
        end

        # deliver result if permissions allow otherwise nil
        define_method method do
          perms = permissions.send(method) rescue raise("missing permission #{method} on #{permissions} used in #{self}")
          if allowed?(perms.retrieve) && (result = object.send(method))
            self.class.to_resource(current_user, current_roles, perms,
                                   result, clazz)
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

      ANONYMOUS = [Role::ANONYMOUS].freeze
      def all_allowed(user, roles, perms, enum)
        if user.nil?
          if allowed?(ANONYMOUS, perms)
            enum
          else
            enum.where('1=2') # deliver an empty AR relation
          end
        elsif allowed?(ANONYMOUS | roles | user.unbound_rolenames, perms)
          enum
        else
          enum.permitted(user.uids_for(perms)) rescue enum.restricted(user.uids_for(perms))
        end
      end

      def all(user, clazz = nil)
        enum = all_allowed(user, [], permissions.retrieve, filter_all(model.all))
        unbound = ANONYMOUS
        unbound += user.unbound_rolenames if user
        to_resource = (clazz || self).method(:to_resource)
        result = Buzzn::Resource::Collection.new(enum,
                                                 to_resource,
                                                 user,
                                                 unbound,
                                                 permissions,
                                                 clazz || self)
        result['createable'] = allowed?(unbound, permissions.create)
        result
      end

      def filter_all(objects); objects; end

      def to_resource(user, roles, permissions, instance, clazz = nil)
        clazz ||= find_resource_class(instance.class)
        raise "could not find Resource class for #{instance.class}" if clazz.nil?
        raise "could not instantiate Resource class for #{instance.class} as #{clazz} is abstract" if clazz.abstract?
        clazz.send(:new, instance, current_user: user, current_roles: roles, permissions: permissions)
      end

      private

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

      def permissions
        if @permissions.nil?
          @permissions = (self::Permission rescue NoPermission)
        end
        @permissions
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

    end

    def initialize(resource, current_user: nil, current_roles: [], permissions: nil)
      @current_user = current_user
      @current_roles = current_roles
      @permissions = permissions
      @object = resource
    end

    def to_collection(enum, perms, clazz = nil)
      Buzzn::Resource::Collection.new(enum,
                                      (clazz || self.class).method(:to_resource),
                                      current_user,
                                      current_roles,
                                      perms,
                                      clazz)
    end

    def to_resource(instance, perms, clazz = nil)
      self.class.to_resource(current_user, current_roles,
                                        perms, instance, clazz)
    end

    def allowed?(perms, roles = current_roles)
      self.class.send(:allowed?, roles, perms)
    end

    def all(perms, enum, clazz = nil)
      result = self.class.all_allowed(current_user, current_roles,
                                      perms.retrieve, enum)
      to_collection(result, perms, clazz)
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

    def is_a?(clazz)
      # for dry-validation we say we are a Hash
      super || clazz == Hash
    end

    def method_missing(method, *args)
      if key?(method) && args.size == 0
        get(method)
      else
        super
      end
    end

  end
end
