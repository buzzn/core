require "application_responder"
require 'oauth_helper'

class ApplicationController < ActionController::Base
  self.responder = ApplicationResponder
  respond_to :html

  include PublicActivity::StoreController


  before_filter :initialize_gon
  before_filter :http_basic_authenticate
  before_filter :set_paper_trail_whodunnit
  before_filter :authenticate_user!
  after_filter :test_gon

  def http_basic_authenticate
    if Rails.env.staging?
      authenticate_or_request_with_http_basic do |username, password|
        username == "buzzn" && password == "sonnenaufgang"
      end
    end
  end

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.

  protect_from_forgery with: :exception
  #protect_from_forgery with: :null_session

  #serialization_scope :current_user

  # protect_from_forgery

  # after_filter :set_csrf_cookie_for_ng

  # def set_csrf_cookie_for_ng
  #   cookies['XSRF-TOKEN'] = form_authenticity_token if protect_against_forgery?
  # end

  def test_gon
      p "!!current_user .............................. #{!!current_user} "
      Gon.global.push({ foo: 'bar'})
    if !!current_user
      Gon.global.push({ user_signed_in: true})
    end
      Gon.global.push({ user_signed_in: false})
  end



  def after_sign_in_path_for(resource)

    # sign_in_url = url_for(:action => 'new', :controller => 'sessions', :only_path => false)

    # if request.referer == sign_in_url
    #   super
    # else
    #   stored_location_for(resource) || request.referer || root_path
    # end

    stored_location_for(resource) || request.referer || profile_path(resource.profile)
  end

  def current_user
    UserDecorator.decorate(super) unless super.nil?
  end

  # used for authority to make it possible to deal with logged out users
  def current_or_null_user
    if current_user == nil
      User.new
    else
      current_user
    end
  end

  def initialize_gon
    if user_signed_in?

      oauth = OAuthHelper.new(current_user)
      # if the user just logged in we have username + password and need to use it
      user = params['user'] || {}
      token = oauth.token(user['password'])
      if token
        gon_access_token = token.token
        # use the same structure as /oauth/token will return
        gon_oauth = { expires_at: token.expires_at,
                      refresh_token: token.refresh_token,
                      access_token: token.token }
        logger.debug("[GON] #{current_user.email} using #{token.token} until #{Time.at token.expires_at}#{' via password login' if user['password']}")
      else
        gon_access_token = nil
        gon_oauth = nil
      end

      Gon.global.push({ current_user_id: current_user.id,
                        profile_name: current_user.profile.slug,
                        pusher_key: Rails.application.secrets.pusher_key,
                        pusher_host: Rails.application.secrets.pusher_host,
                        access_token: gon_access_token,
                        oauth: gon_oauth })
    end
  rescue => e
    logger.error("error while retrieving access token: #{e.message}")
  end

  def new_session_path(scope)
    new_user_session_path
  end

  protected


    def verified_request?
      super || valid_authenticity_token?(session, request.headers['X-XSRF-TOKEN'])
    end

end
