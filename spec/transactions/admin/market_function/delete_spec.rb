require 'buzzn/transactions/admin/market_function/delete'

describe Transactions::Admin::MarketFunction::Delete do

  let(:operator) { create(:account, :buzzn_operator) }
  let(:admin_resource) { AdminResource.new(operator) }
  let(:resource) { admin_resource.organization_markets.retrieve(org.id).market_functions.retrieve(org.market_functions.first.id) }
  let(:org) { create(:organization, :electricity_supplier) }

  let(:result) do
    Transactions::Admin::MarketFunction::Delete.new.(resource: resource, params: {}, organization: org)
  end

  context 'without assignment' do

    it 'deletes' do
      expect(result).to be_success
    end

  end

  context 'with assignment' do
    let(:localpool) { create(:group, :localpool) }
    before do
      localpool.electricity_supplier = org
      localpool.save
    end

    let(:params) { valid_params_1 }

    it 'fails' do
      expect{result}.to raise_error Buzzn::ValidationError, "{:function=>[\"organization already serves as #{resource.function} for [#{localpool.id}]\"]}"
    end
  end

end
