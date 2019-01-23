describe Accounting::Entry do

  let(:localpool) { create(:group, :localpool) }
  let(:contract) do
    create(:contract, :localpool_processing,
           customer: localpool.owner,
           contractor: Organization::Market.buzzn,
           localpool: localpool)
  end

  context 'hashing' do
    it 'works' do
      first_entry = create(:accounting_entry, contract: contract)
      expect(Accounting::Entry.count).to eql 1
      expect(first_entry.checksum).not_to eql ''
      expect(first_entry.previous_checksum).to eql nil
      second_entry = create(:accounting_entry, contract: contract)
      expect(second_entry.checksum).not_to eql ''
      expect(second_entry.previous_checksum).to eql first_entry.checksum
    end

    context 'tampering' do

      it 'is tamperproof' do
        first_entry = create(:accounting_entry, contract: contract)
        checksum_original = first_entry.checksum
        first_entry.amount = 9999
        expect(first_entry.calculate_checksum).not_to eql checksum_original
      end

    end
  end

end
