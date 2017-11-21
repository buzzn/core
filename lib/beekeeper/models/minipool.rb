require_relative '../../beekeeper'
class Beekeeper::Minipool::BaseRecord < ActiveRecord::Base
  self.abstract_class = true
  establish_connection Import.global('config.minipool_database_url')
end
