Buzzn::Transaction.define do |t|
  t.register_step(:update_resource) do |resource, input|
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

  t.register_step(:create_resource) do |clazz, current_user, input|
    Dry::Monads.Right(clazz.create(current_user, input))
  end
end

