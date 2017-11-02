module Buzzn
  module Schemas
    module DryValidation
      def is_a?(clazz)
        # for dry-validation we say we are a Hash
        super || clazz == Hash
      end
    end

    class ActiveRecordValidator
      include DryValidation

      def intialize(model)
        @model = model
      end

      def get(attr)
        @model.send(attr)
      end
      alias :[] :get

      def key?(attr)
        @model.respond_to?(attr)
      end

      def validate(schema)
        schema.call(self)
      end
    end

    module DryValidationForResource
      include DryValidation

      def get(attr)
        if self.respond_to?(attr)
          self.send(attr)
        else
          object.attributes[attr.to_s] || object.send(attr)
        end
      end
      alias :[] :get

      def key?(attr)
        self.respond_to?(attr) || object.attributes.key?(attr) || object.respond_to?(attr)
      end
    end
  end
end
