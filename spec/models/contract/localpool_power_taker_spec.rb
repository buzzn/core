describe 'Contract::LocalpoolPowerTaker' do

  let(:contract) { create(:contract, :localpool_powertaker, market_location: create(:market_location, register: create(:register, :input))) }

  context 'begin_reading' do
    context 'Contract register has a start reading' do
      let!(:reading) { create(:reading, register: contract.market_location.register, date: contract.begin_date) }
      it 'is returned' do
        expect(contract.begin_reading).to eq(reading)
      end
    end
  end

  context 'end_reading' do
    context 'Contract register has an end reading' do
      let!(:reading) { create(:reading, register: contract.market_location.register, date: contract.end_date) }
      it 'is returned' do
        expect(contract.end_reading).to eq(reading)
      end
    end
  end
end
