require_relative '../../shared_nested_address'
require 'buzzn/transactions/admin/localpool/create_person_gap_contract_customer'

describe Transactions::Admin::Localpool::CreatePersonGapContractCustomer do

  entity!(:localpool) { create(:group, :localpool) }

  entity(:operator) { create(:account, :buzzn_operator) }

  entity(:resource) { Admin::LocalpoolResource.all(operator).first }

  it_behaves_like 'create without address', Transactions::Admin::Localpool::CreatePersonGapContractCustomer.new, PersonResource, prefix: 'M', first_name: 'Frank', last_name: 'Zappa', preferred_language: 'de'

  it_behaves_like 'create with address', Transactions::Admin::Localpool::CreatePersonGapContractCustomer.new, PersonResource, prefix: 'M', first_name: 'Frank', last_name: 'Zappa', preferred_language: 'de'

end
