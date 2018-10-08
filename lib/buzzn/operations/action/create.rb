require_relative '../action'

class Operations::Action::Create

  include Import['operations.action.invariant']

  def call(model_class, params)
    object = model_class.create!(params)
    invariant.(object: object)
    [
      object,
      resources.security_context
    ]
  end

end
