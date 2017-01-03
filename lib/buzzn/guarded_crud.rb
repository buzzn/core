require 'buzzn'
module Buzzn
  module GuardedCrud

    def self.included(model)
      model.extend ClassMethods
    end

    def guarded_read(user, *args)
      if readable_by?(user, *args)
        self
      else
        raise PermissionDenied.new
      end
    end

    def guarded_update(user, params)
      if updatable_by?(user)
        update!(self.class.guarded_prepare(user, params))
        self
      else
        raise PermissionDenied.new
      end
    end

    def guarded_delete(user)
      if deletable_by?(user)
        destroy!
        self
      else
        raise PermissionDenied.new
      end
    end

    module ClassMethods
      def guarded_prepare(user, params)
        params
      end

      def guarded_create(user, params, *args)
        if creatable_by?(user, *args)
          create!(guarded_prepare(user, params))
        else
          raise PermissionDenied.new
        end
      end

      def guarded_retrieve(user, id)
        if id.is_a?(Hash)
          id = id[:id]
        end
        _guarded_check(where(id: id).readable_by(user).limit(1).first, user, id)
      end

      def unguarded_retrieve(id)
        if id.is_a?(Hash)
          id = id[:id]
        end
        result = where(id: id).limit(1).first
        if result.nil?
          raise RecordNotFound.new("#{self} with id=#{id} not found")
        end
        result
      end

      def anonymized_guarded_retrieve(user, id)
        if id.is_a?(Hash)
          id = id[:id]
        end
        _guarded_check(where(id: id).anonymized_readable_by(user).limit(1).first, user, id)
      end

      def guarded_update(user, id = nil, params = nil)
        if params.nil?
          params = id
          id = params[:id]
        end
        _guarded_get(user, id).guarded_update(user, params)
      end

      def guarded_delete(user, id)
        if id.is_a?(Hash)
          id = id[:id]
        end
        _guarded_get(user, id).guarded_delete(user)
      end

      private

      def _guarded_check(result, user, id)
        if result.nil?
          if where(id: id).size == 0
            raise RecordNotFound.new("#{self} with id=#{id} not found#{user ? ' by user_id=' + user.id : ''}")
          end
          raise PermissionDenied.new
        end
        result
      end

      def _guarded_get(user, id)
        result = where(id: id).limit(1).first
        if result.nil?
          raise RecordNotFound.new("#{self} with id=#{id} not found#{user ? ' by user_id=' + user.id : ''}")
        end
        result
      end
    end
  end
end
