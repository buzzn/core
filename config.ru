# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)

run CoreRoda.app
# can not freeze as active_support does funny things
#run CoreRoda.freeze.app

# In development, serve uploaded files with rack
if ENV['RACK_ENV'] == 'development'
  use Rack::Static, root: "public", urls: ["/uploads"]
end
