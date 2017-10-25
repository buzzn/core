# Load the Rails application.
require File.expand_path('../application', __FILE__)

Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

# Initialize the Rails application.
Buzzn::Application.initialize!


APP_VERSION = "unknown" # `git rev-parse HEAD`
