describe 'Contract::Base' do

  context "status" do

    context "when contract has no dates at all" do
      let(:contract) { Fabricate.build(:metering_point_operator_contract, begin_date: nil) }
      it "is onboarding" do
        expect(contract.status).to be_onboarding
        expect(contract.status).to eq('onboarding') # string still works
      end
    end

    context "when contract has begin date" do
      let(:contract) { Fabricate.build(:metering_point_operator_contract, begin_date: Date.yesterday) }
      it "is active" do
        expect(contract.status).to be_active
      end

      context "when contract also has end date" do
        before { contract.update_attribute(:end_date, Date.today) }
        it "is ended" do
          expect(contract.status).to be_ended
        end
      end

      context "when contract also has termination date" do
        before { contract.update_attribute(:termination_date, Date.today) }
        it "is terminated" do
          expect(contract.status).to be_terminated
        end
      end
    end
  end

  context "tariffs" do
    let(:contract) { Fabricate.build(:metering_point_operator_contract) }
    it "has none by default" do
      expect(contract.tariffs).to eq([])
    end
    it "correctly creates and saves a tariff" do
      tariff = create(:tariff)
      contract.tariffs << tariff
      expect(contract.tariffs).to eq([tariff])
    end
  end
end