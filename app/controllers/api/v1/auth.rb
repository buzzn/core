module API
  module V1
    class Auth < Grape::API
      include API::V1::Defaults
      resource 'auth' do


        desc "exchange AuthorizationCode to AccessToken"
        params do
          requires :authorization_code, type: String, desc: "Authorization Code"
        end
        oauth2 false
        post 'token' do
          code   = permitted_params[:authorization_code]
          grant  = Doorkeeper::AccessGrant.by_token(code)
          app    = grant.application
          client = OAuth2::Client.new(app.uid, app.secret, :site => Rails.application.secrets.hostname)
          token  = client.auth_code.get_token(code, :redirect_uri => app.redirect_uri)
          return token
        end




      end
    end
  end
end
