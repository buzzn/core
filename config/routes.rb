Buzzn::Application.routes.draw do

  default_url_options host: Rails.application.secrets.hostname

  use_doorkeeper do
    controllers :applications => 'oauth/applications'
  end

  mount API::Base, at: "/"
  mount GrapeSwaggerRails::Engine, at: "/api"
  mount CookieAlert::Engine => "/cookie-alert"

  require 'sidekiq/web'
  authenticate :user, lambda { |user| user.has_role?(:admin) } do
    mount Sidekiq::Web => '/sidekiq'
  end

  #post 'pusher/auth', to: 'pusher#auth'


  devise_for :users, controllers: {
    registrations:      'users/registrations',
    invitations:        'users/invitations',
    omniauth_callbacks: 'users/omniauth_callbacks'
  }


  resources :profiles do
    member do
      get :redirect_to_current_user
      get :check_destroyable
      put :read_new_badge_notifications
      get :edit_notifications
      put :edit_notifications_update
    end
  end
  resources :access_tokens

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
      get :remove_members
      put :remove_members_update
      get :send_invitations
      put :send_invitations_update
      get :chart_comments
      get :add_manager
      put :add_manager_update
      put :remove_manager_update
      get :widget
      get :edit_notifications
      put :edit_notifications_update
      get :get_reading
      get :get_reading_update
    end
  end



  resources :meters, :except => :show
  match 'meters/validate' => 'meters#validate', :via => :get

  resources :equipments
  resources :devices
  resources :contracts, :except => :show
  resources :contracting_parties
  resources :bank_accounts
  resources :organizations
  resources :stream
  resources :addresses
  resources :readings

  resources :conversations do
    member do
      put :unsubscribe
    end
  end

  resources :comments, :except => [:new, :index, :edit, :show, :update] do
    member do
      get :voted
    end
  end

  resources :activities, :except => [:new, :index, :edit, :show, :update, :create, :destroy] do
    member do
      get :voted
    end
  end


  resources :dashboards do
    member do
      get :add_metering_point
      put :add_metering_point_update
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

  resources :metering_point_user_requests do
    member do
      get :accept
      get :reject
    end
  end


  resources :groups do
    resources :metering_points, only: [:index]
    member do
      get :bubbles_data
      get :chart
      get :kiosk
      get :get_scores
      get :send_invitations
      put :send_invitations_update
      get :send_invitations_via_email
      put :send_invitations_via_email_update
      get :remove_members
      put :remove_members_update
      get :chart_comments
      get :add_manager
      put :add_manager_update
      put :remove_manager_update
      get :widget
      get :edit_notifications
      put :edit_notifications_update
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

      get :wizard
      put :wizard_update
    end
  end

  resources :wizard_meters do
    collection do
      get :meter
      put :meter_update

      get :contract
      put :contract_update

      get :edit_meter
      put :edit_meter_update

      get :edit_contract
      put :edit_contract_update

      get :wizard
      put :wizard_update

      get :edit_wizard
      put :edit_wizard_update
    end
  end

  %w( 403 404 422 500 ).each do |code|
    get code, :to => "errors#show", :code => code
  end

  root controller: 'profiles', action: 'redirect_to_current_user'



end
