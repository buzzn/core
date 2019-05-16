shared_examples 'incorrect templates' do

  context 'no template' do
    let(:params) { {} }

    it 'fails' do
      expect {result}.to raise_error Buzzn::ValidationError
    end
  end

  context 'wrong template' do
    let(:params) { { template: 'haxhax' } }

    it 'fails' do
      expect {result}.to raise_error Buzzn::ValidationError, '{:template=>"no a valid template"}'
    end
  end

end

describe Transactions::Admin::Contract::Document do

  before do
    require './lib/buzzn/types/billing_config'
    CoreConfig.store Types::BillingConfig.new(vat: 1.19)
  end

  let!(:localpool) { create(:group, :localpool, :with_address) }
  let(:operator) { create(:account, :buzzn_operator) }
  let!(:localpoolr) { Admin::LocalpoolResource.all(operator).retrieve(localpool.id) }
  let(:result) { Transactions::Admin::Contract::Document.new.(params: params, resource: resource) }

  context 'localpool power taker' do

    let(:contract) { create(:contract, :localpool_powertaker, :with_tariff, localpool: localpool) }
    let(:resource) { localpoolr.localpool_power_taker_contracts.retrieve(contract.id) }

    it_behaves_like 'incorrect templates'

    context 'valid' do

      ['lsn_a1', 'lsn_a2'].each do |t|
        context "template #{t}" do
          let(:params) { { template: t } }

          it 'generates' do
            expect(result).to be_success
            expect(result.value!).to be_a DocumentResource
          end

        end

      end

    end

  end

  context 'localpool metering point operator contract' do

    let(:contract) { create(:contract, :metering_point_operator, localpool: localpool) }
    let(:resource) { localpoolr.metering_point_operator_contracts.retrieve(contract.id) }

    it_behaves_like 'incorrect templates'

    context 'valid' do

      let(:params) { { template: 'metering_point_operator_contract' } }

      it 'generates' do
        expect(result).to be_success
        expect(result.value!).to be_a DocumentResource
      end

    end

  end

  context 'localpool processing contract' do

    let(:contract) { create(:contract, :localpool_processing, localpool: localpool) }
    let(:resource) { localpoolr.localpool_processing_contracts.retrieve(contract.id) }

    it_behaves_like 'incorrect templates'

    context 'valid' do

      let(:params) { { template: 'localpool_processing_contract' } }

      it 'generates' do
        expect(result).to be_success
        expect(result.value!).to be_a DocumentResource
      end

    end

  end

end
