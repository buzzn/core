require_relative '../../shared_nested_address'
require 'buzzn/transactions/admin/generic/update_nested_person'

describe Transactions::Admin::Generic::UpdateNestedPerson do

  let(:localpool) { create(:group, :localpool) }

  let(:operator) { create(:account, :buzzn_operator) }

  let(:customer_person) { create(:person) }

  let!(:contract) do
    create(:contract, :localpool_powertaker,
           customer: customer_person,
           contractor: Organization::Market.buzzn,
           localpool: localpool)
  end

  let(:localpool_resource) { Admin::LocalpoolResource.all(operator).first }
  let(:localpool_owner_resource) { localpool_resource.owner }
  let(:localpool_power_taker_contract_customer_resource) do
    localpool_resource.localpool_power_taker_contracts.first.customer
  end

  [:localpool_power_taker_contract_customer_resource, :localpool_owner_resource].each do |r|
    context r.to_s do
      it_behaves_like 'update with address', Transactions::Admin::Generic::UpdateNestedPerson.new, first_name: 'Martin' do
        let(:resource) { send(r) }
      end

      it_behaves_like 'update without address', Transactions::Admin::Generic::UpdateNestedPerson.new, last_name: 'Luther King' do
        let(:resource) { send(r) }
      end
    end
  end

end
