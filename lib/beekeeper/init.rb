require_relative '../beekeeper'
require 'beekeeper/string_cleaner'
require_relative 'models/minipool'
require_relative 'models/buzzn'

Dir.glob('lib/beekeeper/models/{minipool,buzzn}/*.rb').each do |file|
  require file
end

# wire up invariant with AR and raise error on invalid in before_save
require 'buzzn/schemas/support/enable_dry_validation'
require 'buzzn/types/discovergy'
require 'beekeeper/meter_registry'

Dir.glob('lib/beekeeper/importer/*.rb').each { |importer| require importer }

require_relative 'import'
