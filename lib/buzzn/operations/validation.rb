require_relative '../operations'

class Operations::Validation
  include Dry::Transaction::Operation

  def call(input, schema = nil)
    raise ArgumentError.new('missing schema') unless schema

    result = schema.call(input)
    if result.success?
      Dry::Monads.Right(result.output)
    else
      raise Buzzn::ValidationError.new(result.errors)
      # TODO better use this and handle on roda
      #Dry::Monads.Left(result.errors)
    end
  end
end
