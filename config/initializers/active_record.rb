require 'active_record'

ActiveRecord::Base.schema_format = :sql
ActiveRecord::Base.raise_in_transactional_callbacks = true
