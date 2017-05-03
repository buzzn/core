require 'buzzn/contract_factory'
module API
  module V1
    class Contracts < Grape::API
      include API::V1::Defaults

      resource :contracts do

        desc 'Return the related contractor for a Contract'
        params do
          requires :id, type: String, desc: 'ID of the Contract'
        end
        get ':id/contractor' do
          Contract::BaseResource
            .retrieve(current_user, permitted_params)
            .contractor!
        end

        desc 'Return the related customer for a Contract'
        params do
          requires :id, type: String, desc: 'ID of the Contract'
        end
        get ':id/customer' do
          Contract::BaseResource
            .retrieve(current_user, permitted_params)
            .customer!
        end

        desc 'Return a Contract'
        params do
          requires :id, type: String, desc: 'ID of the Contract'
        end
        get ':id' do
          Contract::BaseResource.retrieve(current_user, permitted_params)
        end
      end
    end
  end
end
