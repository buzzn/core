describe 'Contract::Tariff' do

  describe 'readonly?' do
    context 'when tariff is new record' do
      let(:tariff) { build(:tariff) }
      it 'is false' do
        expect { tariff.save! }.not_to raise_error
      end
    end

    context 'when tariff is saved record' do
      let(:tariff) { create(:tariff) }
      before { tariff.begin_date = Date.today }
      it 'is true' do
        expect { tariff.save! }.to raise_error(ActiveRecord::RecordNotSaved)
      end
    end
  end

end
