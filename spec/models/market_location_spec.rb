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

  describe 'consumption?' do
    let(:market_location) { create(:market_location, register_trait) }
    before { market_location.registers.reload }
    subject { market_location.register.consumption? }
    context 'when register has label consumption' do
      let(:register_trait) { :consumption }
      it { is_expected.to eq(true) }
    end
    context 'when register has label consumption_common' do
      let(:register_trait) { :consumption_common }
      it { is_expected.to eq(true) }
    end
    context 'when register has label production_water' do
      let(:register_trait) { :production_water }
      it { is_expected.to eq(false) }
    end
  end
end
