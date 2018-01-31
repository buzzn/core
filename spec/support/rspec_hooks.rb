RSpec.configure do |config|

  #
  # BEFORE
  #

  config.before(:suite) do
    puts "seeds: for specs"
    require_relative '../../db/support/database_emptier'
    DatabaseEmptier.call
    load 'db/setup_data/specs.rb'
  end

  #
  # AFTER
  #

  config.append_after(:each) do |spec|
    Redis.current.flushall
  end
end
