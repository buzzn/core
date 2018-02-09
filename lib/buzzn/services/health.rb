require_relative '../services'

class Services::Health

  include Import['services.redis',
                 'config.heroku_slug_commit',
                 'config.heroku_release_created_at']

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
    redis.ping == 'PONG' ? 'alive' : 'dead'
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
      version: heroku_slug_commit,
      timestamp: heroku_release_created_at
    }
  end

  def info
    result = {
      build: build_info,
      database: database?,
      redis: redis?,
    }
    result[:healthy] = result.slice(:database, :redis).values.all? { |v| v == 'alive' }
    result
  end

end
