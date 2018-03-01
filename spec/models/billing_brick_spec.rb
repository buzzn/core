describe 'BillingBrick' do

  describe 'new' do
    it 'can be initialized with a date range' do
      attrs = { status: 'closed', type: 'gap', date_range: Date.new(2018, 1, 1)..Date.new(2019, 1, 1) }
      brick = BillingBrick.new(attrs)
      attrs.each { |key, value| expect(brick.send(key)).to eq(value) }
      expect(brick.begin_date).to eq(attrs[:date_range].first)
      expect(brick.end_date).to eq(attrs[:date_range].last)
    end
    it 'can be initialized with begin and end dates' do
      attrs = { status: 'closed', type: 'gap', begin_date: Date.new(2018, 1, 1), end_date: Date.new(2019, 1, 1) }
      brick = BillingBrick.new(attrs)
      attrs.each { |key, value| expect(brick.send(key)).to eq(value) }
      expect(brick.date_range).to eq(attrs[:begin_date]..attrs[:end_date])
    end
  end

  describe '==' do
    let(:attrs) do
      { market_location: build(:market_location),
        type: 'power_taker',
        date_range: Date.new(2018, 1, 1)..Date.new(2019, 1, 1) }
    end

    subject { BillingBrick.new(attrs) }

    context 'when other billing brick has same attributes' do
      let(:other_brick) { BillingBrick.new(attrs) }
      it { is_expected.to eq(other_brick) }
    end

    context 'when other billing brick has different attributes' do
      let(:other_brick) { BillingBrick.new(attrs.merge(type: 'third_party')) }
      it { is_expected.not_to eq(other_brick) }
    end
  end

end
