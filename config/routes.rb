Buzzn::Application.routes.draw do
  default_url_options host: Rails.application.secrets.hostname

  use_doorkeeper do
    controllers :applications => 'oauth/applications'
  end

  #require 'sidekiq/web'
  #authenticate :user, lambda { |user| user.has_role?(:admin) } do
  #  mount Sidekiq::Web => '/sidekiq'
  #end

  devise_for :users, controllers: {
    registrations:      'users/registrations',
    invitations:        'users/invitations'
  }

end
