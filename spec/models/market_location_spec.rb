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
end
