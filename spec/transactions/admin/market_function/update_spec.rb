require 'buzzn/transactions/admin/market_function/update'
require_relative '../../shared_nested_address'
require_relative '../../shared_nested_person'
require_relative '../../../support/params_helper.rb'

describe Transactions::Admin::MarketFunction::Update do

  let(:operator) { create(:account, :buzzn_operator) }
  let(:admin_resource) { AdminResource.new(operator) }

  let(:result) do
    Transactions::Admin::MarketFunction::Update.new.(resource: resource, params: params, organization: org)
  end

  context 'function' do
    let(:org) { create(:organization, :electricity_supplier) }
    let(:resource) { admin_resource.organization_markets.retrieve(org.id).market_functions.retrieve(org.market_functions.first.id) }

    let(:invalid_params_1) do
      {
        updated_at: resource.object.updated_at.to_json,
        function: 'electricity_supplier'
      }
    end

    let(:valid_params_1) do
      {
        updated_at: resource.object.updated_at.to_json,
        function: 'distribution_system_operator'
      }
    end

    context 'already assigned as one' do
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

    context 'invalid' do

      let(:params) { invalid_params_1 }

      it 'fails' do
        expect{result}.to raise_error Buzzn::ValidationError, '{:function=>["must be one of: distribution_system_operator, metering_point_operator, metering_service_provider, other, power_giver, power_taker, transmission_system_operator"]}'
      end

    end

    context 'valid' do

      let(:params) { valid_params_1 }

      it 'works' do
        expect(result).to be_success
        mf = resource.object
        mf.reload
        expect(mf.function).to eql 'distribution_system_operator'
      end

    end

  end

  context 'contact person' do
    let(:org) { create(:organization, :electricity_supplier) }
    it_behaves_like 'update without person', Transactions::Admin::MarketFunction::Update.new, :contact_person, {} do
      let(:resource) { admin_resource.organization_markets.retrieve(org.id).market_functions.retrieve(org.market_functions.first.id) }
      let(:extra_args) {{ organization: org }}
    end
    it_behaves_like 'update with person without address', Transactions::Admin::MarketFunction::Update.new, :contact_person, {} do
      let(:resource) { admin_resource.organization_markets.retrieve(org.id).market_functions.retrieve(org.market_functions.first.id) }
      let(:extra_args) {{ organization: org }}
    end
    it_behaves_like 'update with person with address', Transactions::Admin::MarketFunction::Update.new, :contact_person, {} do
      let(:resource) { admin_resource.organization_markets.retrieve(org.id).market_functions.retrieve(org.market_functions.first.id) }
      let(:extra_args) {{ organization: org }}
    end
  end

  context 'address' do
    let(:org) { create(:organization, :electricity_supplier) }

    it_behaves_like 'update with address', Transactions::Admin::MarketFunction::Update.new, {} do
      let(:resource) { admin_resource.organization_markets.retrieve(org.id).market_functions.retrieve(org.market_functions.first.id) }
      let(:extra_args) {{ organization: org }}
    end

    it_behaves_like 'update without address', Transactions::Admin::MarketFunction::Update.new, {} do
      let(:resource) { admin_resource.organization_markets.retrieve(org.id).market_functions.retrieve(org.market_functions.first.id) }
      let(:extra_args) {{ organization: org }}
    end

  end

end
