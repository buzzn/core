module Buzzn
  class EntityResource < BaseResource

    def initialize(resource, options = {})
      super
    end

    class << self

      # CreateUpdateDelete API

      def create(current_user, params)
        raise 'is abstract can not create' if @abstract
        new(model.guarded_create(current_user, params),
            current_user: current_user)
      end
    end

    def update(params)
      object.guarded_update(@current_user, params)
      self
    end

    def delete
      object.guarded_delete(@current_user)
      self
    end

    def updatable
      object.updatable_by?(@current_user)
    end
    alias :updatable? :updatable

    def deletable
      object.deletable_by?(@current_user)
    end
    alias :deletable? :deletable

    # helper methods

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

    attributes :id, :type
  end
end
