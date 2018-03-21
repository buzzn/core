require_relative '../operations'

class Operations::Validation

  include Dry::Transaction::Operation

  def call(input, schema)
    result = schema.call(input)
    if result.success?
      Success(result.output)
    else
      raise Buzzn::ValidationError.new(result.errors)
      # TODO better use this and handle on roda - see transactions/base
      #Error(result.errors)
    end
  end

end
