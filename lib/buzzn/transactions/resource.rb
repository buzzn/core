Buzzn::Transaction.define do |t|

  t.register_step(:update_resource) do |input, resource|
    begin
      Dry::Monads.Right(resource.update(input))
    rescue ActiveRecord::RecordInvalid => e
      errors = {}
      e.record.errors.messages.each do |name, messages|
        errors[name] = messages.collect do |message|
          "#{name} #{message}"
        end
      end
      raise Buzzn::ValidationError.new errors
    end
  end

  t.register_step(:nested_resource) do |input, method|
    Dry::Monads.Right(method.call(input))
  end

  t.register_step(:method) do |input, method|
    Dry::Monads.Right(method.call(input))
  end

  t.register_step(:retrieve) do |id, resources|
    Dry::Monads.Right(resources.retrieve(id))
  end

  t.register_step(:build) do |input, resources|
    Dry::Monads.Right(resources.build(input))
  end

  t.register_step(:constraints) do |input, contraints|
    result = contraints.(input)
    if result.success?
      Dry::Monads.Right(result.output)
    else
      raise Buzzn::ValidationError.new(result.errors)
      # TODO better use this and handle on roda
      #Dry::Monads.Left(result.errors)
    end
  end
end

