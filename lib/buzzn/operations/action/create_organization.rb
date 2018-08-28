require_relative '../action'
require_relative 'create_or_update_organization'

module Operations::Action
  class CreateOrganization < CreateOrUpdateOrganization

    def call(params:, method:, **)
      super(params: params, method: method, resource: nil)
    end

  end
end
