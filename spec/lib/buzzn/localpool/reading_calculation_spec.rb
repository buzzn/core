describe Buzzn::Localpool::ReadingCalculation do

  let :register_with_regular_readings do
    meter = Fabricate(:easymeter_60404846)
    register = meter.input_register
    Fabricate(:reading, register_id: register.id, timestamp: Time.new(2015, 6, 1), energy_milliwatt_hour: 5000, reason: Reading::DEVICE_SETUP, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: meter.manufacturer_product_serialnumber, state: 'Z86')
    Fabricate(:reading, register_id: register.id, timestamp: Time.new(2015, 12, 31), energy_milliwatt_hour: 239000, reason: Reading::REGULAR_READING, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: meter.manufacturer_product_serialnumber, state: 'Z86')
    Fabricate(:reading, register_id: register.id, timestamp: Time.new(2016, 12, 31), energy_milliwatt_hour: 1239000, reason: Reading::REGULAR_READING, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: meter.manufacturer_product_serialnumber, state: 'Z86')
    register
  end

  let :register_with_irregular_readings do
    meter = Fabricate(:easymeter_60051611)
    register = meter.input_register
    Fabricate(:reading, register_id: register.id, timestamp: Time.new(2015, 6, 1), energy_milliwatt_hour: 5000, reason: Reading::DEVICE_SETUP, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: meter.manufacturer_product_serialnumber, state: 'Z86')
    Fabricate(:reading, register_id: register.id, timestamp: Time.new(2015, 12, 29), energy_milliwatt_hour: 237000, reason: Reading::REGULAR_READING, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: meter.manufacturer_product_serialnumber, state: 'Z86')
    Fabricate(:reading, register_id: register.id, timestamp: Time.new(2016, 12, 31), energy_milliwatt_hour: 239000, reason: Reading::REGULAR_READING, quality: Reading::FORECAST_VALUE, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: meter.manufacturer_product_serialnumber, state: 'Z86')
    Fabricate(:reading, register_id: register.id, timestamp: Time.new(2016, 6, 27), energy_milliwatt_hour: 1239000, reason: Reading::MIDWAY_READING, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: meter.manufacturer_product_serialnumber, state: 'Z86')
    Fabricate(:reading, register_id: register.id, timestamp: Time.new(2017, 1, 3), energy_milliwatt_hour: 2239000, reason: Reading::REGULAR_READING, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: meter.manufacturer_product_serialnumber, state: 'Z86')
    register
  end

  let :register_with_device_change_at_beginning do
    meter = Fabricate(:easymeter_60051585)
    register = meter.input_register
    Fabricate(:reading, register_id: register.id, timestamp: Time.new(2014, 12, 31), energy_milliwatt_hour: 11855000, reason: Reading::REGULAR_READING, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: 77134105, state: 'Z86')
    Fabricate(:reading, register_id: register.id, timestamp: Time.new(2015, 6, 1), energy_milliwatt_hour: 13855000, reason: Reading::DEVICE_CHANGE_1, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: 77134105, state: 'Z86')
    Fabricate(:reading, register_id: register.id, timestamp: Time.new(2015, 6, 1), energy_milliwatt_hour: 0, reason: Reading::DEVICE_CHANGE_2, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: meter.manufacturer_product_serialnumber, state: 'Z86')
    Fabricate(:reading, register_id: register.id, timestamp: Time.new(2015, 12, 31), energy_milliwatt_hour: 239000, reason: Reading::REGULAR_READING, quality: Reading::FORECAST_VALUE, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: meter.manufacturer_product_serialnumber, state: 'Z86')
    register
  end

  let :register_with_device_change_in_between do
    meter = Fabricate(:easymeter_60051621)
    register = meter.input_register
    Fabricate(:reading, register_id: register.id, timestamp: Time.new(2015, 6, 1), energy_milliwatt_hour: 11855000, reason: Reading::DEVICE_SETUP, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: 77134105, state: 'Z86')
    Fabricate(:reading, register_id: register.id, timestamp: Time.new(2015, 8, 4), energy_milliwatt_hour: 13855000, reason: Reading::DEVICE_CHANGE_1, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: 77134105, state: 'Z86')
    Fabricate(:reading, register_id: register.id, timestamp: Time.new(2015, 8, 4), energy_milliwatt_hour: 0, reason: Reading::DEVICE_CHANGE_2, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: meter.manufacturer_product_serialnumber, state: 'Z86')
    Fabricate(:reading, register_id: register.id, timestamp: Time.new(2015, 12, 31), energy_milliwatt_hour: 239000, reason: Reading::REGULAR_READING, quality: Reading::FORECAST_VALUE, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: meter.manufacturer_product_serialnumber, state: 'Z86')
    register
  end

  let :register_with_device_change_at_ending do
    meter = Fabricate(:easymeter_60051565)
    register = meter.input_register
    Fabricate(:reading, register_id: register.id, timestamp: Time.new(2015, 6, 1), energy_milliwatt_hour: 5000, reason: Reading::DEVICE_SETUP, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: meter.manufacturer_product_serialnumber, state: 'Z86')
    Fabricate(:reading, register_id: register.id, timestamp: Time.new(2015, 12, 31), energy_milliwatt_hour: 239000, reason: Reading::REGULAR_READING, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: meter.manufacturer_product_serialnumber, state: 'Z86')
    Fabricate(:reading, register_id: register.id, timestamp: Time.new(2016, 12, 31), energy_milliwatt_hour: 1239000, reason: Reading::DEVICE_CHANGE_1, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: meter.manufacturer_product_serialnumber, state: 'Z86')
    Fabricate(:reading, register_id: register.id, timestamp: Time.new(2016, 12, 31), energy_milliwatt_hour: 0, reason: Reading::DEVICE_CHANGE_2, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: 12345678, state: 'Z86')
    register
  end


  [:register_with_regular_readings, :register_with_irregular_readings, :register_with_device_change_at_beginning,
   :register_with_device_change_in_between, :register_with_device_change_at_ending].each do |scenario|

    [Time.new(2015, 6, 1), nil].each do |time|

      it "gets the right first reading for #{scenario} with time #{time.nil? ? 'nil' : time}" do
        register = send(scenario)
        first_reading = Buzzn::Localpool::ReadingCalculation.get_first_reading(register, time, 2015)
        if scenario == :register_with_device_change_at_beginning && !time.nil?
          expect(first_reading).to eq Reading.by_register_id(register.id).by_reason(Reading::DEVICE_CHANGE_2).first
        else
          expect(first_reading).to eq Reading.by_register_id(register.id).sort('timestamp': 1).sort('reason': 1).first
        end
      end
    end
  end

  # When commenting in this stuff, the test always fails with the "violates NOT NULL constraint" error when Fabricating registers ...
  # The test suite seems to have a big bug :(

  # [:register_with_regular_readings, :register_with_irregular_readings, :register_with_device_change_at_beginning,
  #  :register_with_device_change_in_between, :register_with_device_change_at_ending].each do |scenario|

  #   [Time.new(2015, 12, 31), nil].each do |time|

  #     it "gets the right last reading for #{scenario} with time #{time.nil? ? 'nil' : time}" do
  #       register = send(scenario)
  #       last_reading = Buzzn::Localpool::ReadingCalculation.get_last_reading(register, time, 2015)
  #       if scenario == :register_with_device_change_at_ending && !time.nil?
  #         expect(last_reading).to eq Reading.by_register_id(register.id).by_reason(Reading::DEVICE_CHANGE_1).first
  #       else
  #         expect(last_reading).to eq Reading.by_register_id(register.id).in_year(2015).sort('timestamp': -1).sort('reason': 1).first
  #       end
  #     end
  #   end
  # end
end