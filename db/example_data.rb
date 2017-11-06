FactoryGirl.definition_file_paths = %w(db/factories)
FactoryGirl.find_definitions
include FactoryGirl::Syntax::Methods

#
# All files with sample data to load.
# Order is important as the files reference each other!
#
SAMPLES_TO_LOAD = %i(
  persons
  localpools
  contracts
  meters
  registers
  brokers
)

#
# This module provides access to all samples that have already been created.
# Examples: SampleData.localpools.people_power, SampleData.meters.grid, etc.
#
module SampleData
  SAMPLES_TO_LOAD.each { |type| mattr_accessor type }
end

# load files
SAMPLES_TO_LOAD.each do |type|
  Buzzn::Logger.root.info("seeds: loading sample data for #{type}")
  require_relative "example_data/#{type}"
end
