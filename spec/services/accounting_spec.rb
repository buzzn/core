describe Services::Accounting do

  let(:service) { Services::Accounting.new }
  let(:localpool) { create(:group, :localpool) }
  let(:contract) do
    create(:contract, :localpool_powertaker,
           contractor: Organization::Market.buzzn,
           localpool: localpool)
  end

  let(:operator) { create(:account, :buzzn_operator) }

  context 'booking' do

    it 'books correctly' do
      service.book(operator, contract, 420, comment: 'initial debit')
      expect(Accounting::Entry.for_contract(contract).count).to eql 1
    end

  end

  context 'calculation' do

    let(:another_contract) do
      create(:contract, :localpool_powertaker,
             contractor: Organization::Market.buzzn,
             localpool: localpool)
    end

    it 'calculated correctly' do
      service.book(operator, contract, 420)
      service.book(operator, contract, 137)
      service.book(operator, contract, 777)
      service.book(operator, contract, 555)
      service.book(operator, contract, -889)
      expect(Accounting::Entry.for_contract(contract).count).to eql 5
      expect(service.balance(contract)).to eql 1000
      service.book(operator, another_contract, 737)
      expect(service.balance(contract)).to eql 1000
    end

    it 'calculates correctly - with certain entry' do
      entry1 = service.book(operator, contract, 100)
      entry2 = service.book(operator, contract, 100)
      entry3 = service.book(operator, contract, 100)
      entry4 = service.book(operator, another_contract, 50)
      entry5 = service.book(operator, contract, 100)
      entry6 = service.book(operator, contract, 100)
      expect(Accounting::Entry.for_contract(contract).count).to eql 5
      expect(service.balance(contract)).to eql 500
      expect(service.balance_at(entry2)).to eql 200
      expect(service.balance_at(entry5)).to eql 400
    end

  end

end
