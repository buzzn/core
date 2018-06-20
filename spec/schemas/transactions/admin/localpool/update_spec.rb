require 'buzzn/schemas/transactions/admin/localpool/update'
require_relative '../../shared_nested_address'

describe 'Schemas::Transactions::Admin::Localpool::Update' do

  context 'with address' do

    subject { Schemas::Transactions::Admin::Localpool.update_with_address }

    it_behaves_like 'update with nested address', name: 'be there'

  end

  context 'without address' do

    subject { Schemas::Transactions::Admin::Localpool.update_without_address }

    it_behaves_like 'update without nested address', name: 'be there'

  end

end
