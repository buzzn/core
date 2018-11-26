describe 'Contract::LocalpoolProcessing', :order => :defined do

  context 'number' do
    let(:contract) { create(:contract, :localpool_processing) }
    let(:another_contract) { create(:contract, :localpool_processing) }

    it 'has a contract number' do
      expect(contract.contract_number).to be >= 60000
      expect(contract.contract_number_addition).to be >= 0
    end

    it 'counts upwards' do
      contract_number = contract.contract_number
      expect(another_contract.contract_number).to eq contract_number+1
    end

    it 'changes the range even when number is higher' do
      # 80000 is clearly above the current setting of 60000
      # make sure that new contracts are forced 'down' into range
      contract.contract_number = 80000
      contract.contract_number_addition = 0
      contract.save
      another_contract.contract_number = nil
      another_contract.contract_number_addition = nil
      another_contract.save
      expect(another_contract.contract_number).to be >= 60000
      expect(another_contract.contract_number).to be <  70000
    end

  end

end
