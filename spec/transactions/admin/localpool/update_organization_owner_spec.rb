require_relative '../../shared_nested_address'
require_relative '../../shared_nested_person'
require 'buzzn/transactions/admin/localpool/create_organization_owner'

describe Transactions::Admin::Localpool::UpdateOrganizationOwner do

  entity(:organization) { create(:organization) }

  entity!(:localpool) { create(:group, :localpool, owner: organization) }

  entity(:operator) { create(:account, :buzzn_operator) }

  entity(:resource) { Admin::LocalpoolResource.all(operator).first.owner }

  it_behaves_like 'update without address', Transactions::Admin::Localpool::UpdateOrganizationOwner.new, :resource, name: 'Zappa-For-President'
  it_behaves_like 'update with address', Transactions::Admin::Localpool::UpdateOrganizationOwner.new, :resource, name: 'The Big Blue Coop', additional_legal_representation: 'Jaques Mayol, Enzo Majorca'

  context 'contact' do
    it_behaves_like 'update without person', Transactions::Admin::Localpool::UpdateOrganizationOwner.new, :resource, :contact, name: 'Zappa-For-President-Forever'
    it_behaves_like 'update with person without address', Transactions::Admin::Localpool::UpdateOrganizationOwner.new, :resource, :contact, name: 'Elvis-Lives-Forever'
    it_behaves_like 'update with person with address', Transactions::Admin::Localpool::UpdateOrganizationOwner.new, :resource, :contact, name: 'Mamas-and-Papas'

  end

  context 'legal_representation' do
    it_behaves_like 'update without person', Transactions::Admin::Localpool::UpdateOrganizationOwner.new, :resource, :legal_representation, name: 'Zappa-For-President-Again-And-Again'

    it_behaves_like 'update with person without address', Transactions::Admin::Localpool::UpdateOrganizationOwner.new, :resource, :legal_representation, name: 'Elvis-Lives-Again-And-Again'
  end
end
