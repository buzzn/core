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
             (klass == Account::Base && klass.count != 3) ||
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
    ActiveRecord::Base.connection.disable_referential_integrity do
      ActiveRecord::Base.descendants.each do |model|
        begin
          model.delete_all unless model.abstract_class?
        rescue => e
          puts "Failed to delete all #{model} records: #{e.message}"
        end
      end
    end
  end

  config.after(:context) do
    Mongoid.purge!
  end

  config.append_after(:each) do |spec|
    Redis.current.flushall
    Rails.cache.clear
  end
end