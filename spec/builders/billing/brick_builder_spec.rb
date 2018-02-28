describe 'Billing::BrickBuilder' do

  describe 'from_contract' do

    let(:date_range) { Date.new(2018, 1, 1)..Date.new(2019, 1, 1) }
    let(:brick)      { Billing::BrickBuilder.from_contract(contract, date_range) }
    context 'when contract starts before date_range and hasn\'t ended' do
      let(:contract) { create(:contract, :localpool_gap, begin_date: date_range.first - 1.day, end_date: nil) }
      it 'has the date_range\'s begin date' do
        expect(brick.date_range).to eq(date_range.first..date_range.last)
      end
    end
    context 'when contract starts with date_range and hasn\'t ended' do
      let(:contract) { create(:contract, :localpool_gap, begin_date: date_range.first, end_date: nil) }
      it 'has the date_range\'s begin date' do
        expect(brick.date_range).to eq(date_range.first..date_range.last)
      end
    end
    context 'when contract starts in date_range and hasn\'t ended' do
      let(:contract) { create(:contract, :localpool_gap, begin_date: date_range.first + 1.day, end_date: nil) }
      it 'has the contract\'s begin and end dates' do
        expect(brick.date_range).to eq(contract.begin_date..date_range.last)
      end
    end
    context 'when contract starts and ends in date_range' do
      let(:contract) { create(:contract, :localpool_gap, begin_date: date_range.first + 1.day, end_date: date_range.last - 1.day) }
      it 'has the contract\'s begin and end dates' do
        expect(brick.date_range).to eq(contract.begin_date..contract.end_date)
      end
    end
    context 'when contract starts in and ends after date_range' do
      let(:contract) { create(:contract, :localpool_gap, begin_date: date_range.first + 1.day, end_date: date_range.last + 1.day) }
      it 'has the contract\'s begin and date_range\'s end date' do
        expect(brick.date_range).to eq(contract.begin_date..date_range.last)
      end
    end
    describe 'type' do
      context 'when initialized with a third party contract' do
        let(:contract) { create(:contract, :localpool_third_party) }
        it 'has the type third_party' do
          expect(brick.type).to eq(:third_party)
        end
      end
    end
    describe 'status' do
      let(:contract) { create(:contract, :localpool_third_party) }
      it 'is open' do
        skip 'status isn\'t implemented yet.'
        expect(brick.status).to eq(:open)
      end
    end
  end

end
