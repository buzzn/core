require_relative '../action'

class Operations::Action::Update

  include Dry::Transaction::Operation

  include Import['operations.action.save', 'operations.action.assign']

  def call(**kwargs)
    assign.(**kwargs)
    save.(**kwargs)
  end

end
