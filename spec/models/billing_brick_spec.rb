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

end
