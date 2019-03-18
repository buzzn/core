describe Transactions::Admin::Contract::Base::Payment::Create, order: :defined do

  let(:localpool) { create(:group, :localpool) }
  let(:operator) { create(:account, :buzzn_operator) }

  let(:contract) { create(:contract, :localpool_powertaker, localpool: localpool) }

  let(:localpoolr) { Admin::LocalpoolResource.all(operator).retrieve(localpool.id) }

  let(:payment) { create(:payment, contract: contract)}

  let(:resource) do
    contract.reload
    localpool.reload
    localpoolr.localpool_power_taker_contracts.first.payments.retrieve(payment.id)
  end

  context 'invalid data' do
    let(:params) do
      {
        foo: 'foo'
      }
    end

    let(:result) do
      Transactions::Admin::Contract::Base::Payment::Update.new.(params: params, resource: resource)
    end

    it 'fails' do
      expect {result}.to raise_error Buzzn::ValidationError, '{:updated_at=>["is missing"]}'
    end
  end

  context 'valid data' do
    let(:params) do
      {
        begin_date: Date.new(2018, 5, 23),
        price_cents: 1377,
        energy_consumption_kwh_pa: 777,
        updated_at: resource.updated_at.to_json
      }
    end

    let(:result) do
      Transactions::Admin::Contract::Base::Payment::Update.new.(params: params, resource: resource)
    end

    it 'creates' do
      expect(result).to be_success
    end
  end

end

