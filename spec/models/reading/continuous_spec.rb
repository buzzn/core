describe 'Reading::Continuous' do

  describe 'constants' do
    subject { Reading::Continuous }
    describe 'reasons' do
      it 'contain all expected values' do
        expect(subject.reasons).to eq(%w(device_setup device_change_1 device_change_2 device_removal regular_reading midway_reading contract_change device_parameter_change balancing_zone_change other))
      end
    end
    describe 'qualities' do
      it 'contain all expected values' do
        expect(subject.qualities).to eq(%w(unusable substitute_value energy_quantity_summarized forecast_value read_out proposed_value))
      end
    end
    describe 'sources' do
      it 'contain all expected values' do
        expect(subject.sources).to eq(%w(buzzn_systems customer_lsg lsn vnb third_party_msb_mdl other user_input slp sep_pv sep_bhkw))
      end
    end
  end

  describe "legacy tests" do
    entity(:reading_1) { Fabricate(:reading, register_id: 'some-id', timestamp: Time.new(2015, 6, 1), energy_milliwatt_hour: 5000, reason: Reading::Continuous::DEVICE_SETUP, quality: Reading::Continuous::READ_OUT, source: Reading::Continuous::BUZZN, meter_serialnumber: 'some-number', state: 'Z86') }
    entity(:reading_2) { Fabricate(:reading, register_id: 'some-id', timestamp: Time.new(2015, 12, 29), energy_milliwatt_hour: 237000, reason: Reading::Continuous::REGULAR_READING, quality: Reading::Continuous::READ_OUT, source: Reading::Continuous::BUZZN, meter_serialnumber: 'some-number', state: 'Z86') }
    entity(:reading_3) { Fabricate(:reading, register_id: 'some-id', timestamp: Time.new(2016, 6, 27), energy_milliwatt_hour: 1239000, reason: Reading::Continuous::MIDWAY_READING, quality: Reading::Continuous::READ_OUT, source: Reading::Continuous::BUZZN, meter_serialnumber: 'some-number', state: 'Z86') }
    entity(:reading_4) { Fabricate(:reading, register_id: 'some-id', timestamp: Time.new(2016, 12, 31), energy_milliwatt_hour: 239000, reason: Reading::Continuous::REGULAR_READING, quality: Reading::Continuous::FORECAST_VALUE, source: Reading::Continuous::BUZZN, meter_serialnumber: 'some-number', state: 'Z86') }
    entity(:reading_5) { Fabricate(:reading, register_id: 'some-id', timestamp: Time.new(2017, 1, 1), energy_milliwatt_hour: 2239000, reason: Reading::Continuous::REGULAR_READING, quality: Reading::Continuous::READ_OUT, source: Reading::Continuous::BUZZN, meter_serialnumber: 'some-number', state: 'Z86') }

    entity(:reading_6) { Fabricate(:reading, register_id: 'some-id', timestamp: Time.new(2015, 6, 2), energy_milliwatt_hour: 237000, reason: Reading::Continuous::REGULAR_READING, quality: Reading::Continuous::READ_OUT, source: Reading::Continuous::BUZZN, meter_serialnumber: 'some-number', state: 'Z86') }
    entity(:reading_7) { Fabricate(:reading, register_id: 'some-id', timestamp: Time.new(2015, 6, 3, 1, 2, 3), energy_milliwatt_hour: 1239000, reason: Reading::Continuous::MIDWAY_READING, quality: Reading::Continuous::READ_OUT, source: Reading::Continuous::BUZZN, meter_serialnumber: 'some-number', state: 'Z86') }
    entity(:reading_8) { Fabricate(:reading, register_id: 'some-id', timestamp: Time.new(2015, 6, 3, 1, 2, 4), energy_milliwatt_hour: 239000, reason: Reading::Continuous::REGULAR_READING, quality: Reading::Continuous::FORECAST_VALUE, source: Reading::Continuous::BUZZN, meter_serialnumber: 'some-number', state: 'Z86') }
    entity(:reading_9) { Fabricate(:reading, register_id: 'some-id', timestamp: Time.new(2015, 6, 3, 1, 2, 5), energy_milliwatt_hour: 2239000, reason: Reading::Continuous::REGULAR_READING, quality: Reading::Continuous::READ_OUT, source: Reading::Continuous::BUZZN, meter_serialnumber: 'some-number', state: 'Z86') }

    xit 'gets readings via in_year scope' do
      expect(Reading::Continuous.all.in_year(2016)).to match_array [reading_3, reading_4]
      expect(Reading::Continuous.all.in_year(2017)).to match_array [reading_5]
    end

    xit 'gets readings via at scope' do
      expect(Reading::Continuous.all.at(Time.new(2015, 6, 2))).to match_array [reading_6]
      expect(Reading::Continuous.all.at(Time.new(2015, 6, 3, 1, 2, 4))).to match_array [reading_8]
    end

    xit 'gets readings via by_reason and without_reason scope' do
      expect(Reading::Continuous.all.by_reason(Reading::Continuous::DEVICE_SETUP)).to match_array [reading_1]
      expect(Reading::Continuous.all.by_reason(Reading::Continuous::REGULAR_READING)).to match_array [reading_2, reading_4, reading_5, reading_6, reading_8, reading_9]
      expect(Reading::Continuous.all.by_reason(Reading::Continuous::DEVICE_SETUP, Reading::Continuous::MIDWAY_READING)).to match_array [reading_1, reading_3, reading_7]
      expect{Reading::Continuous.all.by_reason('blabla')}.to raise_error ArgumentError

      expect(Reading::Continuous.all.without_reason(Reading::Continuous::DEVICE_SETUP)).to match_array [reading_2, reading_3, reading_4, reading_5, reading_6, reading_7, reading_8, reading_9]
      expect(Reading::Continuous.all.without_reason(Reading::Continuous::REGULAR_READING)).to match_array [reading_1, reading_3, reading_7]
      expect(Reading::Continuous.all.without_reason(Reading::Continuous::DEVICE_SETUP, Reading::Continuous::MIDWAY_READING)).to match_array [reading_2, reading_4, reading_5, reading_6, reading_8, reading_9]
      expect{Reading::Continuous.all.without_reason('blabla')}.to raise_error ArgumentError
    end
  end

end
