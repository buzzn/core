require_relative '../action'

class Operations::Action::Assign

  include Import['operations.action.invariant', 'operations.action.stale']

  def call(params:, resource:, **)
    stale.(params: params, resource: resource)
    resource.object.attributes = params
    invariant.(object: resource.object)
  end

end
