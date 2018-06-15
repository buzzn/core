require 'buzzn/schemas/transactions/person/create'
require_relative '../shared_nested_address'

describe 'Schemas::Transactions::Person::Create' do

  subject { Schemas::Transactions::Person::CreateWithAddress }

  it_behaves_like 'create with nested address', prefix: 'M', first_name: 'Frank', last_name: 'Zappa', preferred_language: 'de'

end
