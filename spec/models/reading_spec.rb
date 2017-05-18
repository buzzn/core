describe "Reading Model" do

  entity(:reading_1) { Fabricate(:reading, register_id: 'some-id', timestamp: Time.new(2015, 6, 1), energy_milliwatt_hour: 5000, reason: Reading::DEVICE_SETUP, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: 'some-number', state: 'Z86') }
  entity(:reading_2) { Fabricate(:reading, register_id: 'some-id', timestamp: Time.new(2015, 12, 29), energy_milliwatt_hour: 237000, reason: Reading::REGULAR_READING, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: 'some-number', state: 'Z86') }
  entity(:reading_3) { Fabricate(:reading, register_id: 'some-id', timestamp: Time.new(2016, 6, 27), energy_milliwatt_hour: 1239000, reason: Reading::MIDWAY_READING, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: 'some-number', state: 'Z86') }
  entity(:reading_4) { Fabricate(:reading, register_id: 'some-id', timestamp: Time.new(2016, 12, 31), energy_milliwatt_hour: 239000, reason: Reading::REGULAR_READING, quality: Reading::FORECAST_VALUE, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: 'some-number', state: 'Z86') }
  entity(:reading_5) { Fabricate(:reading, register_id: 'some-id', timestamp: Time.new(2017, 1, 1), energy_milliwatt_hour: 2239000, reason: Reading::REGULAR_READING, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: 'some-number', state: 'Z86') }

  entity(:reading_6) { Fabricate(:reading, register_id: 'some-id', timestamp: Time.new(2015, 6, 2), energy_milliwatt_hour: 237000, reason: Reading::REGULAR_READING, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: 'some-number', state: 'Z86') }
  entity(:reading_7) { Fabricate(:reading, register_id: 'some-id', timestamp: Time.new(2015, 6, 3, 1, 2, 3), energy_milliwatt_hour: 1239000, reason: Reading::MIDWAY_READING, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: 'some-number', state: 'Z86') }
  entity(:reading_8) { Fabricate(:reading, register_id: 'some-id', timestamp: Time.new(2015, 6, 3, 1, 2, 4), energy_milliwatt_hour: 239000, reason: Reading::REGULAR_READING, quality: Reading::FORECAST_VALUE, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: 'some-number', state: 'Z86') }
  entity(:reading_9) { Fabricate(:reading, register_id: 'some-id', timestamp: Time.new(2015, 6, 3, 1, 2, 5), energy_milliwatt_hour: 2239000, reason: Reading::REGULAR_READING, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: 'some-number', state: 'Z86') }

  it 'gets readings via in_year scope' do
    expect(Reading.all.in_year(2016)).to match_array [reading_3, reading_4]
    expect(Reading.all.in_year(2017)).to match_array [reading_5]
  end

  it 'gets readings via at scope' do
    expect(Reading.all.at(Time.new(2015, 6, 2))).to match_array [reading_6]
    expect(Reading.all.at(Time.new(2015, 6, 3, 1, 2, 4))).to match_array [reading_8]
  end

  it 'gets readings via by_reason and without_reason scope' do
    expect(Reading.all.by_reason(Reading::DEVICE_SETUP)).to match_array [reading_1]
    expect(Reading.all.by_reason(Reading::REGULAR_READING)).to match_array [reading_2, reading_4, reading_5, reading_6, reading_8, reading_9]
    expect(Reading.all.by_reason(Reading::DEVICE_SETUP, Reading::MIDWAY_READING)).to match_array [reading_1, reading_3, reading_7]
    expect{Reading.all.by_reason('blabla')}.to raise_error ArgumentError

    expect(Reading.all.without_reason(Reading::DEVICE_SETUP)).to match_array [reading_2, reading_3, reading_4, reading_5, reading_6, reading_7, reading_8, reading_9]
    expect(Reading.all.without_reason(Reading::REGULAR_READING)).to match_array [reading_1, reading_3, reading_7]
    expect(Reading.all.without_reason(Reading::DEVICE_SETUP, Reading::MIDWAY_READING)).to match_array [reading_2, reading_4, reading_5, reading_6, reading_8, reading_9]
    expect{Reading.all.without_reason('blabla')}.to raise_error ArgumentError
  end
end