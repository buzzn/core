require_relative '../action'

class Operations::Action::CreateItem

  include Import['operations.action.invariant']

  def call(resources, params)
    object = resources.objects.create!(params)
    invariant.(object: object)
    [
      object,
      resources.security_context
    ]
  end

end
