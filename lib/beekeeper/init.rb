module Beekeeper; end

require_relative 'models/base_record'
Dir.glob(Rails.root.join('lib/beekeeper/models/*.rb')).each do |file|
  require file
end

require_relative 'import'
