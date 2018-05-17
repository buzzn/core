require_relative '../action'

class Operations::Action::UpdateNg

  include Dry::Transaction::Operation

  include Import['operations.action.save', 'operations.action.assign']

  def call(resource:, params:)
    assign.(params, resource).bind do |assigned_resource|
      save.(assigned_resource)
    end
  end

end
