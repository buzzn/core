describe 'BillingBrick' do

  it 'can be initialized with values' do
    attrs = { status: :open, type: :gap, begin_date: Date.new(2018, 1, 1), end_date: Date.new(2018, 12, 31) }
    brick = BillingBrick.new(attrs)
    attrs.each { |key, value| expect(brick.send(key)).to equal(value) }
  end

  describe '==' do
    let(:attrs) do
      { market_location: build(:market_location),
        type: :power_taker,
        begin_date: Date.new(2018, 1, 1),
        end_date: Date.new(2018, 12, 31) }
    end

    subject { BillingBrick.new(attrs) }

    context 'when other billing brick has same attributes' do
      let(:other_brick) { BillingBrick.new(attrs) }
      it { is_expected.to eq(other_brick) }
    end

    context 'when other billing brick has different attributes' do
      let(:other_brick) { BillingBrick.new(attrs.merge(begin_date: attrs[:begin_date] - 1.day)) }
      it { is_expected.not_to eq(other_brick) }
    end
  end

end
