describe Transactions::Admin::Contract::Base::Payment::Create, order: :defined do

  let(:localpool) { create(:group, :localpool) }
  let(:operator) { create(:account, :buzzn_operator) }
  let(:tariff)   { create(:tariff, group: localpool, energyprice_cents_per_kwh: 20, baseprice_cents_per_month: 300) }

  let(:contract) { create(:contract, :localpool_powertaker, localpool: localpool, tariffs: [tariff]) }

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
      expect{result}.to raise_error Buzzn::ValidationError, '{:begin_date=>["is missing"], :energy_consumption_kwh_pa=>["is missing"], :cycle=>["is missing"], :price_cents=>["must be filled"]}'
      expect(contract.payments.count).to eql 0
    end
  end

  context 'valid data' do
    let(:params) do
      {
        begin_date: Date.new(2018, 5, 23),
        price_cents: 1377,
        cycle: 'monthly',
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

  context 'with a tariff' do
    let(:params) do
      {
        begin_date: Date.new(2018, 9, 23),
        cycle: 'monthly',
        energy_consumption_kwh_pa: 1000,
        tariff_id: tariff.id
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
      payment = contract.payments.first
      expect(payment.tariff).to eql tariff
      days = 30
      expect(payment.price_cents).to eql (days*(1000/365.00)*20+     # kwh
                                          days*(300 * 12)/365).round # base
    end

  end

end