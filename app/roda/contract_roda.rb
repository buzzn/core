class ContractRoda < BaseRoda

  route do |r|

    r.on :id do |id|
      contract = Contract::BaseResource.retrieve(current_user, id)

      r.get! do
        contract
      end

      r.get! 'contractor' do |id|
        contract.contractor!
      end

      r.get! 'customer' do |id|
        contract.customer!
      end
    end
  end
end
