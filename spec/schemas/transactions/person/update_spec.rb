require 'buzzn/schemas/transactions/person/update'
require_relative '../shared_nested_address'

describe 'Schemas::Transactions::Person::Update' do

  context 'with address' do

    subject { Schemas::Transactions::Person.update_with_address }

    it_behaves_like 'update with nested address', first_name: 'Donald', last_name: 'Trump'

  end

  context 'without address' do

    subject { Schemas::Transactions::Person.update_without_address }

    it_behaves_like 'update without nested address', first_name: 'Frank', last_name: 'Zappa'

  end

end
