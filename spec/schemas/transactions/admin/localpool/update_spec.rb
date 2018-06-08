require 'buzzn/schemas/transactions/admin/localpool/update'
require_relative '../../shared_nested_address'

describe 'Schemas::Transactions::Admin::Localpool::Update' do

  subject { Schemas::Transactions::Admin::Localpool::Update }

  it_behaves_like 'update with nested address', name: 'be there'

end
