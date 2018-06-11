# Set up gems listed in the Gemfile.
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)

require 'bundler/setup' if File.exists?(ENV['BUNDLE_GEMFILE'])

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, ENV['RACK_ENV'])

## https://docs.newrelic.com/docs/agents/ruby-agent/features/garbage-collection#gc_setup
if ENV['GC_PROFILER_ENABLED'] == 'true'
  puts 'Enabling GC profiler'
  GC::Profiler.enable
end
