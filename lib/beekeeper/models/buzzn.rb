require_relative '../../beekeeper'
class Beekeeper::Buzzn::BaseRecord < ActiveRecord::Base

  self.abstract_class = true
  establish_connection Import.global('config.buzzn_database_url')

end
