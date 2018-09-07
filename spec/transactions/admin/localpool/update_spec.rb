require_relative '../../shared_nested_address'
require 'buzzn/transactions/admin/localpool/update'

describe Transactions::Admin::Localpool::Update do

  entity(:operator) { create(:account, :buzzn_operator) }
  entity!(:localpool) { create(:group, :localpool) }

  entity(:resource) { Admin::LocalpoolResource.all(operator).first }

  it_behaves_like 'update with address', Transactions::Admin::Localpool::Update.new, :resource, name: 'takakari'
  it_behaves_like 'update without address', Transactions::Admin::Localpool::Update.new, :resource, name: 'takari'

end
