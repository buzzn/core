require File.expand_path('../buzzn', __FILE__)
require File.expand_path('../boot', __FILE__)

require 'rails/all'

## https://docs.newrelic.com/docs/agents/ruby-agent/features/garbage-collection#gc_setup
if ENV['GC_PROFILER_ENABLED'] == 'true'
  puts "Enabling GC profiler"
  GC::Profiler.enable
end

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

$LOAD_PATH << './lib'

require 'buzzn/logger'

module Buzzn
  class Application < Rails::Application

#    config.active_record.schema_format = :sql

    config.exceptions_app = self.routes

    #config.active_record.raise_in_transactional_callbacks = true # TODO: remove

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'
    config.time_zone = 'UTC'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    #config.i18n.default_locale = :de

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password, :password_confirmation]

    config.generators do |g|
      g.orm :active_record
      g.test_framework :rspec, spec: true, fixture: false
      g.stylesheets = false
      g.javascripts = false
      g.helper      = false
    end

    # We don't use the Rails cache, all caching is directly from roda to redis.
    config.cache_store = nil

    # Disable Rails's static asset server (Apache or nginx will already do this).
    config.serve_static_files = false

    # we don't use the asset pipeline, this application is API-only.
    config.assets.enabled = false

    # details: http://guides.rubyonrails.org/api_app.html
    config.api_only = true
  end
end
