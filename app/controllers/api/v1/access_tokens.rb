module API
  module V1
    class AccessTokens < Grape::API
      include API::V1::Defaults
      resource 'access-tokens' do


        desc "Return the Access Token "
        params do
          requires :application_id, type: String, desc: "Scopes"
          requires :scopes, type: String, desc: "Application ID"
        end
        post do
          doorkeeper_authorize! :manager
          Doorkeeper::AccessToken.create!(
            scopes: params[:scopes],
            resource_owner_id: current_user.id,
            application_id: params[:application_id]
          )
        end


      end
    end
  end
end
