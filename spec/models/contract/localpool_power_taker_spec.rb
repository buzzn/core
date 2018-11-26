describe 'Contract::LocalpoolPowerTaker', :order => :defined do

  context 'number' do
    let(:lpc) { create(:contract, :localpool_processing) }
    let(:contract) do
      create(:contract, :localpool_powertaker,
             localpool: lpc.localpool)
    end

    it 'counts upwards' do
      expect(contract.contract_number).to eq lpc.contract_number
      expect(contract.contract_number_addition).to eq lpc.contract_number_addition + 1
    end
  end

end
