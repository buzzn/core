require_relative '../action'
require_relative 'update'

module Operations::Action
  class CreateOrUpdateAddress < Update

    def call(params:, resource:, **)
      if (address_resource = resource&.address) && params.key?(:address)
        super(params: params.delete(:address), resource: address_resource)
      elsif params.key?(:address) && address_params = params[:address]
        params[:address] = Address.create(address_params)
      end
    end

  end
end
