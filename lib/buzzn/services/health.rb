require_relative '../services'
require_relative '../types/maintenance_mode'
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
      redis: redis?,
    }
    result[:healthy] = result.slice(:database, :redis).values.all? { |v| v == 'alive' }
    result
  end

end
