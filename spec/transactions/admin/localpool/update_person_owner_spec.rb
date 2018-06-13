require_relative '../../shared_nested_address'
require 'buzzn/transactions/admin/localpool/update_person_owner'

describe Transactions::Admin::Localpool::UpdatePersonOwner do

  entity!(:localpool) { create(:group, :localpool) }

  entity(:operator) { create(:account, :buzzn_operator) }

  entity(:resource) { Admin::LocalpoolResource.all(operator).first.owner }

  it_behaves_like 'update with address', Transactions::Admin::Localpool::UpdatePersonOwner.new, :resource, first_name: 'donald'

  it_behaves_like 'update without address', Transactions::Admin::Localpool::UpdatePersonOwner.new, :resource, last_name: 'trump'

end
