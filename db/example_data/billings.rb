# We're really lucky we can reuse the beekeeper import's billing generator here.
# Once we remove the beekeeper import, move the relevant code here and simplify, or create the billings by hand.
module Beekeeper; module Importer; end; end
require 'beekeeper/importer/generate_billings'

billing_generator = Beekeeper::Importer::GenerateBillings.new(Logger.new(STDOUT))
billing_generator.run(SampleData.localpools.people_power)
