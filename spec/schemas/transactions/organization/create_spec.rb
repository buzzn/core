require 'buzzn/schemas/transactions/organization/create'
require_relative '../shared_nested_address'
require_relative '../shared_nested_person'

describe 'Schemas::Transactions::Organization::CreateWithNested' do

  subject { Schemas::Transactions::Organization::CreateWithNested }

  it_behaves_like 'create with nested address', name: 'Trump-Tower Limited'

  it_behaves_like 'create with nested person', :contact, name: 'Trump-Tower Limited'

  it_behaves_like 'create with nested person', :legal_representation, name: 'Trump-Tower Limited'

end
