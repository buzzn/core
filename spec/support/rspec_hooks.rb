RSpec.configure do |config|

  #
  # BEFORE
  #

  config.before(:suite) do
    puts 'seeds: for specs'
    require_relative '../../db/support/database_emptier'
    DatabaseEmptier.call
    load 'db/setup_data/specs.rb'
  end

  #
  # AFTER
  #

  config.append_after(:each) do |spec|
    require_relative '../../lib/buzzn/services/redis_cache'
    require_relative '../../lib/buzzn/services/redis_sidekiq'
    Services::RedisCache.current.flushall
    Services::RedisSidekiq.current.flushall
  end
end
