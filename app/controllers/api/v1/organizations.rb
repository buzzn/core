module API
  module V1
    class Organizations < Grape::API
      include API::V1::Defaults

      resource :organizations do

        desc "Return an Organization"
        params do
          requires :id, type: String, desc: "ID of the organization"
        end
        oauth2 false
        get ":id" do
          OrganizationResource.retrieve(current_user, permitted_params)
        end

        desc 'Return the related address for an organization'
        params do
          requires :id, type: String, desc: 'ID of the organization'
        end
        oauth2 false
        get ':id/address' do
          OrganizationResource
            .retrieve(current_user, permitted_params)
            .address!
        end


        desc 'Return the related bank_account for an organization'
        params do
          requires :id, type: String, desc: 'ID of the organization'
        end
        oauth2 :full
        get ':id/bank-account' do
          OrganizationResource
            .retrieve(current_user, permitted_params)
            .bank_account!
        end
      end
    end
  end
end
