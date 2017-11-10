require 'dry-validation'
require_relative 'predicates'

module Buzzn
  module Schemas
    ERRORS = 'config/errors.yml'
    Form = Dry::Validation.Form(build: false) do
      configure do

        config.messages_file = ERRORS

        predicates(Predicates)
      end
    end

    Schema = Dry::Validation.Schema(build: false) do
      configure do
        config.messages_file = ERRORS
      end
    end

    def self.Form(base = nil, **options, &block)
      klass = base ? Form.configure(Class.new(base.class)) : Form
      Dry::Validation.Schema(klass, options, &block)
    end

    def self.Schema(base = nil, **options, &block)
      klass = base ? Schema.configure(Class.new(base.class)) : Schema
      Dry::Validation.Schema(klass, options, &block)
    end
  end
end
