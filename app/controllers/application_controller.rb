require "application_responder"

class ApplicationController < ActionController::Base


  before_filter :http_basic_authenticate

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


  rescue_from SecurityError do |exception|
    redirect_to "/"
  end

  def new_session_path(scope)
    new_user_session_path
  end

  protected


    def verified_request?
      super || valid_authenticity_token?(session, request.headers['X-XSRF-TOKEN'])
    end

end
