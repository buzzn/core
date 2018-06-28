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
    Import.global('services.redis_cache').flushall
    Import.global('services.redis_sidekiq').flushall
  end
end
