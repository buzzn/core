describe 'Contract::Payment' do

  context 'scopes' do
    let(:contract) { create(:contract, :localpool_powertaker) }
    let!(:payment_1) { create(:payment, begin_date: Date.new(2017, 3, 1), contract: contract) }
    let!(:payment_2) { create(:payment, begin_date: Date.new(2018, 4, 1), contract: contract) }
    let!(:payment_3) { create(:payment, begin_date: Date.new(2018, 8, 1), contract: contract) }

    context 'in_year' do

      it 'works' do
        expect(contract.payments.in_year(2017).count).to eql 1
        expect(contract.payments.in_year(2018).count).to eql 2
      end

    end

    context 'at' do

      it 'works' do
        expect(contract.payments.at(Date.new(2017, 10, 4))).to eql payment_1
        expect(contract.payments.at(Date.new(2018, 3, 31))).to eql payment_1
        expect(contract.payments.at(Date.new(2018, 4, 4))).to eql payment_2
      end
    end

    context 'current' do

      it 'works' do
        expect(contract.payments.current).to eql payment_3
      end

    end

  end

end
