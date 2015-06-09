Buzzn::Application.routes.draw do
  use_doorkeeper
  mount API::Base, at: "/"
  mount GrapeSwaggerRails::Engine, at: "/api"
  mount CookieAlert::Engine => "/cookie-alert"

  require 'sidekiq/web'
  authenticate :user, lambda { |user| user.has_role?(:admin) } do
    mount Sidekiq::Web => '/sidekiq'
  end

  devise_for :users, controllers: {
    registrations: 'users/registrations',
    invitations: 'users/invitations'
  }

  resources :profiles do
    member do
      get :redirect_to_current_user
    end
  end

  resources :metering_points do
    member do
      get :chart
      get :latest_fake_data
      get :edit_users
      get :edit_devices
      get :update_parent
      get :latest_power
    end
  end



  resources :meters
  resources :equipments
  resources :devices
  resources :contracts, :except => :show
  resources :contracting_parties
  resources :bank_accounts
  resources :organizations
  resources :comments, :only => [:create, :destroy]
  resources :stream
  resources :addresses



  resources :dashboards do
    member do
      get :add_metering_point
      get :remove_metering_point
      get :display_metering_point_in_series
      get :remove_metering_point_from_series
    end
  end

  resources :friendships do
    member do
      get :cancel
    end
  end

  resources :friendship_requests do
    member do
      get :accept
      get :reject
    end
  end

  resources :group_metering_point_requests do
    member do
      get :accept
      get :reject
    end
  end


  resources :groups do
    resources :metering_points, only: [:index]
    member do
      get :cancel_membership
      get :bubbles_data
      get :chart
      get :kiosk
    end
  end


  root controller: 'profiles', action: 'redirect_to_current_user'

end
