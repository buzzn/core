# We're really lucky we can reuse the beekeeper import's billing generator here.
# Once we remove the beekeeper import, move the relevant code here and simplify, or create the billings by hand.
module Beekeeper; module Importer; end; end
require 'beekeeper/importer/generate_billings'
require 'beekeeper/importer/support/localpool_log'

beekeeper_account = Account::Base.where(:email => 'dev+beekeeper@buzzn.net').first
if beekeeper_account.nil?
  raise 'please create a beekeeper account first'
end

billing_generator = Beekeeper::Importer::GenerateBillings.new(LocalpoolLog.new(SampleData.localpools.people_power), beekeeper_account)
billing_generator.run(SampleData.localpools.people_power, [])
