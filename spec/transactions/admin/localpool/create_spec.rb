require_relative '../../shared_nested_address'
require 'buzzn/transactions/admin/localpool/create'

describe Transactions::Admin::Localpool::Create do

  entity(:operator) { create(:account, :buzzn_operator) }

  entity(:resource) { Admin::LocalpoolResource.all(operator) }

  entity(:billing_detail) { build(:billing_detail) }

  entity(:billing_detail_clean) do
    json = billing_detail.as_json
    json.delete(:updated_at)
    json.delete(:created_at)
    json.delete(:id)
    json
  end

  it_behaves_like 'create without address', Transactions::Admin::Localpool::Create.new, Admin::LocalpoolResource, name: 'takari', billing_detail: billing_detail_clean

  it_behaves_like 'create with address', Transactions::Admin::Localpool::Create.new, Admin::LocalpoolResource, name: 'akari', billing_detail: billing_detail_clean

end
