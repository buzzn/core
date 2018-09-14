require_relative '../../shared_nested_address'
require 'buzzn/transactions/admin/localpool/update'

describe Transactions::Admin::Localpool::Update do

  entity(:operator) { create(:account, :buzzn_operator) }
  entity(:billing_detail) { create(:billing_detail) }
  entity!(:localpool) { create(:group, :localpool, billing_detail: billing_detail) }

  entity(:resource) { Admin::LocalpoolResource.all(operator).first }

  it_behaves_like 'update with address', Transactions::Admin::Localpool::Update.new, :resource, name: 'takakari'
  it_behaves_like 'update without address', Transactions::Admin::Localpool::Update.new, :resource, name: 'takari'

  let(:billing_params_base) do
    bjson = billing_detail.attributes
    bjson.delete(:created_at)
    bjson.delete(:id)
    bjson[:updated_at] = billing_detail.updated_at.as_json
    {
      updated_at: resource.updated_at.as_json,
      billing_detail: bjson
    }
  end

  let(:billing_params_valid) do
    json = billing_params_base.dup
    json[:billing_detail][:reduced_power_amount] = 13131012
    json
  end

  let(:billing_params_invalid) do
    json = billing_params_base.dup
    json[:billing_detail][:reduced_power_factor] = -0.23
    json
  end

  let(:billing_detail_result_valid) do
    Transactions::Admin::Localpool::Update.new.(params: billing_params_valid, resource: resource)
  end

  let(:billing_detail_result_invalid) do
    Transactions::Admin::Localpool::Update.new.(params: billing_params_invalid, resource: resource)
  end

  it 'updates the billing detail' do
    resource.reload
    expect(billing_detail_result_valid).to be_success
    localpool.billing_detail.reload
    expect(localpool.billing_detail.reduced_power_amount).to eql 13131012.0
  end

  it 'does not update the billing detail' do
    resource.reload
    expect {billing_detail_result_invalid}.to raise_error(Buzzn::ValidationError, '{:reduced_power_factor=>["must be greater than or equal to 0"]}')
  end

end
