require_relative '../beekeeper'
require_relative 'models/minipool'
require_relative 'models/buzzn'

Dir.glob(Rails.root.join('lib/beekeeper/models/{minipool,buzzn}/*.rb')).each do |file|
  require file
end

require_relative 'import'
