require 'oauth2/client'
require 'oauth2/access_token'

class OAuthHelper

  def initialize(user)
    @user = user
  end

  def rails_view
    @app ||= Doorkeeper::Application.where(name: 'Buzzn RailsView').first
    raise 'can not find rails-view oauth application' unless @app
    @app
  end

  def client
    @client ||= OAuth2::Client.new(rails_view.uid, rails_view.secret, site: Rails.application.secrets.hostname)
  end

  def token(username, password)
    # if we have a token with refresh-token then take it
    token = access_token
    # if no refresh-token but username/password then login with password grant
    if username && token.refresh_token.nil?
      # TODO remove this hard-coded scope and use rails_view.scopes.to_s
      token = client.password.get_token(username, password, scope: 'full')
      # as the password grant does not register the right application we do it here
      ac = Doorkeeper::AccessToken.where(token: token.token).first
      ac.update!(application_id: rails_view.id)
    end
    token
  end

  def to_access_token(token)
    # create an access_token wrapper
    access_token = OAuth2::AccessToken.new(client, token.token,
                                           expires_in: token.expires_in,
                                           expires_at: token.created_at.to_i + token.expires_in.to_i,
                                           refresh_token: token.refresh_token)
    # refresh access_token if it is about to expire and return the new one
    if access_token.refresh_token && (access_token.expires_at - Time.now.to_i < 120)
      access_token.refresh!
    else
      access_token
    end
  end
      
  def access_token
    # find the token which does expire for the rails view
    token = @user.access_tokens.where('application_id = ? AND expires_in IS NOT NULL AND revoked_at IS NULL', rails_view.id).first
    if token
      # get a usable token
      to_access_token(token)
    else
      # take the one which does not expires or return nil
      token = @user.access_tokens.where(application: rails_view, expires_in: nil).first
      # and convert into OAuth2::AccessToken
      to_access_token(token) if token
    end
  end
end
