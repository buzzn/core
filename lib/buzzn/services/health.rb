module Buzzn::Services

  class Health
    include Import.args['service.redis']

    def database?
      if ActiveRecord::Base.connection.active?
        'alive'
      else
        'dead'
      end
    rescue
      'errored'
    end

    def redis?
      redis.ping == "PONG" ? 'alive' : 'dead'
    rescue
      'dead'
    end

    def mongo?
      # use connection from one of our mongo model
      if Reading::Continuous.mongo_client.cluster.servers.first.connectable?
        'alive'
      else
        'dead'
      end
    rescue
      'errored'
    end

    def build_info
      {
        version: Import.global('config.heroku_slug_commit'),
        timestamp: Import.global('config.heroku_release_created_at')
      }
    end

    def info
      result = {
        build: build_info,
        database: database?,
        redis: redis?,
        mongo: mongo?
      }
      result[:healthy] = result.slice(:database, :redis, :mongo).values.all? { |v| v == 'alive' }
      result
    end
  end
end
