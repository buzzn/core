module Buzzn
  class PermissionDenied < StandardError; end
  class RecordNotFound < StandardError; end
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
