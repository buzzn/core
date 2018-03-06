describe 'Contract::Tariff' do

  describe 'readonly?' do
    context 'when tariff is new record' do
      let(:tariff) { build(:tariff) }
      it "is false" do
        expect(tariff).not_to be_readonly
        expect { tariff.save! }.not_to raise_error
      end
    end

    context 'when tariff is saved record' do
      let(:tariff) { create(:tariff) }
      it "is true" do
        expect(tariff).to be_readonly
        expect { tariff.save! }.to raise_error(ActiveRecord::ReadOnlyRecord)
      end
    end
  end

end
