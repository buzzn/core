require "application_responder"

class ApplicationController < ActionController::Base
  self.responder = ApplicationResponder
  respond_to :html


  before_filter :http_basic_authenticate
  before_filter :set_paper_trail_whodunnit
  before_filter :authenticate_user!

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


  def after_sign_in_path_for(resource)

    # sign_in_url = url_for(:action => 'new', :controller => 'sessions', :only_path => false)

    # if request.referer == sign_in_url
    #   super
    # else
    #   stored_location_for(resource) || request.referer || root_path
    # end

    redirect = stored_location_for(resource) || request.referer || profile_path(resource.profile)
    if redirect =~ /\/users\/sign_in/
      redirect = profile_path(resource.profile)
    end
    redirect
  end


  # used for authority to make it possible to deal with logged out users
  def current_or_null_user
    if current_user == nil
      User.new
    else
      current_user
    end
  end


  def authority_forbidden(error)
    render "errors/403"
  end

  def new_session_path(scope)
    new_user_session_path
  end

  protected


    def verified_request?
      super || valid_authenticity_token?(session, request.headers['X-XSRF-TOKEN'])
    end

end
