module Buzzn
  class BaseResource < ActiveModel::Serializer

    class << self
      private :new

      def guarded_collection(method)
        unless methods.include?(method)
          define_method method do
            object.send(method).readable_by(@current_user)
          end
        end
      end
      private :guarded_collection

      def guarded_entity(method)
        unless methods.include?(method)
          # deliver nested resource if permissions allow otherwise
          # raise PermissionsDenied or RecordNotFound when not found
          define_method "#{method}!" do
            result = object.send(method)   
            if result.nil?
              raise RecordNotFound.new
            elsif result.readable_by?(@current_user)
              result
            else
              raise PermissionDenied.create(result, :retrieve, @current_user)
            end
          end
          # deliver result if permissions allow otherwise nil
          define_method method do
            result = object.send(method)
            if result && result.readable_by?(@current_user)
              result
            end
          end
        end
      end
      private :guarded_entity

      # DSL methods

      def has_many(method, *args)
        guarded_collection(method)
        super
      end

      def has_one(method, *args)
        guarded_entity(method)
        super
      end

      def collections(*methods)
        methods.each do |method|
          guarded_collection(method)
        end
      end
      def entities(*methods)
        methods.each do |method|
          guarded_entity(method)
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
        @abstract = true
      end

      # the 'R' from the crud API

      def find_resource_class(clazz)
        if clazz == model || clazz == Object
          raise "could not find Resource class for #{clazz}"
        end
        const = "#{clazz}Resource".safe_constantize
        if const.nil?
          find_resource_class(clazz.superclass)
        else
          const
        end
      end
      private :find_resource_class

      def to_resource(current_user, instance)
        if @abstract
          clazz = find_resource_class(instance.class)
        else
          clazz = self
        end
        clazz.send(:new, instance, current_user: current_user)
      end
      private :to_resource

      def retrieve(current_user, id)
        instance = model.guarded_retrieve(current_user, id)
        to_resource(current_user, instance)
      end

      def all(current_user, filter = nil)
        result = model.readable_by(current_user)
        if filter
          result.filter(filter)
        else
          result
        end
      end
    end

    def initialize(resource, options = {})
      @current_user = options[:current_user]
      super
    end

    alias :to_h :serializable_hash
    alias :to_hash :serializable_hash
  end
end
