describe Admin::BillingItemResource do

  entity(:admin) { create(:account, :buzzn_operator) }
  entity(:localpool) { create(:group, :localpool) }
  entity(:billing_cycle) { create(:billing_cycle, localpool: localpool) }
  entity(:billing) do
    billing = create(:billing, contract: create(:contract, :localpool_powertaker, :with_tariff, localpool: localpool))
    billing_cycle.billings << billing
    billing
  end
  entity!(:billing_item) do
    create(:billing_item,
           billing: billing,
           tariff: billing.contract.tariffs.first,
           vat: create(:vat, amount: 0.19, begin_date: Date.new(1990, 1, 1)))
  end

  let(:billing_item_resource) { Admin::LocalpoolResource.all(admin).retrieve(localpool.id).billing_cycles.first.billings.first.items.first }

  subject { JSON.parse(billing_item_resource.to_json) }

  it 'json has all keys' do
    expect(subject.keys).to match_array(%w(base_price_cents begin_date begin_reading_kwh consumed_energy_kwh last_date end_date end_reading_kwh energy_price_cents id length_in_days type updated_at created_at incompleteness))
  end

  context 'without readings' do
    before { billing_item.update(begin_reading: nil, end_reading: nil) }
    it 'no begin value' do
      expect(subject['begin_reading_kwh']).to be_nil
    end
    it 'no end value' do
      expect(subject['end_reading_kwh']).to be_nil
    end
    it 'is incomplete' do
      expect(subject['incompleteness']['begin_reading']).to eql ['must be filled']
      expect(subject['incompleteness']['end_reading']).to eql ['must be filled']
    end
  end

  context 'with readings' do
    before { billing_item.update(begin_reading: create(:reading), end_reading: create(:reading)) }
    it 'begin value' do
      expect(subject['begin_reading_kwh']).to eq(1)
    end
    it 'end value' do
      expect(subject['end_reading_kwh']).to eq(1)
    end
    it 'is complete' do
      expect(subject['incompleteness'].count).to eql(0)
    end
  end
end
