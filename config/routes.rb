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
    registrations:      'users/registrations',
    invitations:        'users/invitations',
    omniauth_callbacks: 'users/omniauth_callbacks'
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
      get :edit_readings
      get :update_parent
      get :latest_power
      get :get_scores
    end
  end



  resources :meters, :except => :show
  resources :equipments
  resources :devices
  resources :contracts, :except => :show
  resources :contracting_parties
  resources :bank_accounts
  resources :organizations
  resources :comments, :only => [:create, :destroy]
  resources :stream
  resources :addresses
  resources :readings



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
      get :get_scores
      get :send_invitations
      put :send_invitations_update
    end
  end

  resources :wizard_metering_points do
    collection do
      get :metering_point
      put :metering_point_update

      get :meter
      put :meter_update

      get :contract
      put :contract_update
    end
  end

  resources :wizard_meters do
    collection do
      get :meter
      put :meter_update

      get :contract
      put :contract_update
    end
  end


  root controller: 'profiles', action: 'redirect_to_current_user'

end
