require_relative '../action'

class Operations::Action::Update

  include Dry::Transaction::Operation

  include Import['operations.action.save', 'operations.action.assign']

  def call(input, resource = nil)
    assign.call(input, resource).bind do |assigned_resource|
      save.call(assigned_resource)
    end
  end

end
