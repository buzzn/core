require_relative '../beekeeper'
require 'beekeeper/importer/support/string_cleaner'
require_relative 'models/minipool'
require_relative 'models/buzzn'

Dir.glob('lib/beekeeper/models/{minipool,buzzn}/*.rb').each do |file|
  require file
end

# wire up invariant with AR and raise error on invalid in before_save
require 'buzzn/schemas/support/enable_dry_validation'
require 'buzzn/types/discovergy'
require 'beekeeper/importer/support/meter_registry'
require 'beekeeper/importer/support/localpool_log'
require 'beekeeper/importer/support/json_log_writer'

Dir.glob('lib/beekeeper/importer/*.rb').each { |importer| require importer }

require_relative 'import'
