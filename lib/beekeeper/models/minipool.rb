require_relative '../../beekeeper'
require_relative './minipool/concerns/import_warnings'

class Beekeeper::Minipool::BaseRecord < ActiveRecord::Base

  self.abstract_class = true
  establish_connection Import.global('config.minipool_database_url')
  include Beekeeper::ImportWarnings

end
