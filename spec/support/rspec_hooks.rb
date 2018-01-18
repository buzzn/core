RSpec.configure do |config|

  #
  # BEFORE
  #

  config.before(:suite) do
    puts "seeds: for specs"
    load 'db/setup_data/specs.rb'
  end

  #
  # AFTER
  #

  config.after(:suite) do
    require_relative '../../db/support/database_emptier'
    DatabaseEmptier.call
  end

  config.append_after(:each) do |spec|
    Redis.current.flushall
  end
end
