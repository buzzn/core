describe 'BillingItem' do

  describe 'new' do
    it 'can be initialized with a date range' do
      attrs = { contract_type: 'gap', date_range: Date.new(2018, 1, 1)...Date.new(2019, 1, 1) }
      item = BillingItem.new(attrs)
      attrs.each { |key, value| expect(item.send(key)).to eq(value) }
      expect(item.begin_date).to eq(attrs[:date_range].first)
      expect(item.end_date).to eq(attrs[:date_range].last)
    end
    it 'can be initialized with begin and end dates' do
      attrs = { contract_type: 'gap', begin_date: Date.new(2018, 1, 1), end_date: Date.new(2019, 1, 1) }
      item = BillingItem.new(attrs)
      attrs.each { |key, value| expect(item.send(key)).to eq(value) }
      expect(item.date_range).to eq(attrs[:begin_date]...attrs[:end_date])
    end
  end

  describe 'status' do
    context 'when item has no billing' do
      subject { build(:billing_item, billing: nil).status }
      it      { is_expected.to eq('open') }

      context 'when item is of type third_party' do
        subject { build(:billing_item, billing: nil, contract_type: 'third_party').status }
        it      { is_expected.to be_nil }
      end
    end

    context 'when item has a billing' do
      EXPECTATIONS = {
        open:       'open',
        calculated: 'open',
        delivered:  'closed',
        settled:    'closed',
        closed:     'closed'
      }

      EXPECTATIONS.each do |billing_status, expected_item_status|
        context "when billing status is #{billing_status}" do
          let(:billing) { build(:billing, status: billing_status) }
          subject       { build(:billing_item, billing: billing).status }
          it { is_expected.to eq(expected_item_status) }
        end
      end
    end

  end

  describe 'consumed_energy_kwh' do
    let(:item) { build(:billing_item) }
    context 'when it has no readings' do
      it 'returns nil' do
        expect(item.consumed_energy_kwh).to be_nil
      end
    end
    context 'when it has readings' do
      before do
        item.end_reading   = build(:reading, raw_value: 200_600)
        item.begin_reading = build(:reading, raw_value: 100_000)
      end
      it 'returns the rounded difference' do
        expect(item.consumed_energy_kwh).to eq(101)
      end
    end
  end

  describe 'energy_price_cents' do
    let(:item) { build(:billing_item, :with_readings, tariff: nil) }
    context 'when it has no tariff' do
      it 'returns nil' do
        expect(item.energyprice_cents_before_taxes).to be_nil
      end
    end
    context 'when it has a tariff' do
      before { item.tariff = build(:tariff, energyprice_cents_per_kwh: 25.999) }
      it 'calculates the price correctly' do
        expected_price = (100 * BigDecimal(25.999, 3))
        expect(item.energyprice_cents_before_taxes.round(6)).to eq(expected_price.round(6))
      end
    end
  end

  describe 'base_price_cents' do
    let(:item) { build(:billing_item, end_date: Date.today, begin_date: Date.today - 50.days) }
    context 'when it has no tariff' do
      it 'returns nil' do
        expect(item.baseprice_cents_before_taxes).to be_nil
      end
    end
    context 'when it has a tariff' do
      before { item.tariff = build(:tariff, baseprice_cents_per_month: 100) }
      it 'calculates the price correctly' do
        baseprice_cents_per_day = (50 * 12) / 365.0
        expected_price          = (baseprice_cents_per_day * 100)
        expect(item.baseprice_cents_before_taxes).to eq(expected_price.round(0))
      end
    end
  end

  describe 'price_cents' do
    let(:item) { build(:billing_item, :with_readings, end_date: Date.today, begin_date: Date.today - 50.days) }
    context 'when it has no tariff' do
      it 'returns nil' do
        expect(item.price_cents_before_taxes).to be_nil
      end
    end
    context 'when it has a tariff' do
      before { item.tariff = build(:tariff, energyprice_cents_per_kwh: 25.999, baseprice_cents_per_month: 100) }
      it 'calculates the price correctly' do
        expect(item.price_cents_before_taxes.round(2)).to eq(2764.00)
      end
    end
  end
end
