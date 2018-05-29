require_relative '../action'

class Operations::Action::New

  include Import['operations.action.invariant']

  def call(params:, clazz:, **)
    object = clazz.new(params)
  end

end
