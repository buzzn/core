require_relative '../../shared_nested_address'
require 'buzzn/transactions/admin/localpool/create_organization_owner'

describe Transactions::Admin::Localpool::CreateOrganizationOwner do

  entity!(:localpool) { create(:group, :localpool) }

  entity(:operator) { create(:account, :buzzn_operator) }

  entity(:resource) { Admin::LocalpoolResource.all(operator).first }

  it_behaves_like 'create without address', Transactions::Admin::Localpool::CreateOrganizationOwner.new, OrganizationResource, name: 'Zappa-For-President'
  it_behaves_like 'create with address', Transactions::Admin::Localpool::CreateOrganizationOwner.new, OrganizationResource, name: 'Elvis-Lives'

end
