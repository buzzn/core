require 'dry-validation'
require_relative 'predicates'

module Buzzn
  module Schemas
    Form = Dry::Validation.Form(build: false) do
      configure do

        config.messages_file = 'config/errors.yml'

        predicates(Predicates)
      end
    end

    def self.Form(base = nil, **options, &block)
      klass = base ? Form.configure(Class.new(base.class)) : Form
      Dry::Validation.Schema(klass, options, &block)
    end
  end
end
