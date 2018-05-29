describe 'Contract::Base' do

  context 'status' do

    context 'when contract has no dates at all' do
      let(:contract) { create(:contract, :metering_point_operator, begin_date: nil) }
      it 'is onboarding' do
        expect(contract.status).to be_onboarding
        expect(contract.status).to eq('onboarding') # string still works
        contract.update_attribute(:begin_date, Date.tomorrow)
        expect(contract).to be_onboarding
      end
    end

    context 'when contract has begin date' do
      let(:contract) { create(:contract, :metering_point_operator, begin_date: Date.yesterday) }
      it 'is active' do
        expect(contract.status).to be_active
        expect(contract).to be_active
        contract.update_attribute(:end_date, Date.tomorrow)
      end

      context 'when contract also has end date' do
        before { contract.update_attribute(:end_date, Date.today) }
        it 'is ended' do
          expect(contract.status).to be_ended
          expect(contract).to be_ended
        end
      end

      context 'when contract also has termination date' do
        before { contract.update_attribute(:termination_date, Date.today) }
        it 'is terminated' do
          expect(contract.status).to be_terminated
          expect(contract).to be_terminated
        end
      end
    end
  end

  context 'tariffs' do
    let(:contract) { create(:contract, :metering_point_operator) }
    it 'has none by default' do
      expect(contract.tariffs).to eq([])
    end
    it 'correctly creates and saves a tariff' do
      tariff = create(:tariff)
      contract.tariffs << tariff
      expect(contract.tariffs).to eq([tariff])
    end
  end

  context 'last_date' do
    context 'when end_date is set' do
      subject { build(:contract, end_date: Date.parse('2018-01-01')).last_date }
      it { is_expected.to eq(Date.parse('2017-12-31')) }
    end
    context 'when end_date is nil' do
      subject { build(:contract, end_date: nil).last_date }
      it { is_expected.to be_nil }
    end
  end
end
