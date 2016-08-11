module API
  module V1
    class AccessTokens < Grape::API
      include API::V1::Defaults
      resource 'access-tokens' do


        desc "Creates an Access Token"
        params do
          requires :application_id, type: String, desc: "Application ID"
          requires :scopes, type: Array[String], desc: "List of scopes from #{Doorkeeper.configuration.scopes.to_a.join(', ')}", coerce_with: ->(val) { val.split(/,?\s+/) }, values: Doorkeeper.configuration.scopes.to_a
        end
        oauth2 :full
        post do
          unless Doorkeeper::AccessToken.creatable_by?(current_user)
            return status 403
          end
          Doorkeeper::AccessToken.create!(
            scopes: permitted_params[:scopes],
            resource_owner_id: current_user.id,
            application_id: permitted_params[:application_id]
          )
        end


      end
    end
  end
end
