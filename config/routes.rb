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
  resources :registers
  resources :equipments


  resources :devices do
    member do
      get :new_out
      get :edit_out
      get :new_in
      get :edit_in
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
    end
  end

  resources :metering_service_provider_contracts
  resources :metering_point_operator_contracts
  resources :electricity_supplier_contracts
  resources :servicing_contracts
  resources :contracting_parties

  resources :assets

  resources :organizations

  resources :comments, :only => [:create, :destroy]

  resources :startpage

  resources :stream


  resources :wizard_consumers do
    collection do
      get :complete_user
      put :complete_user_update

      get :contracting_party_legal_entity
      put :contracting_party_legal_entity_update

      get :contracting_party_address
      put :contracting_party_address_update

      get :contracting_party_organization
      put :contracting_party_organization_update

      get :contracting_party_organization_address
      put :contracting_party_organization_address_update

      get :location_address
      put :location_address_update

      get :location_habitation
      put :location_habitation_update

      get :location_metering_point
      put :location_metering_point_update

      get :metering_point_current_supplier
      put :metering_point_current_supplier_update

      get :contract_forecast
      put :contract_forecast_update

      get :contracting_party_bank_account
      put :contracting_party_bank_account_update

      get :complete_contract
      put :complete_contract_update
    end
  end


  resources :wizard_producers do
    collection do
      get :complete_user
      put :complete_user_update

      get :contracting_party_legal_entity
      put :contracting_party_legal_entity_update

      get :contracting_party_address
      put :contracting_party_address_update

      get :contracting_party_organization
      put :contracting_party_organization_update

      get :contracting_party_organization_address
      put :contracting_party_organization_address_update

      get :location_address
      put :location_address_update

      get :location_habitation
      put :location_habitation_update

      get :location_metering_point
      put :location_metering_point_update

      get :metering_point_current_supplier
      put :metering_point_current_supplier_update

      get :contract_forecast
      put :contract_forecast_update

      get :contracting_party_bank_account
      put :contracting_party_bank_account_update

      get :complete_contract
      put :complete_contract_update

      get :power_generator
      put :power_generator_update

      get :contracting_party_taxation
      put :contracting_party_taxation_update
    end
  end

  resources :wizard_metering_points do
    collection do
      get :metering_point
      put :metering_point_update

      get :meter
      put :meter_update
    end
  end


  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"

  #root controller: 'profiles', action: 'redirect_to_current_user'
  root to: "startpage#index"

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
