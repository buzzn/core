require 'buzzn/schemas/transactions/admin/localpool/update_without_address'
require_relative '../../shared_nested_address'

describe 'Schemas::Transactions::Admin::Localpool::UpdateWithoutAddress' do

  subject { Schemas::Transactions::Admin::Localpool::UpdateWithoutAddress }

  it_behaves_like 'update without nested address', name: 'be there'

end
