require_relative '../../shared_nested_address'
require 'buzzn/transactions/admin/localpool/create'

describe Transactions::Admin::Localpool::Create do

  entity(:operator) { create(:account, :buzzn_operator) }

  entity(:resource) { Admin::LocalpoolResource.all(operator) }

  it_behaves_like 'create without address', Transactions::Admin::Localpool::Create.new, Admin::LocalpoolResource, name: 'takari'

  it_behaves_like 'create with address', Transactions::Admin::Localpool::Create.new, Admin::LocalpoolResource, name: 'akari'

end
