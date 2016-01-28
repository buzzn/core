require "application_responder"

class ApplicationController < ActionController::Base
  self.responder = ApplicationResponder
  respond_to :html

  include PublicActivity::StoreController

  before_filter :initialize_gon

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

  def after_sign_in_path_for(resource)

    # sign_in_url = url_for(:action => 'new', :controller => 'sessions', :only_path => false)

    # if request.referer == sign_in_url
    #   super
    # else
    #   stored_location_for(resource) || request.referer || root_path
    # end

    profile_path(resource.profile)
  end

  def current_user
    UserDecorator.decorate(super) unless super.nil?
  end

  def initialize_gon
    if user_signed_in?
      Gon.global.push({ current_user_id: current_user.id,
                        profile_name: current_user.user_name,
                        pusher_key: Rails.application.secrets.pusher_key,
                        pusher_host: Rails.application.secrets.pusher_host})
    end
  end

  def new_session_path(scope)
    new_user_session_path
  end

  protected
    def verified_request?
      super || valid_authenticity_token?(session, request.headers['X-XSRF-TOKEN'])
    end

end
