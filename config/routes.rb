Buzzn::Application.routes.draw do
  use_doorkeeper
  mount API::Base, at: "/"
  mount GrapeSwaggerRails::Engine, at: "/api"

  require 'sidekiq/web'
  authenticate :user, lambda { |user| user.has_role?(:admin) } do
    mount Sidekiq::Web => '/sidekiq'
  end

  devise_for :users, controllers: { registrations: 'users/registrations' }

  resources :profiles do
    member do
      get :redirect_to_current_user
    end
  end

  resources :metering_points do
    member do
      get :chart
      get :latest_slp
      get :edit_users
      get :edit_devices
      get :update_parent
    end
  end



  resources :meters
  resources :equipments
  resources :devices
  resources :contracts
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
    end
  end


  root controller: 'profiles', action: 'redirect_to_current_user'

end
