describe "Reading Model" do
  it 'gets readings via in_year scope' do
    reading1 = Fabricate(:reading, register_id: 'some-id', timestamp: Time.new(2015, 6, 1), energy_milliwatt_hour: 5000, reason: Reading::DEVICE_SETUP, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: 'some-number', state: 'Z86')
    reading2 = Fabricate(:reading, register_id: 'some-id', timestamp: Time.new(2015, 12, 29), energy_milliwatt_hour: 237000, reason: Reading::REGULAR_READING, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: 'some-number', state: 'Z86')
    reading3 = Fabricate(:reading, register_id: 'some-id', timestamp: Time.new(2016, 6, 27), energy_milliwatt_hour: 1239000, reason: Reading::MIDWAY_READING, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: 'some-number', state: 'Z86')
    reading4 = Fabricate(:reading, register_id: 'some-id', timestamp: Time.new(2016, 12, 31), energy_milliwatt_hour: 239000, reason: Reading::REGULAR_READING, quality: Reading::FORECAST_VALUE, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: 'some-number', state: 'Z86')
    reading5 = Fabricate(:reading, register_id: 'some-id', timestamp: Time.new(2017, 1, 1), energy_milliwatt_hour: 2239000, reason: Reading::REGULAR_READING, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: 'some-number', state: 'Z86')

    expect(Reading.all.in_year(2016)).to eq [reading3, reading4]
    expect(Reading.all.in_year(2017)).to eq [reading5]
  end

  it 'gets readings via at scope' do
    reading1 = Fabricate(:reading, register_id: 'some-id', timestamp: Time.new(2015, 6, 1), energy_milliwatt_hour: 5000, reason: Reading::DEVICE_SETUP, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: 'some-number', state: 'Z86')
    reading2 = Fabricate(:reading, register_id: 'some-id', timestamp: Time.new(2015, 6, 2), energy_milliwatt_hour: 237000, reason: Reading::REGULAR_READING, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: 'some-number', state: 'Z86')
    reading3 = Fabricate(:reading, register_id: 'some-id', timestamp: Time.new(2015, 6, 3, 1, 2, 3), energy_milliwatt_hour: 1239000, reason: Reading::MIDWAY_READING, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: 'some-number', state: 'Z86')
    reading4 = Fabricate(:reading, register_id: 'some-id', timestamp: Time.new(2015, 6, 3, 1, 2, 4), energy_milliwatt_hour: 239000, reason: Reading::REGULAR_READING, quality: Reading::FORECAST_VALUE, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: 'some-number', state: 'Z86')
    reading5 = Fabricate(:reading, register_id: 'some-id', timestamp: Time.new(2015, 6, 3, 1, 2, 5), energy_milliwatt_hour: 2239000, reason: Reading::REGULAR_READING, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: 'some-number', state: 'Z86')

    expect(Reading.all.at(Time.new(2015, 6, 2))).to eq [reading2]
    expect(Reading.all.at(Time.new(2015, 6, 3, 1, 2, 4))).to eq [reading4]
  end

  it 'gets readings via by_reason and without_reason scope' do
    reading1 = Fabricate(:reading, register_id: 'some-id', timestamp: Time.new(2015, 6, 1), energy_milliwatt_hour: 5000, reason: Reading::DEVICE_SETUP, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: 'some-number', state: 'Z86')
    reading2 = Fabricate(:reading, register_id: 'some-id', timestamp: Time.new(2015, 6, 2), energy_milliwatt_hour: 237000, reason: Reading::REGULAR_READING, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: 'some-number', state: 'Z86')
    reading3 = Fabricate(:reading, register_id: 'some-id', timestamp: Time.new(2015, 6, 3, 1, 2, 3), energy_milliwatt_hour: 1239000, reason: Reading::MIDWAY_READING, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: 'some-number', state: 'Z86')
    reading4 = Fabricate(:reading, register_id: 'some-id', timestamp: Time.new(2015, 6, 3, 1, 2, 4), energy_milliwatt_hour: 239000, reason: Reading::REGULAR_READING, quality: Reading::FORECAST_VALUE, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: 'some-number', state: 'Z86')
    reading5 = Fabricate(:reading, register_id: 'some-id', timestamp: Time.new(2015, 6, 3, 1, 2, 5), energy_milliwatt_hour: 2239000, reason: Reading::DEVICE_REMOVAL, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: 'some-number', state: 'Z86')

    expect(Reading.all.by_reason(Reading::DEVICE_SETUP)).to eq [reading1]
    expect(Reading.all.by_reason(Reading::REGULAR_READING)).to eq [reading2, reading4]
    expect(Reading.all.by_reason(Reading::DEVICE_SETUP, Reading::MIDWAY_READING)).to eq [reading1, reading3]
    expect{Reading.all.by_reason('blabla')}.to raise_error ArgumentError

    expect(Reading.all.without_reason(Reading::DEVICE_SETUP)).to eq [reading2, reading3, reading4, reading5]
    expect(Reading.all.without_reason(Reading::REGULAR_READING)).to eq [reading1, reading3, reading5]
    expect(Reading.all.without_reason(Reading::DEVICE_SETUP, Reading::MIDWAY_READING)).to eq [reading2, reading4, reading5]
    expect{Reading.all.without_reason('blabla')}.to raise_error ArgumentError
  end
end