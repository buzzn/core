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

  describe 'from_contract' do
    let(:period) { Date.new(2018, 1, 1)..Date.new(2019, 1, 1) }
    let(:brick)  { BillingBrick.from_contract(contract, period.first, period.last) }
    context 'when contract starts before period and hasn\'t ended' do
      let(:contract) { create(:contract, :localpool_gap, begin_date: period.first - 1.day, end_date: nil) }
      it 'has the period\'s begin date' do
        expect(brick.date_range).to eq(period.first..period.last)
      end
    end
    context 'when contract starts with period and hasn\'t ended' do
      let(:contract) { create(:contract, :localpool_gap, begin_date: period.first, end_date: nil) }
      it 'has the period\'s begin date' do
        expect(brick.date_range).to eq(period.first..period.last)
      end
    end
    context 'when contract starts in period and hasn\'t ended' do
      let(:contract) { create(:contract, :localpool_gap, begin_date: period.first + 1.day, end_date: nil) }
      it 'has the contract\'s begin and end dates' do
        expect(brick.date_range).to eq(contract.begin_date..period.last)
      end
    end
    context 'when contract starts and ends in period' do
      let(:contract) { create(:contract, :localpool_gap, begin_date: period.first + 1.day, end_date: period.last - 1.day) }
      it 'has the contract\'s begin and end dates' do
        expect(brick.date_range).to eq(contract.begin_date..contract.end_date)
      end
    end
    context 'when contract starts in and ends after period' do
      let(:contract) { create(:contract, :localpool_gap, begin_date: period.first + 1.day, end_date: period.last + 1.day) }
      it 'has the contract\'s begin and period\'s end date' do
        expect(brick.date_range).to eq(contract.begin_date..period.last)
      end
    end
  end
end
