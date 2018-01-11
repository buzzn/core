RSpec.configure do |config|

  #
  # BEFORE
  #

  config.before(:suite) do
    puts "seeds: for specs"
    load 'db/setup_data/specs.rb'
  end

  config.before(:context) do
    first = true
    ActiveRecord::Base.connection.tables.each do |table|
      next if table.match(/\Aschema_migrations\Z/)
      klass = table.singularize.camelize.safe_constantize
      if klass
        if klass.class.is_a?(Module)
          klass = (klass.const_get 'Base' rescue nil)
        end
        if klass
          if (klass == PersonsRole && klass.count != 4) ||
             (klass == Role && klass.count != 4) ||
             (klass == Account::Base && klass.count != 4) ||
             (klass == Person && klass.count != 3) ||
             (klass == Organization && klass.count != 7) ||
             (klass != Organization && klass != PersonsRole && klass != Role && klass != Person && klass != Account::Base && klass.count > 0)
            if first
              first = false
              warn '-' * 80
              warn 'DB cleaning failed'
            end
            warn "#{klass}: #{klass.count}"
          end
        end
      end
    end
  end

  #
  # AFTER
  #

  config.after(:suite) do
    require_relative '../../db/support/database_emptier'
    DatabaseEmptier.call
  end

  config.after(:context) do
#    Mongoid.purge!
  end

  config.append_after(:each) do |spec|
    Redis.current.flushall
  end
end
