describe MarketLocation do

  let(:market_location) { build(:market_location) }
  let(:register)        { build(:register) }

  describe 'get/set register' do
    describe 'when it has no register' do
      before { market_location.register = nil }
      it 'is nil' do
        expect(market_location.register).to be_nil
      end
      it 'is can be set' do
        market_location.register = register
        expect(market_location.register).to eq(register)
      end
    end
    describe 'when it has a register' do
      before { market_location.register = register }
      it 'can be read' do
        expect(market_location.register).to eq(register)
      end
      it 'can be unset' do
        market_location.register = nil
        expect(market_location.register).to eq(nil)
      end
    end
  end

  describe 'billable_contracts_for_period' do
    context 'market location has no contracts' do
      let(:market_location) { create(:market_location, contracts: []) }
      it 'returns no contracts' do
        contracts = market_location.billable_contracts_for_period(Date.new(2000, 1, 1), Date.new(2018, 12, 31))
        expect(contracts).to eq([])
      end
    end

    context 'market location has one contract in range' do
      let(:begin_date) { Date.new(2018, 1, 1) }
      let(:end_date)   { Date.new(2018, 12, 31) }
      let(:contracts)  { [create(:contract, :localpool_powertaker, begin_date: begin_date, end_date: end_date)] }
      let(:market_location) { create(:market_location, contracts: contracts) }
      it 'returns that contract' do
        contracts = market_location.billable_contracts_for_period(begin_date, end_date)
        expect(contracts).to eq(contracts)
      end
    end

  end
end
