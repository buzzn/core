require 'buzzn/schemas/transactions/admin/localpool/create'
require_relative '../../shared_nested_address'

describe 'Schemas::Transactions::Admin::Localpool::Create' do

  subject { Schemas::Transactions::Admin::Localpool::Create }

  it_behaves_like 'create with nested address', name: 'be there'

end
