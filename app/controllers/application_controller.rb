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

  serialization_scope :current_user

  def after_sign_in_path_for(resource)

    sign_in_url = url_for(:action => 'new', :controller => 'sessions', :only_path => false, :protocol => 'http')
    if request.referer == sign_in_url
      super
    else
      stored_location_for(resource) || request.referer || root_path
    end

    current_user.profile
  end

  def current_user
    UserDecorator.decorate(super) unless super.nil?
  end

  def initialize_gon
    if user_signed_in?
      Gon.global.push({current_user_id: current_user.id})
    end
  end


end
