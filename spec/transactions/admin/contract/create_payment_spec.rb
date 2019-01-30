describe Transactions::Admin::Contract::Base::Payment::Create, order: :defined do

  let(:localpool) { create(:group, :localpool) }
  let(:operator) { create(:account, :buzzn_operator) }

  let(:contract) { create(:contract, :localpool_powertaker, localpool: localpool) }

  let(:localpoolr) { Admin::LocalpoolResource.all(operator).retrieve(localpool.id) }

  let(:resource) do
    contract.reload
    localpool.reload
    localpoolr.localpool_power_taker_contracts.first.payments
  end

  context 'invalid data' do
    let(:params) do
      {
        foo: 'foo'
      }
    end

    let(:result) do
      Transactions::Admin::Contract::Base::Payment::Create.new.(params: params, resource: resource)
    end

    it 'fails' do
      expect(contract.payments.count).to eql 0
      expect{result}.to raise_error Buzzn::ValidationError, '{:begin_date=>["is missing"], :price_cents=>["is missing"], :energy_consumption_kwh_pa=>["is missing"]}'
      expect(contract.payments.count).to eql 0
    end
  end

  context 'valid data' do
    let(:params) do
      {
        begin_date: Date.new(2018, 5, 23),
        price_cents: 1377,
        energy_consumption_kwh_pa: 777
      }
    end

    let(:result) do
      Transactions::Admin::Contract::Base::Payment::Create.new.(params: params, resource: resource)
    end

    it 'creates' do
      expect(contract.payments.count).to eql 0
      expect(result).to be_success
      expect(result.value!).to be_a Contract::PaymentResource
      expect(contract.payments.count).to eql 1
    end
  end

end
