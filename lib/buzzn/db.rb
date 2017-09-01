require 'sequel'
module Buzzn
  DB = Sequel.connect(ActiveRecord::Base.connection_config.dup.tap do |c|
                        c[:user] = c.delete(:username) || ENV['PG_USER'] || ENV['USER']
  end)
end

# needed for html view of rodauth
DB = Buzzn::DB
