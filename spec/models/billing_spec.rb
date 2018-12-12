describe 'Billing' do

  describe 'invoice number' do

    let(:contract) { create(:contract, :localpool_powertaker) }
    let(:today) { Date.today }

    context 'without an existing number' do

      context 'singular' do
        it 'generates one' do
          billing = Billing.new
          billing.begin_date = today
          billing.end_date = today + 90
          billing.contract = contract
          expect(billing.invoice_number).to be_nil
          billing.save
          expect(billing.invoice_number).not_to be_nil
          expect(billing.invoice_number).to eql "#{today.year}-#{contract.contract_number}/#{contract.contract_number_addition}-2"
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
