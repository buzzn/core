require File.expand_path('../boot', __FILE__)

require File.expand_path('../../lib/buzzn/services/boot', __FILE__)
require 'rails/all'
require 'sprockets/es6'


# TODO https://github.com/drapergem/draper/issues/644
require 'draper'
Draper::Railtie.initializers.delete_if {|initializer| initializer.name == 'draper.setup_active_model_serializers' }

## https://docs.newrelic.com/docs/agents/ruby-agent/features/garbage-collection#gc_setup
GC::Profiler.enable

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

module Buzzn
  class Application < Rails::Application

    config.exceptions_app = self.routes

    config.active_record.raise_in_transactional_callbacks = true # TODO: remove

    tap do |config|
      domains = case Rails.env
                when 'development'
                  %r(http://(localhost:[0-9]*|127.0.0.1:[0-9]*))
                when 'staging'
                  %r(https://(staging|develop)-[a-z0-9]*.buzzn.io)
                when 'production'
                  %r(https://[a-z0-9]*.buzzn.io)
                else
                  raise 'unknonw rails environment'
                end
      config.middleware.insert_before 0, 'Rack::Cors' do
        allow do
          origins *domains
          ['/api/*', '/oauth/*'].each do |path|
            resource path, headers: :any, methods: [:get, :post, :patch, :put, :delete, :options]
          end
        end
      end
    end

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'
    config.time_zone = 'Berlin'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    config.i18n.default_locale = :de

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password, :password_confirmation]

    config.assets.paths << Rails.root.join('app', 'assets', 'fonts')


    config.generators do |g|
      g.orm :active_record
      g.test_framework :rspec, spec: true, fixture: false
      g.stylesheets = false
      g.javascripts = false
      g.helper      = false
    end

    config.middleware.use Rack::GoogleAnalytics, :tracker => Rails.application.secrets.google_analytics

    config.middleware.delete Rack::Lock

    config.autoload_paths << "#{Rails.root}/lib"

    if ENV['AWS_ACCESS_KEY'].present?
      config.x.fog.storage_opts   = { provider: 'AWS', aws_access_key_id: ENV['AWS_ACCESS_KEY'], aws_secret_access_key: ENV['AWS_SECRET_KEY'], region: ENV['AWS_REGION'] }
      config.x.fog.directory_opts = { key: ENV['AWS_BUCKET'], public: false }
    else
      config.x.fog.storage_opts   = { provider: 'Local', local_root: 'tmp' }
      config.x.fog.directory_opts = { key: 'files' }
    end

    config.x.templates_path = Rails.root.join('app', 'templates')

    config.before_initialize do
      logger = ::Logger.new(STDERR)
      if Rails.env == 'development'
        logger.formatter = proc { |_, _, _, msg| "#{msg}\n" }
      else
        logger.formatter = proc { |l, _, _, msg| "#{msg}\n" if l != 'DEBUG' }
      end
      Buzzn::Logger.root = logger
      Buzzn::Services::Boot.before_initialize
      Buzzn::Logger.root = Rails.logger
    end
  end
end
