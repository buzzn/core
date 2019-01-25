describe 'Billing' do

  describe 'invoice number' do

    let(:contract) { create(:contract, :localpool_powertaker) }
    let(:accounting_entry) { create(:accounting_entry, contract: contract) }
    let(:today) { Date.today }

    context 'without an existing number', order: :defined do

      context 'singular' do
        it 'generates one' do
          billing = Billing.new
          billing.begin_date = today
          billing.end_date = today + 90
          billing.contract = contract
          expect(billing.invoice_number).to be_nil
          billing.save
          expect(billing.invoice_number).not_to be_nil
          expect(billing.full_invoice_number).to eql "#{today.year}-#{contract.contract_number}/#{contract.contract_number_addition}"
          expect(billing.invoice_number_addition).not_to be_nil
        end

      end

      context 'singular with uniqueness' do
        let(:another_billing) { create(:billing, contract: contract, invoice_number: nil) }

        it 'is unique' do
          expect(another_billing.full_invoice_number).to eql "#{today.year}-#{contract.contract_number}/#{contract.contract_number_addition}"
          expect(another_billing.invoice_number_addition).to eql 1
          billing = Billing.new
          billing.begin_date = today
          billing.end_date = today + 90
          billing.contract = contract
          expect(billing.invoice_number).to be_nil
          billing.save
          expect(billing.invoice_number_addition).to eql 2
          expect(billing.full_invoice_number).to eql "#{today.year}-#{contract.contract_number}/#{billing.invoice_number_addition}"
        end
      end

      context 'billing_cycle' do
        it 'generates one'
      end

    end

    context 'accounting_entry' do
      it 'assigns' do
        billing = Billing.new
        billing.begin_date = today
        billing.end_date = today + 90
        billing.contract = contract
        billing.accounting_entry = accounting_entry
        billing.save

        accounting_entry.reload
        expect(accounting_entry.billing).to eql billing
      end
    end

    context 'with an existing number' do

      it 'does not generate one' do
        billing = Billing.new
        billing.begin_date = today
        billing.end_date = today + 90
        billing.invoice_number = '1337-foobar'
        billing.contract = contract
        billing.save
        expect(billing.invoice_number).to eql '1337-foobar'
      end

    end

  end

end
