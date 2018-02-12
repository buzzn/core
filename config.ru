# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/buzzn', __FILE__)

run CoreRoda.app
# can not freeze as active_support does funny things
#run CoreRoda.freeze.app
