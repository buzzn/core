require_relative '../operations'

class Operations::Validation
  include Dry::Transaction::Operation

  def call(input, schema)
    result = schema.call(input)
    if result.success?
      Right(result.output)
    else
      raise Buzzn::ValidationError.new(result.errors)
      # TODO better use this and handle on roda
      #Left(result.errors)
    end
  end
end
