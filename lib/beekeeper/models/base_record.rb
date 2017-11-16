class Beekeeper::BaseRecord < ActiveRecord::Base
  self.abstract_class = true
  establish_connection Import.global('config.beekeeper_database_url')
end
