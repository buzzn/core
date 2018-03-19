describe 'Reading::Single' do

  describe 'constants' do
    subject { Reading::Single }
    describe 'reasons' do
      it 'contain all expected values' do
        expect(subject.reasons.keys).to eq(%w(device_setup device_change_1 device_change_2 device_removal regular_reading midway_reading contract_change device_parameter_change balancing_zone_change))
        expect(subject.reasons.values).to eq(%w(IOM COM1 COM2 ROM PMR COT COS CMP COB))
      end
    end
    describe 'qualities' do
      it 'contain all expected values' do
        expect(subject.qualities.keys).to eq(%w(unusable substitute_value energy_quantity_summarized forecast_value read_out proposed_value))
        expect(subject.qualities.values).to eq(%w(20 67 79 187 220 201))
      end
    end
    describe 'sources' do
      it 'contain all expected values' do
        expect(subject.sources.keys).to eq(%w(smart manual))
        expect(subject.sources.values).to eq(%w(SM MAN))
      end
    end
    describe 'status' do
      it 'contain all expected values' do
        expect(subject.status.keys).to eq(%w(z83 z84 z86))
        expect(subject.status.values).to eq(%w(Z83 Z84 Z86))
      end
    end
    describe 'read_by' do
      it 'contain all expected values' do
        expect(subject.read_by.keys).to eq(%w(buzzn power_taker power_giver distribution_system_operator))
        expect(subject.read_by.values).to eq(%w(BN SN SG VNB))
      end
    end
    describe 'units' do
      it 'contain all expected values' do
        expect(subject.units.keys).to eq(%w(watt_hour watt cubic_meter))
        expect(subject.units.values).to eq(%w(Wh W m³))
      end
    end
  end

  describe 'readonly?' do
    context 'when reading is new record' do
      let(:reading) { build(:reading) }
      it 'is false' do
        expect(reading).not_to be_readonly
        expect { reading.save! }.not_to raise_error
      end
    end

    context 'when reading is saved record' do
      let(:reading) { create(:reading) }
      it 'is true' do
        expect(reading).to be_readonly
        expect { reading.save! }.to raise_error(ActiveRecord::ReadOnlyRecord)
      end
    end
  end

end
