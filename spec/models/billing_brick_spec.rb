describe 'BillingBrick' do

  describe 'new' do
    it 'can be initialized with a date range' do
      attrs = { contract_type: 'gap', date_range: Date.new(2018, 1, 1)...Date.new(2019, 1, 1) }
      brick = BillingBrick.new(attrs)
      attrs.each { |key, value| expect(brick.send(key)).to eq(value) }
      expect(brick.begin_date).to eq(attrs[:date_range].first)
      expect(brick.end_date).to eq(attrs[:date_range].last)
    end
    it 'can be initialized with begin and end dates' do
      attrs = { contract_type: 'gap', begin_date: Date.new(2018, 1, 1), end_date: Date.new(2019, 1, 1) }
      brick = BillingBrick.new(attrs)
      attrs.each { |key, value| expect(brick.send(key)).to eq(value) }
      expect(brick.date_range).to eq(attrs[:begin_date]...attrs[:end_date])
    end
  end

  describe 'status' do
    context 'when brick has no billing' do
      subject { build(:billing_brick, billing: nil).status }
      it      { is_expected.to eq('open') }

      context 'when brick is of type third_party' do
        subject { build(:billing_brick, billing: nil, contract_type: 'third_party').status }
        it      { is_expected.to be_nil }
      end
    end

    context 'when brick has a billing' do
      EXPECTATIONS = {
        open:       'open',
        calculated: 'open',
        delivered:  'closed',
        settled:    'closed',
        closed:     'closed'
      }

      EXPECTATIONS.each do |billing_status, expected_brick_status|
        context "when billing status is #{billing_status}" do
          let(:billing) { build(:billing, status: billing_status) }
          subject       { build(:billing_brick, billing: billing).status }
          it { is_expected.to eq(expected_brick_status) }
        end
      end
    end

  end

  describe 'consumed_energy_kwh' do
    let(:brick) { build(:billing_brick) }
    context 'when it has no readings' do
      it 'returns nil' do
        expect(brick.consumed_energy_kwh).to be_nil
      end
    end
    context 'when it has readings' do
      before do
        brick.end_reading   = build(:reading, raw_value: 200_500)
        brick.begin_reading = build(:reading, raw_value: 100_000)
      end
      it 'returns the difference' do
        expect(brick.consumed_energy_kwh).to eq(100.5)
      end
    end
  end

  describe 'energy_price_cents' do
    let(:brick) { build(:billing_brick, :with_readings, tariff: nil) }
    context 'when it has no tariff' do
      it 'returns nil' do
        expect(brick.energy_price_cents).to be_nil
      end
    end
    context 'when it has a tariff' do
      before { brick.tariff = build(:tariff, energyprice_cents_per_kwh: 25.999) }
      it 'calculates the price correctly' do
        expected_price = (100 * 25.999).round
        expect(brick.energy_price_cents).to eq(expected_price)
      end
    end
  end

  describe 'base_price_cents' do
    let(:brick) { build(:billing_brick, end_date: Date.today, begin_date: Date.today - 50.days) }
    context 'when it has no tariff' do
      it 'returns nil' do
        expect(brick.base_price_cents).to be_nil
      end
    end
    context 'when it has a tariff' do
      before { brick.tariff = build(:tariff, baseprice_cents_per_month: 100) }
      it 'calculates the price correctly' do
        baseprice_cents_per_day = (50 * 12) / 365.0
        expected_price          = (baseprice_cents_per_day * 100).round
        expect(brick.base_price_cents).to eq(expected_price)
      end
    end
  end
end
