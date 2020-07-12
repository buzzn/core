require 'sequel'

ActiveRecord::Base.establish_connection Import.global('config.database_url')


module Buzzn

  DB = Sequel.connect(ActiveRecord::Base.connection_config.dup.tap do |c|
      c[:user] = c.delete(:username)
      if Rake.application.top_level_tasks.include?("db:create")
        # do not connect to the database when trying to create it
        c[:test] = false
      end
   end)

end

# needed for html view of rodauth
DB = Buzzn::DB
