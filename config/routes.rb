Buzzn::Application.routes.draw do
  default_url_options host: Rails.application.secrets.hostname
end
