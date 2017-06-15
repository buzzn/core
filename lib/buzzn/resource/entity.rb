module Buzzn::Resource
  class Entity < Base

    class << self

      # Create-Update-Delete API

      def create(user, params)
        raise 'is abstract can not create' if @abstract
        perms = permissions
        if perms
          if roles = allowed_roles(user, perms.create)
            to_resource(user, roles, perms, model.create!(params), self)
          else
            raise Buzzn::PermissionDenied.new(model, :create, user)
          end
        else
          # TODO remove deprecated
          new(model.guarded_create(current_user, params),
              current_user: current_user)
        end
      rescue ActiveRecord::RecordInvalid => e
        raise Buzzn::CascadingValidationError.new(nil, e)
      end
    end

    def update(params)
      if permissions
        if permissions.respond_to?(:update) && allowed?(permissions.update)
          object.update!(params)
          self
        else
          raise Buzzn::PermissionDenied.new(self, :update, current_user)
        end
      else
        # TODO remove deprecated
        object.guarded_update(current_user, params)
        self
      end
    end

    def delete
      if permissions
        if permissions.respond_to?(:delete) && allowed?(permissions.delete)
          object.delete
          self
        else
          raise Buzzn::PermissionDenied.new(self, :delete, current_user)
        end
      else
        # TODO remove deprecated
        object.guarded_delete(current_user)
        self
      end
    end

    def updatable
      if permissions
        allowed?(permissions.update)
      else
        # TODO remove deprecated
        object.updatable_by?(current_user)
      end
    end
    alias :updatable? :updatable

    def deletable
      if permissions
        allowed?(permissions.delete)
      else
        # TODO remove deprecated
        object.deletable_by?(current_user)
      end
    end
    alias :deletable? :deletable

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

    attribute :id, :type
  end
end
