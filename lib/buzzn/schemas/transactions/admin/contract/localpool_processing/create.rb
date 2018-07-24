require_relative '../localpool_processing'
require_relative '../../../../constraints/contract/base'

Schemas::Transactions::Admin::Contract::LocalpoolProcessing::Create = Schemas::Support.Form(Schemas::Constraints::Contract::Base) do
end
