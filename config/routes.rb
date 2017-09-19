Buzzn::Application.routes.draw do
  default_url_options host: Rails.application.secrets.hostname

  use_doorkeeper do
    controllers :applications => 'oauth/applications'
  end



end
