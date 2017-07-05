# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)

# You need to manually start the agent
NewRelic::Agent.manual_start

run CoreRoda.app
# can not freeze as active_support does funny things
#run CoreRoda.freeze.app
