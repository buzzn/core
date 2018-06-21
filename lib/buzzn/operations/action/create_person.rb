require_relative '../action'
require_relative 'create_or_update_person'

module Operations::Action
  class CreatePerson < CreateOrUpdatePerson

    def call(params:, method:, **)
      super(params: params, method: method, resource: nil)
    end

  end
end
