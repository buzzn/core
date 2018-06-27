require 'buzzn/schemas/transactions/organization/create_with_nested'
require_relative '../shared_nested_address'

describe 'Schemas::Transactions::Organization::CreateWithNested' do

  subject { Schemas::Transactions::Organization::CreateWithNested }

  it_behaves_like 'create with nested address', name: 'Trump-Tower Limited'

end
