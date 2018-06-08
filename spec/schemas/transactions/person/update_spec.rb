require 'buzzn/schemas/transactions/person/update'
require_relative '../shared_nested_address'

describe 'Schemas::Transactions::Person::Update' do

  subject { Schemas::Transactions::Person::Update }

  it_behaves_like 'update with nested address', first_name: 'Frank', last_name: 'Zappa'

end
