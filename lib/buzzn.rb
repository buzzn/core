module Buzzn
  class PermissionDenied < StandardError
    def self.create(resource, action, user)
      case resource
      when Class
        create_class(resource, action, user)
      else
        create_instance(resource, action, user)
      end
    end
    def self.create_class(clazz, action, user)
      new("#{action} #{clazz}: permission denied for User: #{user ? user.id : '--anonymous--'}")
    end
    def self.create_instance(object, action, user)
      new("#{action} #{object.class}: #{object.id} permission denied for User: #{user ? user.id : '--anonymous--'}")
    end
  end
  class RecordNotFound < StandardError
    def self.create(clazz, id, user = nil)
      new("#{clazz}: #{id} not found#{user ? ' by User: ' + user.id : ''}")
    end
  end
  class ValidationError < StandardError

    attr_reader :errors

    def initialize(errors)
      @errors = errors
    end

    def message
      @errors.values.inspect
    end
  end

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
