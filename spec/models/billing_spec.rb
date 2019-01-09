describe 'Billing' do

  describe 'invoice number' do

    let(:contract) { create(:contract, :localpool_powertaker) }
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
          expect(billing.invoice_number).to eql "#{today.year}-#{contract.contract_number}/#{contract.contract_number_addition}"
          expect(billing.invoice_number_addition).not_to be_nil
        end

      end

      context 'singular with uniqueness' do
        let(:another_billing) { create(:billing, contract: contract, invoice_number: nil) }

        it 'is unique' do
          expect(another_billing.invoice_number).to eql "#{today.year}-#{contract.contract_number}/#{contract.contract_number_addition}"
          expect(another_billing.invoice_number_addition).to eql 0
          billing = Billing.new
          billing.begin_date = today
          billing.end_date = today + 90
          billing.contract = contract
          expect(billing.invoice_number).to be_nil
          billing.save
          expect(billing.invoice_number).to eql "#{today.year}-#{contract.contract_number}/#{contract.contract_number_addition}"
          expect(billing.invoice_number_addition).to eql 1
        end
      end

      context 'billing_cycle' do
        it 'generates one'
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
