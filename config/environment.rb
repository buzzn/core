# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
Buzzn::Application.initialize!


APP_VERSION = `git rev-parse HEAD`