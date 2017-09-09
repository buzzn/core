module Buzzn
  class PermissionDenied < StandardError
    class << self
      def new(resource, action, user)
        case resource
        when Class
          super(create_class(resource, action, user))
        else
          super(create_instance(resource, action, user))
        end
      end

      def create_class(clazz, action, user)
        "#{action} #{clazz}: permission denied for User: #{user ? user.id : '--anonymous--'}"
      end
      def create_instance(object, action, user)
        "#{action} #{object.class}: #{object.id} permission denied for User: #{user ? user.id : '--anonymous--'}"
      end
    end
  end
  class RecordNotFound < StandardError
    class << self
      def new(clazz, id, user = nil)
        super("#{clazz || 'UNKNOWN-CLASS'}: #{id} not found#{user ? ' by User: ' + user.id : ''}")
      end
    end
  end
  class StaleEntity < StandardError
    class << self
      def new(entity)
        super("#{entity.class}: #{entity.id} was updated at: #{entity.updated_at}")
      end
    end
  end

  class GeneralError < StandardError

    attr_reader :errors

    def initialize(errors)
      @errors = errors
    end

    def message
      @errors.values.inspect
    end
  end
  class ValidationError < GeneralError; end

  class NestedValidationError < ValidationError
    def initialize(key, errors)
      nested_errors = {}
      key = key.to_sym
      errors.messages.each do |k,v|
        nested_errors["#{key}.#{k}".to_sym] = v
      end
      super(nested_errors)
    end
  end

  class CascadingValidationError < NestedValidationError
    def initialize(key = nil, ar_error)
      @original = ar_error
      errors = {}
      key ||= ar_error.record.class.to_s.underscore
      super(:"#{key}", ar_error.record.errors)
    end

    def backtrace
      @original.backtrace
    end
  end

end
