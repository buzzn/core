module Buzzn
  class BaseResource < ActiveModel::Serializer

    attr_reader :current_user

    class << self

      def new(resource, options = {})
        @abstract = false if @abstract.nil?
        options ||= {}
        # ActiveModel::SerializableResource does not check whether it has
        # already an serializer, so we check it here and just return it
        if resource.is_a? self
          resource
        elsif abstract?
          to_resource(options[:current_user], resource)
        else
          super
        end
      end

      def guarded_collection(method)
        unless methods.include?(method)
          define_method method do
            object.send(method)
              .readable_by(current_user)
              .collect { |r| self.class.to_resource(current_user, r) }
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
            elsif result.readable_by?(current_user)
              self.class.to_resource(current_user, result)
            else
              raise PermissionDenied.create(result, :retrieve, current_user)
            end
          end
          # deliver result if permissions allow otherwise nil
          define_method method do
            result = object.send(method)
            if result && result.readable_by?(current_user)
              self.class.to_resource(current_user, result)
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
        @abstract = true if @abstract.nil?
        @abstract
      end

      def abstract?
        @abstract == true
      end

      # the 'R' from the crud API

      def find_resource_class(clazz)
        return nil if clazz == Object || clazz.nil?
        const = "#{clazz}Resource".safe_constantize
        if const.nil?
          find_resource_class(clazz.superclass)
        else
          const
        end
      end
      private :find_resource_class

      def to_resource(user, instance, clazz = nil)
        clazz ||= find_resource_class(instance.class)
        unless clazz
          raise "could not find Resource class for #{instance.class}"
        end
        clazz.send(:new, instance, current_user: user)
      end

      def retrieve(user, id)
        instance = model.guarded_retrieve(user, id)
        to_resource(user, instance, @abstract ? nil : self)
      end

      def all(user, filter = nil)
        result = model.readable_by(user)
        if filter
          result = result.filter(filter)
        end
        result.collect do |r|
          to_resource(user, r)
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
