module Buzzn::Resource
  class Base

    attr_reader :object, :current_user, :current_roles, :permissions

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
        @abstract = false if @abstract.nil?
        options ||= {}
        # ActiveModel::SerializableResource does not check whether it has
        # already an serializer, so we check it here and just return it
        if resource.is_a? self
          resource
        elsif abstract?
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

      def has_many(method, *args)
        define_method method do
          if permissions
            perms = permissions.send(method) rescue raise("missing permission #{method} on #{self}")
            all(perms, object.send(method))
          else
            # TOOO remove deprecated
            Buzzn::Resource::Collection.new(object.send(method)
                                             .readable_by(current_user),
                                            self.class.method(:to_resource),
                                            current_user, [], permissions)
          end
        end
      end

      def has_one(method, *args)
        # deliver nested resource if permissions allow otherwise
        # raise PermissionsDenied or RecordNotFound when not found
        define_method "#{method}!" do
          if permissions
            perms = permissions.send(method) rescue raise("missing permission #{method} on #{self}")
            if allowed?(perms.retrieve)
              if result = object.send(method)
                self.class.to_resource(current_user, current_roles, perms,
                                       result)
              else
                raise Buzzn::RecordNotFound.new(self.class, method, current_user)
              end
            else
              clazz = self.class.send(:find_resource_class,
                                      object.send(method).class)
              raise Buzzn::PermissionDenied.new(clazz, :retrieve, current_user)
            end
          else
            # TODO remove this deprecated clause
            result = object.send(method)
            if result.nil?
              raise Buzzn::RecordNotFound.new(self.class, method, current_user)
            elsif result.readable_by?(current_user)
              self.class.to_resource(current_user, nil, nil, result)
            else
              clazz = self.class.send(:find_resource_class, result.class)
              raise Buzzn::PermissionDenied.create(clazz, :retrieve, current_user)
            end
          end
        end

        # deliver result if permissions allow otherwise nil
        define_method method do
          if permissions
            perms = permissions.send(method) rescue raise("missing permission #{method} on #{self}")
            if allowed?(perms.retrieve) && (result = object.send(method))
              self.class.to_resource(current_user, current_roles, perms,
                                     result)
            end
          else
            # TODO remove deprecated
            result = object.send(method)
            if result && result.readable_by?(current_user)
              self.class.to_resource(current_user, nil, nil, result)
            end
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

      # the 'R' from the crud API

      def retrieve(user, id)
        if abstract?
          result = get(user, id)
          perms = find_resource_class(result.class).send :permissions
        else
          perms = permissions
        end
        if perms
          if roles = allowed_roles(user, perms.retrieve, id)
            result ||= get(user, id)
            to_resource(user, roles, perms, result,
                        abstract? ? nil : self)
          else
            result ||= (get(user, id) rescue self)
            raise Buzzn::PermissionDenied.new(result, :retrieve, user)
          end
        else
          # TODO remove legacy
          instance = model.guarded_retrieve(user, id)
          to_resource(user, nil, nil, instance, @abstract ? nil : self)
        end
      end

      def all_allowed(user, roles, perms, enum)
        if user.nil?
          if allowed?([:anonymous], perms)
            enum
          else
            enum.where('1=2') # deliver an empty AR relation
          end
        elsif allowed?([:anonymous] | roles | user.unbound_rolenames, perms)
          enum
        else
          enum.restricted(user.uuids_for(perms))
        end
      end

      def all(user, filter = nil)
        if permissions
          raise 'filter not allowed' if filter
          enum = all_allowed(user, [], permissions.retrieve, model.all)
          unbound = [:anonymous]
          unbound += user.unbound_rolenames if user
          Buzzn::Resource::Collection.new(enum,
                                          method(:to_resource),
                                          user,
                                          unbound,
                                          permissions,
                                          self)
        else
          # TODO remove deprecated code
          result = model.readable_by(user).filter(filter)
          {
            'array' => result.collect do |r|
              # highly inefficient but needed to pass in permissions
              # is deprecated any ways
              find_resource_class(r.class).retrieve(user, r.id)
            end
          }
        end
      end

      def to_resource(user, roles, permissions, instance, clazz = nil)
        clazz ||= find_resource_class(instance.class)
        unless clazz
          raise "could not find Resource class for #{instance.class}"
        end
        clazz.send(:new, instance, current_user: user, current_roles: roles, permissions: permissions)
      end

      private

      def allowed_roles(user, perms, id = nil)
        return false unless user
        roles = id ? user.rolenames_for(id) : user.unbound_rolenames
        if (roles & perms).empty?
          false
        else
          roles
        end
      end

      def allowed?(roles, perms)
        (roles & perms).size > 0
      end

      def get(user, id)
        instance = model.where(id: id).first
        if instance.nil?
          # use heavily patch find-method with friendly/slugged id 
          instance = model.find(id) rescue nil
          if instance.nil?
            raise Buzzn::RecordNotFound.new(self, id, user)
          end
        end
        instance
      end

      def permissions
        if @permissions.nil?
          @permissions = "#{model}Permissions".safe_constantize || false
        end
        @permissions
      end

      ANONYMOUS = { '*' => :* }.freeze
      def roles_map(user)
        result = {}
        if user
          user.roles.where("resource_type = ? or resource_type IS NULL", model)
            .select(:resource_id, :name)
            .each do |r|
            (result[r.resource_id || '*'] ||= []) << r.name.to_sym
          end
        else
          result = ANONYMOUS
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

    def to_collection(enum, perms = nil, clazz = nil)
      Buzzn::Resource::Collection.new(enum,
                                      (clazz || self.class).method(:to_resource),
                                      current_user,
                                      current_roles,
                                      perms,
                                      clazz)
    end

    def to_resource(instance, perms)
      self.class.to_resource(current_user, current_roles, perms, instance)
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
        obj = self.respond_to?(attr) ? self.send(attr) : object.send(attr)
        if first
          first = false
          json << '{'
        else
          json << ','
        end
        json << '"' << attr.to_s << '":' << obj.to_json
      end
      includes.each do |k,v|
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
            #  binding.pry
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
  end
end
