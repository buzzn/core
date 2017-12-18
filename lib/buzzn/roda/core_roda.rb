require 'sequel'
require 'rack-timeout'
require_relative 'common_roda'
require_relative 'plugins/terminal_verbs'

class CoreRoda < CommonRoda

  include Import.args[:env, 'service.health']

  use Rack::CommonLogger, Buzzn::Logger.new(CoreRoda)

  use Rack::Timeout, service_timeout: 29

  use Rack::Cors, debug: Rails.env != 'production' do
    allow do
      origins(*%r(#{Import.global('config.cors')}))
      resource '/*', headers: :any, methods: [:get, :post, :patch, :put, :delete, :options], expose: 'Authorization'
    end
  end

  plugin :terminal_verbs

  # adds /heartbeat endpoint
  plugin :heartbeat

  route do |r|

    logger.info(r.inspect)

    ActiveRecord::Base.connection_pool.with_connection do
      r.on 'api' do
        r.on 'display' do
          r.run Display::Roda
        end

        r.on 'admin' do
          r.run Admin::Roda
        end

        r.on 'me' do
          r.run Me::Roda
        end

        r.on 'utils' do
          r.run Utils::Roda
        end
      end

      r.get! 'health' do
        info = health.info
        r.response.headers['content_type'] = 'application/json'
        unless info[:healthy]
          logger.error(info.to_yaml.strip)
          r.response.status = 503
        end
        health.info.to_json
      end
    end
  end
end
