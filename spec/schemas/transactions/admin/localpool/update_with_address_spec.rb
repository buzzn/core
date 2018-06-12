require 'buzzn/schemas/transactions/admin/localpool/update_with_address'
require_relative '../../shared_nested_address'

describe 'Schemas::Transactions::Admin::Localpool::UpdateWithAddress' do

  subject { Schemas::Transactions::Admin::Localpool::UpdateWithAddress }

  it_behaves_like 'update with nested address', name: 'be there'

end
