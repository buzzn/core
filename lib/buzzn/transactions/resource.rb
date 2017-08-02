Buzzn::Transaction.define do |t|
  t.register_step(:update_resource) do |input, resource, extras = {}|
    begin
      Dry::Monads.Right(resource.update(input.merge(extras)))
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
end

