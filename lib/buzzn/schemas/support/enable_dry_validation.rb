module Buzzn
  module Schemas
    module DryValidation
      def is_a?(clazz)
        # for dry-validation we say we are a Hash
        super || clazz == Hash
      end
    end

    module ValidateInvariant

      def vvalid?(*)
        invariant_valid?
      end

      def vvalidate(*)
        valid?
      end

      def invariant_valid?
        result = invariant
        if result && !result.success?
          result.errors.each do |key, value|
            errors.add(key, value)
          end
          false
        else
          true
        end
      end
    end

    module DryValidationForActiveRecord

      def find_invariant(clazz)
        if clazz != ActiveRecord::Base
          invariant = "#{::Schemas::Invariants}::#{clazz}".safe_constantize
          invariant || find_invariant(clazz.superclass)
        end
      end

      def invariant
        if invariant = find_invariant(self.class)
          ActiveRecordValidator.new(self).validate(invariant)
        end
      end
    end

    class ActiveRecordValidator
      include DryValidation

      def initialize(model)
        @model = model
      end

      def attributes
        @attributes ||= @model.attributes
      end

      def get(attr)
        attributes[attr.to_s] || @model.send(attr)
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


      def find_completeness(clazz)
        if clazz != Buzzn::Resource::Base
          invariant = "#{::Schemas::Completeness}::#{clazz.to_s.sub(/Resource$/, '')}".safe_constantize
          invariant || find_completeness(clazz.superclass)
        end
      end

      def incompleteness
        if completeness = find_completeness(self.class)
          completeness.call(self).errors
        else
          raise "could not find #{::Schemas::Completeness}::#{self.class}"
        end
      end
    end
  end
end
