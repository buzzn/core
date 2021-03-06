require 'sequel'
require 'rack/cors'

require_relative 'common_roda'
require_relative 'plugins/terminal_verbs'

class CoreRoda < CommonRoda

  include Import.args[:env, 'services.health', 'services.object_space_metric']

  # In development, serve uploaded files with rack
  use Rack::Static, root: 'public', urls: ['/uploads']

  use Rack::CommonLogger, logger

  use Rack::Cors, debug: logger.debug? do
    allow do
      origins(*%r(#{Import.global('config.cors')}))
      resource '/*', headers: :any, methods: [:get, :post, :patch, :put, :delete, :options], expose: 'Authorization'
    end
  end

  plugin :terminal_verbs

  # adds /heartbeat endpoint
  plugin :heartbeat

  route do |r|

    object_space_metric.non_blocking_sample
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

        r.on 'website' do
          r.run Website::Roda
        end

      end

      r.get! 'health' do
        info = health.info
        r.response.headers['Content-Type'] = 'application/json'
        unless info[:healthy]
          logger.error(info.to_yaml.strip)
          r.response.status = 503
        end
        health.info.to_json
      end
    end
  end

end
