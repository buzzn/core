require 'buzzn/schemas/transactions/organization/update'
require_relative '../shared_nested_address'

describe 'Schemas::Transactions::Organization::Update' do

  entity(:organization) { create(:organization, :with_address) }

  entity!(:address) { organization.address }

  subject { Schemas::Transactions::Organization.update_for(organization) }

  context 'with address' do

    before { organization.update!(address: address) }

    it_behaves_like 'update with nested address', name: 'Stairways To Heaven'

  end

  context 'without address' do

    before { organization.update!(address: nil) }

    it_behaves_like 'update without nested address', name: 'Zombie-Powder-Poo'

  end

end
