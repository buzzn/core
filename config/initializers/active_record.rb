require 'active_record'

ActiveRecord::Base.schema_format = :sql
ActiveRecord::Base.raise_in_transactional_callbacks = true

if (ENV['RACK_ENV'] || 'development') == 'development'
    ActiveRecord::Base.logger = ActiveSupport::Logger.new(STDOUT)
    ActiveRecord::Base.logger.level = ::Logger::DEBUG
end