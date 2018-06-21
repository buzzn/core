require_relative '../action'
require_relative 'create_or_update_address'

module Operations::Action
  class CreateAddress < CreateOrUpdateAddress

    def call(params:, **)
      super(params: params, resource: nil)
    end

  end
end
