require 'buzzn/transactions/admin/contract/localpool/create_third_party'
require_relative 'shared_create'

describe Transactions::Admin::Contract::Localpool::CreateThirdParty, order: :defined do

  let!(:localpool) { create(:group, :localpool) }
  let(:operator) { create(:account, :buzzn_operator) }
  let!(:localpoolr) { Admin::LocalpoolResource.all(operator).retrieve(localpool.id) }

  let(:resource) do
    localpool.save
    localpoolr.localpool_third_party_contracts
  end

  let(:meter) do
    create(:meter, :real, group: localpool)
  end

  let(:register_meta) do
    meter.registers.first.meta
  end

  let(:request_with_meta) do
    {
      begin_date: Date.today.as_json,
      share_register_publicly: false,
      share_register_with_group: true,
      register_meta: { name: 'Secret Room', label: 'CONSUMPTION'}
    }
  end

  let(:request_with_meta_id) do
    {
      begin_date: Date.today.as_json,
      share_register_publicly: false,
      share_register_with_group: true,
      register_meta: { id: register_meta.id }
    }
  end

  context 'invalid state' do
    it_behaves_like 'without processing contract', Transactions::Admin::Contract::Localpool::CreateThirdParty.new do
      let(:params) { request_with_meta }
      let(:lp) { localpoolr }
      let(:r) { resource }
    end

    it_behaves_like 'with existing contract on same register', Transactions::Admin::Contract::Localpool::CreateThirdParty.new do
      let(:params) { request_with_meta }
      let(:lp) { localpoolr }
      let(:r) { resource }
    end

  end

  context 'valid state' do

    let!(:contract) do
      create(:contract, :localpool_processing,
             customer: localpool.owner,
             contractor: Organization::Market.buzzn,
             localpool: localpool)
    end

    let(:result_valid_1) do
      Transactions::Admin::Contract::Localpool::CreateThirdParty.new.(resource: resource,
                                                                      params: request_with_meta,
                                                                      localpool: localpoolr)
    end

    let(:result_valid_2) do
      Transactions::Admin::Contract::Localpool::CreateThirdParty.new.(resource: resource,
                                                                      params: request_with_meta_id,
                                                                      localpool: localpoolr)
    end

    it 'creates with meta: data' do
      expect(result_valid_1).to be_success
      expect(result_valid_1.value!).to be_a Contract::LocalpoolThirdPartyResource
    end

    it 'creates with meta: id' do
      expect(result_valid_2).to be_success
      expect(result_valid_2.value!).to be_a Contract::LocalpoolThirdPartyResource
    end

  end

end
