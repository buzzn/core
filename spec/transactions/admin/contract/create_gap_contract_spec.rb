require 'buzzn/transactions/admin/contract/localpool/create_gap_contract'

require 'buzzn/resources/contract/localpool_gap_contract_resource'

require_relative '../../../support/params_helper.rb'
require_relative 'shared_create'

describe Transactions::Admin::Contract::Localpool::CreateGapContract, order: :defined do

  let!(:localpool) { create(:group, :localpool) }
  let(:operator) { create(:account, :buzzn_operator) }
  let!(:localpoolr) { Admin::LocalpoolResource.all(operator).retrieve(localpool.id) }

  let(:resource) do
    localpool.save
    localpoolr.localpool_gap_contracts
  end

  let(:register_meta) do
    create(:meta)
  end

  let(:request) do
    { begin_date: Date.today.as_json,
      share_register_publicly: false,
      share_register_with_group: true,
      register_meta: { id: register_meta.id }
    }
  end

  let(:gap_person) do
    create(:person)
  end

  context 'invalid state' do

    context 'without a gap contract customer' do

      let!(:lpc) do
        unless localpool.localpool_processing_contracts.any?
          create(:contract, :localpool_processing,
                 customer: localpoolr.object.owner,
                 contractor: Organization::Market.buzzn,
                 localpool: localpool)
        end
        localpoolr.object.reload
        localpoolr.object.localpool_processing_contracts.first
      end

      let(:result) do
        Transactions::Admin::Contract::Localpool::CreateGapContract.new.(resource: resource, params: request, localpool: localpoolr)
      end

      it 'does not create' do
        expect {result}.to raise_error(Buzzn::ValidationError, '{:localpool=>{:gap_contract_customer=>["must be filled"]}}')
      end

    end

    context 'with a gap_contract customer' do

      before do
        localpool.gap_contract_customer = gap_person
        localpool.save
      end

      it_behaves_like 'without processing contract', Transactions::Admin::Contract::Localpool::CreateGapContract.new do
        let(:params) { request }
        let(:lp) { localpoolr }
        let(:r) { resource }
      end

      it_behaves_like 'with existing contract on same register', Transactions::Admin::Contract::Localpool::CreateGapContract.new do
        let(:params) { request }
        let(:lp) { localpoolr }
        let(:r) { resource }
      end

    end

  end

  context 'valid state' do

    before do
      localpoolr.object.gap_contract_customer = gap_person
      localpoolr.object.save
    end

    let!(:lpc) do
      unless localpool.localpool_processing_contracts.any?
        create(:contract, :localpool_processing,
               customer: localpoolr.object.owner,
               contractor: Organization::Market.buzzn,
               localpool: localpool)
      end
      localpoolr.object.reload
      localpoolr.object.localpool_processing_contracts.first
    end

    let(:result) do
      Transactions::Admin::Contract::Localpool::CreateGapContract.new.(resource: resource, params: request, localpool: localpoolr)
    end

    it 'creates' do
      expect(result).to be_success
      res = result.value!
      expect(res).to be_a Contract::LocalpoolGapContractResource
    end

  end

end
