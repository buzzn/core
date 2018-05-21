require_relative 'base'

module Buzzn::Resource
  class Entity < Base

    class << self

      # Create-Update-Delete API

      def has_many(method, clazz = nil)
        super
        createables << method
      end

      def createables
        @createables ||= []
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
        permissions.respond_to?(name) && allowed?(permissions.send(name).create)
      end
      if self.class.superclass.respond_to? :createables
        result += self.class.superclass.createables
      end
      result
    end

    # helper methods

    def persisted?
      object.persisted?
    end

    # identity
    def id
      object.id
    end

    def type
      Dry::Core::Inflector.underscore(self.class.model.to_s.gsub(/::/, '')).underscore
    end

    attribute :id, :type, :updated_at

  end
end
