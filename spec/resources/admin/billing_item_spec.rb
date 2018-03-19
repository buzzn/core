describe Contract::TariffResource do

  entity(:admin) { Fabricate(:admin) }
  entity(:localpool) { create(:localpool) }
  entity(:billing_cycle) { create(:billing_cycle, localpool: localpool) }
  entity(:billing) do
    billing = create(:billing, contract: create(:contract, :localpool_powertaker, :with_tariff, localpool: localpool))
    billing_cycle.billings << billing
    billing
  end
  entity!(:billing_item) do
    create(:billing_item,
           billing: billing,
           tariff: billing.contract.tariffs.first)

  end

  let(:billing_item_resource) { Admin::LocalpoolResource.all(admin).retrieve(localpool.id).billing_cycles.first.billings.first.items.first }

  subject { JSON.parse(billing_item_resource.to_json) }

  it 'json has all keys' do
    expect(subject.keys).to match_array(%w(base_price_cents begin_date begin_reading_kwh consumed_energy_kwh end_date end_reading_kwh energy_price_cents id length_in_days type updated_at))
  end

  context 'without readings' do
    before { billing_item.update(begin_reading: nil, end_reading: nil) }
    it 'no begin value' do
      expect(subject['begin_reading_kwh']).to be_nil
    end
    it 'no end value' do
      expect(subject['end_reading_kwh']).to be_nil
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
  end
end
