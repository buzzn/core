module API
  module V1
    class Auth < Grape::API
      include API::V1::Defaults
      resource 'auth' do


        desc "Return the Access Token"
        params do
          requires :authorization_code, type: String, desc: "Authorization Code"
        end
        post 'token' do
          code   = params[:authorization_code]
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
