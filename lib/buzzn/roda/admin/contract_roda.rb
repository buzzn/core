require_relative '../admin_roda'
module Admin
  class ContractRoda < BaseRoda
    plugin :shared_vars

    route do |r|

      contracts = shared[LocalpoolRoda::PARENT].contracts

      r.get! do
        contracts
      end

      r.on :id do |id|
        contract = contracts.retrieve(id)

        r.get! do
          contract
        end

        r.get! 'contractor' do
          contract.contractor!
        end

        r.get! 'customer' do
          contract.customer!
        end
      end
    end
  end
end
