module API
  module V1
    class Auth < Grape::API
      include API::V1::Defaults
      resource 'auth' do


        desc "Return the Access Token"
        params do
          requires :authorizationCode, type: String, desc: "Authorization Code"
        end
        post 'token' do
          authorization_code = params[:authorizationCode]
          grant = Doorkeeper::AccessGrant.by_token(authorization_code)
          app   = grant.application
          client = OAuth2::Client.new(app.uid, app.secret, :site => "http://localhost:3000")
          token  = client.auth_code.get_token(authorization_code, :redirect_uri => app.redirect_uri)
          return token
        end




      end
    end
  end
end
