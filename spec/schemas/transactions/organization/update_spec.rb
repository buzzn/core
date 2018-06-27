require 'buzzn/schemas/transactions/organization/update'
require_relative '../shared_nested_address'

describe 'Schemas::Transactions::Organization::Update' do

  context 'with address' do

    subject { Schemas::Transactions::Organization.update_with_address }

    it_behaves_like 'update with nested address', name: 'Stairways To Heaven'

  end

  context 'without address' do

    subject { Schemas::Transactions::Organization.update_without_address }

    it_behaves_like 'update without nested address', name: 'Zombie-Powder-Poo'

  end

end
