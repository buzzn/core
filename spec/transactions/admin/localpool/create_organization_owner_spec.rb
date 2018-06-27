require_relative '../../shared_nested_address'
require_relative '../../shared_nested_person'
require 'buzzn/transactions/admin/localpool/create_organization_owner'

describe Transactions::Admin::Localpool::CreateOrganizationOwner do

  entity!(:localpool) { create(:group, :localpool) }

  entity(:operator) { create(:account, :buzzn_operator) }

  entity(:resource) { Admin::LocalpoolResource.all(operator).first }

  it_behaves_like 'create without address', Transactions::Admin::Localpool::CreateOrganizationOwner.new, Organization::GeneralResource, name: 'Zappa-For-President'
  it_behaves_like 'create with address', Transactions::Admin::Localpool::CreateOrganizationOwner.new, Organization::GeneralResource, name: 'Elvis-Lives'

  context 'contact' do
    it_behaves_like 'create without person', Transactions::Admin::Localpool::CreateOrganizationOwner.new, Organization::GeneralResource, :contact, name: 'Zappa-For-President-Forever'
    it_behaves_like 'create with person without address', Transactions::Admin::Localpool::CreateOrganizationOwner.new, Organization::GeneralResource, :contact, name: 'Elvis-Lives-Forever'
    it_behaves_like 'create with person with address', Transactions::Admin::Localpool::CreateOrganizationOwner.new, Organization::GeneralResource, :contact, name: 'Mamas-and-Papas'
  end

  context 'legal_representation' do
    it_behaves_like 'create without person', Transactions::Admin::Localpool::CreateOrganizationOwner.new, Organization::GeneralResource, :legal_representation, name: 'Zappa-For-President-Again-And-Again'

    it_behaves_like 'create with person without address', Transactions::Admin::Localpool::CreateOrganizationOwner.new, Organization::GeneralResource, :legal_representation, name: 'Elvis-Lives-Again-And-Again'
  end
end
