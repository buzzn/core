require File.expand_path('../buzzn', __FILE__)
require File.expand_path('../boot', __FILE__)

require 'rails/all'

## https://docs.newrelic.com/docs/agents/ruby-agent/features/garbage-collection#gc_setup
if ENV['GC_PROFILER_ENABLED'] == 'true'
  puts 'Enabling GC profiler'
  GC::Profiler.enable
end

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, ENV['RACK_ENV'])

$LOAD_PATH << './lib'

require 'buzzn/logger'
