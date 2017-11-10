module Buzzn::Resource
  class Entity < Base

    class << self

      # Create-Update-Delete API

      def create(user, params)
        raise 'is abstract can not create' if @abstract
        perms = permissions
        if roles = allowed_roles(user, perms.create)
          to_resource(user, roles, perms, model.create!(params), self)
        else
          raise Buzzn::PermissionDenied.new(model, :create, user)
        end
      rescue ActiveRecord::RecordInvalid => e
        raise Buzzn::CascadingValidationError.new(nil, e)
      end

      def has_many!(method, clazz = nil)
        has_many(method, clazz)
        createables << method
        define_method "create_#{method.to_s.singularize}" do |params = {}|
          create(permissions.send(method).create) do
            to_resource(object.send(method).create!(params),
                        permissions.send(method),
                        clazz)
          end
        end
      end

      def createables
        @createables ||= []
      end

    end

    def check_staleness(params)
      # we deliver only millis to client and have to nil the nanos
      if (object.updated_at.to_f * 1000).to_i != (params.delete(:updated_at).to_f * 1000).to_i
        raise Buzzn::StaleEntity.new(object)
      end
    end

    def update(params)
      if permissions.respond_to?(:update) && allowed?(permissions.update)
        check_staleness(params)
        object.update!(params)
        self
      else
        raise Buzzn::PermissionDenied.new(self, :update, current_user)
      end
    end

    def delete
      if permissions.respond_to?(:delete) && allowed?(permissions.delete)
        object.delete
        self
      else
        raise Buzzn::PermissionDenied.new(self, :delete, current_user)
      end
    end

    def updatable
      ! permissions.nil? && allowed?(permissions.update)
    end
    alias :updatable? :updatable

    def deletable
      ! permissions.nil? && allowed?(permissions.delete)
    end
    alias :deletable? :deletable

    def createables
      result = self.class.createables.select do |name|
        allowed?(permissions.send(name).create)
      end
      if self.class.superclass.respond_to? :createables
        result += self.class.superclass.createables
      end
      result
    end

    # helper methods

    def create(perms)
      if allowed?(perms)
        yield
      else
        raise Buzzn::PermissionDenied.new(self, caller_locations(1,1)[0].label, current_user)
      end
    rescue ActiveRecord::RecordInvalid => e
      raise Buzzn::CascadingValidationError.new(nil, e)
    end
    alias :guarded :create

    def persisted?
      object.persisted?
    end

    # identity
    def id
      object.id
    end

    def type
      self.class.model.to_s.gsub(/::/, '').underscore
    end

    attribute :id, :type, :updated_at
  end
end
