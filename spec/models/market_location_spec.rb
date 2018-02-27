describe MarketLocation do

  describe 'get/set register' do
    let(:market_location) { build(:market_location) }
    let(:register)        { build(:register) }

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

  describe 'billable_contracts_for_range' do
    let(:billing_date_range) { Date.new(2018, 1, 1)..Date.new(2019, 1, 1) }
    let(:contract)           { create(:contract, :localpool_powertaker, begin_date: contract_date_range.first, end_date: contract_date_range.last) }
    let(:contracts)          { [contract] }
    let(:market_location)    { create(:market_location, contracts: contracts) }
    subject                  { market_location.billable_contracts_for_range(billing_date_range) }

    context 'when market location has one contract' do
      #
      # begin before billing date range
      #
      context 'when contract begins and ends before billing range' do
        let(:contract_date_range) { Date.new(2017, 5, 1)..Date.new(2017, 5, 31) }
        it { is_expected.to eq([]) }
      end

      context 'when contract begins before and ends on billing range start' do
        let(:contract_date_range) { Date.new(2017, 5, 1)..billing_date_range.first }
        it { is_expected.to eq([]) }
      end

      context 'when contract begins before and ends in billing range' do
        let(:contract_date_range) { Date.new(2017, 5, 1)..Date.new(2018, 5, 31) }
        it { is_expected.to eq([contract]) }
      end

      context 'when contract begins before and ends after billing range' do
        let(:contract_date_range) { Date.new(2017, 5, 1)..Date.new(2019, 5, 31) }
        it { is_expected.to eq([contract]) }
      end

      #
      # begin in billing date range
      #
      context 'when contract begins in and ends in billing range' do
        let(:contract_date_range) { Date.new(2018, 5, 1)..Date.new(2018, 5, 31) }
        it { is_expected.to eq([contract]) }
      end

      context 'when contract begins in and ends after billing range' do
        let(:contract_date_range) { Date.new(2018, 5, 1)..Date.new(2019, 5, 31) }
        it { is_expected.to eq([contract]) }
      end

      #
      # begin on billing date range end
      #
      context 'when contract begins on billing range end' do
        let(:contract_date_range) { billing_date_range.last..Date.new(2019, 5, 31) }
        it { is_expected.to eq([]) }
      end

      #
      # begin after billing date range
      #
      context 'when contract begins after billing range' do
        let(:contract_date_range) { Date.new(2019, 5, 1)..Date.new(2019, 5, 31) }
        it { is_expected.to eq([]) }
      end

    end
  end
end
