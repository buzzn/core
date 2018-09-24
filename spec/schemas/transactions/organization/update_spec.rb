require 'buzzn/schemas/transactions/organization/update'
require_relative '../shared_nested_address'
require_relative '../shared_nested_person'

describe 'Schemas::Transactions::Organization::Update' do

  entity(:organization) do
    create(:organization,
           :with_address,
           :with_contact,
           :with_legal_representation)
  end

  entity!(:address) { organization.address }
  entity!(:contact) { organization.contact }
  entity!(:legal_representation) { organization.legal_representation }

  subject { Schemas::Transactions::Organization.update_for(organization) }

  context 'with address' do

    before { organization.update!(address: address) }

    it_behaves_like 'update with nested address', name: 'Stairways To Heaven'

  end

  context 'without address' do

    before { organization.update!(address: nil) }

    it_behaves_like 'update without nested address', name: 'Zombie-Powder-Poo'

  end

  context 'with contact', skip: true do

    before { organization.update!(contact: contact) }

    it_behaves_like 'update with nested person', :contact, name: 'Stairways To Heaven'

    it_behaves_like 'update with nested person and address', :contact, name: 'Zombie-Powder-Poo'

  end

  context 'without contact', skip: true do

    before { organization.update!(contact: nil) }

    it_behaves_like 'update without nested person', :contact, name: 'Zombie-Powder-Poo'
    it_behaves_like 'update without nested person and address', :contact, name: 'Zombie-Powder-Poo'

  end

  context 'without legal_representation', skip: true do

    before { organization.update!(legal_representation: nil) }

    it_behaves_like 'update without nested person', :legal_representation, name: 'Zombie-Powder-Poo'
    it_behaves_like 'update without nested person and address', :legal_representation, name: 'Zombie-Powder-Poo'

  end

  context 'with legal_representation', skip: true do

    before { organization.update!(legal_representation: legal_representation) }

    it_behaves_like 'update with nested person', :legal_representation, name: 'Stairways To Heaven'
    it_behaves_like 'update with nested person and address', :legal_representation, name: 'Zombie-Powder-Poo'

  end

end
