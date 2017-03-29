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

      # crud API

      def create(current_user, params)
        raise 'is abstract can not create' if @abstract
        new(model.guarded_create(current_user, params),
            current_user: current_user)
      end

      def retrieve(current_user, id)
        new(model.guarded_retrieve(current_user, id),
            current_user: current_user)
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

    def id
      object.id
    end

    def type
      self.class.model.to_s.gsub(/::/, '').underscore
    end

    attributes :id, :type

    alias :to_h :serializable_hash
    alias :to_hash :serializable_hash
  end
end
