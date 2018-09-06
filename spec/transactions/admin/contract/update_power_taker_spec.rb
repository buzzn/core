require 'buzzn/transactions/admin/contract/localpool/update_power_taker.rb'

require 'buzzn/resources/contract/localpool_power_taker_resource.rb'

describe Transactions::Admin::Contract::Localpool::UpdatePowerTaker, order: :defined do

  let(:localpool) { create(:group, :localpool) }
  let(:operator) { create(:account, :buzzn_operator) }

  let(:lpc) do
    create(:contract, :localpool_processing,
           customer: localpool.owner,
           contractor: Organization::Market.buzzn,
           localpool: localpool)
  end

  let(:person) do
    create(:person, :with_bank_account)
  end

  let(:contract) do
    create(:contract, :localpool_powertaker,
           customer: person,
           contractor: Organization::Market.buzzn,
           localpool: localpool)
  end

  let(:localpoolr) { Admin::LocalpoolResource.all(operator).retrieve(localpool.id) }

  let(:resource) do
    contract.reload
    localpool.reload
    localpoolr.localpool_power_taker_contracts.first
  end

  let(:base_input) do
    {
      'signing_date': Date.today
    }
  end

  let(:with_register_meta_input) do
    {
      'register_meta': { :name => 'Another Secret Room'}
    }
  end

  let(:with_register_meta_and_updated_input) do
    json = with_register_meta_input.dup
    json[:register_meta][:updated_at] = resource.register_meta.updated_at.as_json
    json
  end

  let(:invalid_input_2) do
    contract.reload
    base_input.merge(with_register_meta_input).merge(:updated_at => resource.updated_at.as_json)
  end

  let(:valid_input) do
    contract.reload
    base_input.merge(with_register_meta_and_updated_input)
              .merge(:updated_at => resource.updated_at.as_json)
  end

  let(:valid_input_2) do
    contract.reload
    base_input.merge(:updated_at => resource.updated_at.as_json)
  end

  let(:result_invalid) do
    Transactions::Admin::Contract::Localpool::UpdatePowerTaker.new.(params: base_input,
                                                                    resource: resource)
  end

  let(:result_invalid_2) do
    Transactions::Admin::Contract::Localpool::UpdatePowerTaker.new.(params: invalid_input_2,
                                                                    resource: resource)
  end

  let(:result_valid) do
    Transactions::Admin::Contract::Localpool::UpdatePowerTaker.new.(params: valid_input,
                                                                    resource: resource)
  end

  let(:result_valid_2) do
    Transactions::Admin::Contract::Localpool::UpdatePowerTaker.new.(params: valid_input_2,
                                                                    resource: resource)
  end

  it 'should not update' do
    expect {result_invalid}.to raise_error(Buzzn::ValidationError, '{:updated_at=>["is missing"]}')
  end

  it 'should not update' do
    expect {result_invalid_2}.to raise_error(Buzzn::ValidationError, '{:register_meta=>{:updated_at=>["is missing"]}}')
  end

  it 'should update' do
    expect(result_valid).to be_success
  end

  it 'should update' do
    expect(result_valid_2).to be_success
  end

end
