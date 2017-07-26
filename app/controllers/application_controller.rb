require "application_responder"

class ApplicationController < ActionController::Base
  self.responder = ApplicationResponder
  respond_to :html


  before_filter :http_basic_authenticate
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


  def authenticate_user!
    @current_user = Account::Base.where(id: session['account_id']).first
    redirect_to '/session/login?redirect=/admin' unless @current_user
  end

  rescue_from SecurityError do |exception|
    redirect_to "/"
  end

  def authenticate_admin_user!
    unless current_user.person.has_role?(:admin)
      @current_user = nil
      session['account_id']=nil
      redirect_to '/session/login?recirect=/admin'
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
