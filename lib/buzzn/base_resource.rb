module Buzzn
  class BaseResource < ActiveModel::Serializer

    attr_reader :current_user, :current_roles, :permissions

    class << self

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

      def has_many(method, *args)
        super
        define_method method do
          if permissions
            Buzzn::ResourceCollection.new(object.send(method),
                                          self.class.method(:to_resource),
                                          current_user,
                                          { '*' => current_roles },
                                          permissions)
          else
            Buzzn::ResourceCollection.new(object.send(method)
                                           .readable_by(current_user),
                                          self.class.method(:to_resource),
                                          current_user, {}, permissions)
          end
        end
      end

      def has_one(method, *args)
        # deliver nested resource if permissions allow otherwise
        # raise PermissionsDenied or RecordNotFound when not found
        define_method "#{method}!" do
          if permissions
            perms = permissions.send(method)
            if allowed?(perms.retrieve)
              if result = object.send(method)
                self.class.to_resource(current_user, current_roles, perms,
                                       result)
              else
                raise RecordNotFound.new(self.class, method, current_user)
              end
            else
              clazz = self.class.send(:find_resource_class,
                                      object.send(method).class)
              raise PermissionDenied.new(clazz, :retrieve, current_user)
            end
          else
            # TODO remove this deprecated clause
            result = object.send(method)
            if result.nil?
              raise RecordNotFound.new(self.class, method, current_user)
            elsif result.readable_by?(current_user)
              self.class.to_resource(current_user, nil, nil, result)
            else
              clazz = self.class.send(:find_resource_class, result.class)
              raise PermissionDenied.create(clazz, :retrieve, current_user)
            end
          end
        end

        # deliver result if permissions allow otherwise nil
        define_method method do
          if permissions
            perms = permissions.send(method)
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

        super
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
          result ||= get(user, id)
          roles = roles(user, id)
          if allowed?(roles, perms.retrieve)
            to_resource(user, roles, perms, result,
                        abstract? ? nil : self)
          else
            raise Buzzn::PermissionDenied.new(self, :retrieve, user)
          end
        else
          # TODO remove legacy
          instance = model.guarded_retrieve(user, id)
          to_resource(user, nil, nil, instance, @abstract ? nil : self)
        end
      end

      def bound_resources(user, perms)
        # use uuid as they are globally unique
        user.roles.where('resource_type IS NOT NULL and name IN (?)', perms).select(:resource_id)
      end

      def unbound_roles(user, perms)
        user.roles.where('resource_id IS NULL and name IN (?)', perms).select(1)
      end

      def all_allowed(user, perms, enum, id_field = 'id')
        enum = enum.where("#{id_field} IN (?) or EXISTS (?)",
                          bound_resources(user, perms),
                          unbound_roles(user, perms))
      end

      def all(user, filter = nil)
        if permissions
          if user
            enum = all_allowed(user, permissions.retrieve, model.filter(filter))
          end
          Buzzn::ResourceCollection.new(enum || [],
                                        method(:to_resource),
                                        user,
                                        roles_map(user),
                                        permissions)
        else
          # TODO remove deprecated code
          result = model.readable_by(user)
          if filter
            result = result.filter(filter)
          end
          result.collect do |r|
            # highly inefficient but needed to pass in permissions
            # is deprecated any ways
            find_resource_class(r.class).retrieve(user, r.id)
          end
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

      def allowed?(roles, perms)
        (roles & perms).size > 0
      end

      def get(user, id)
        instance = model.where(id: id).first
        if instance.nil?
          raise Buzzn::RecordNotFound.new(self, id, user)
        end
        instance
      end

      def permissions
        if @permissions.nil?
          @permissions = "#{model}Permissions".safe_constantize || false
        end
        @permissions
      end

      def roles_map(user)
        result = {}
        if user
          user.roles.where("resource_type = ? or resource_type IS NULL", model)
            .select(:resource_id, :name)
            .each do |r|
            (result[r.resource_id || '*'] ||= []) << r.name.to_sym
          end
        end
        result
      end

      def roles(user, id = nil)
        if user
          roles =
            if id
              user.roles.where('resource_id = ? or resource_id IS NULL', id)
            else
              user.roles.where('resource_id IS NULL')
            end
          roles.select(:name).collect { |r| r.name.to_sym }
        else
          []
        end
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
      super
    end

    def to_collection(enum, perms = nil)
      Buzzn::ResourceCollection.new(enum,
                                    self.class.method(:to_resource),
                                    current_user,
                                    { '*' => current_roles },
                                    perms)
    end

    def to_resource(instance, perms)
      self.class.to_resource(current_user, current_roles, perms, instance)
    end

    def allowed?(perms)
      self.class.send(:allowed?, current_roles, perms)
    end

    def all_allowed(perms, enum, id_field = 'id')
      self.class.all_allowed(current_user, perms, enum, id_field)
    end

    def unbound_roles(perms)
      self.class.unbound_roles(current_user, perms)
    end

    alias :to_h :serializable_hash
    alias :to_hash :serializable_hash
  end
end
