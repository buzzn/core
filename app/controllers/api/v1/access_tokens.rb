module API
  module V1
    class AccessTokens < Grape::API
      include API::V1::Defaults
      resource 'access-tokens' do

        before do
          doorkeeper_authorize! :manager
        end

        desc "Creates an Access Token "
        params do
          requires :application_id, type: String, desc: "Application ID"
          requires :scopes, type: String, desc: "Scopes"
        end
        post do
          unless Doorkeeper::AccessToken.creatable_by?(current_user)
            return status 403
          end
          params[:scopes].split(/,\s+/).each do |scope|
            unless Doorkeeper.configuration.scopes.member? scope
              return status 400
            end
          end
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
