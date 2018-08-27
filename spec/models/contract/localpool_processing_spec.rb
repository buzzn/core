describe 'Contract::LocalpoolProcessing', :order => :defined do

  context 'number' do
    let(:contract) { create(:contract, :localpool_processing) }
    let(:another_contract) { create(:contract, :localpool_processing) }

    it 'has a contract number' do
      contract.contract_number = nil
      contract.contract_number_addition = nil
      contract.save
      expect(contract.contract_number).to be >= 60000
      expect(contract.contract_number_addition).to be >= 0
    end

    it 'counts upwards' do
      contract.contract_number = nil
      contract.contract_number_addition = nil
      contract.save
      contract_number = contract.contract_number
      another_contract.contract_number = nil
      another_contract.contract_number_addition = nil
      another_contract.save
      expect(another_contract.contract_number).to eq contract_number+1
    end

  end

end
