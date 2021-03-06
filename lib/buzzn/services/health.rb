require_relative '../services'
require_relative '../types/maintenance_mode'
class Services::Health

  include Import['services.redis_cache',
                 'services.redis_sidekiq',
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

  def redis_cache?
    redis_cache.ping == 'PONG' ? 'alive' : 'dead'
  rescue
    'dead'
  end

  def redis_sidekiq?
    redis_sidekiq.ping == 'PONG' ? 'alive' : 'dead'
  rescue
    'dead'
  end

  def maintenace?
    CoreConfig.load(Types::MaintenanceMode).maintenance_mode
  rescue Dry::Struct::Error
    mode = Types::MaintenanceMode.new(maintenance_mode: :off)
    CoreConfig.store(mode)
    mode.maintenance_mode
  end

  def build_info
    {
      version: heroku_slug_commit,
      timestamp: heroku_release_created_at
    }
  end

  def info
    result = {
      maintenance: maintenace?,
      build: build_info,
      database: database?,
      redis_cache: redis_cache?,
      redis_sidekiq: redis_sidekiq?,
    }
    result[:healthy] = result.slice(:database, :redis_cache, :redis_sidekiq).values.all? { |v| v == 'alive' }
    result
  end

end
