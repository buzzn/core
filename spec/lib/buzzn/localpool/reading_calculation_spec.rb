describe Buzzn::Localpool::ReadingCalculation do

  let :register_with_regular_readings do
    meter = Fabricate(:input_meter)
    register = meter.input_register
    Fabricate(:reading, register_id: register.id, timestamp: Time.new(2015, 6, 1), energy_milliwatt_hour: 5000, reason: Reading::DEVICE_SETUP, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: meter.manufacturer_product_serialnumber, state: 'Z86')
    Fabricate(:reading, register_id: register.id, timestamp: Time.new(2015, 12, 31), energy_milliwatt_hour: 239000, reason: Reading::REGULAR_READING, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: meter.manufacturer_product_serialnumber, state: 'Z86')
    Fabricate(:reading, register_id: register.id, timestamp: Time.new(2016, 12, 31), energy_milliwatt_hour: 1239000, reason: Reading::REGULAR_READING, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: meter.manufacturer_product_serialnumber, state: 'Z86')
    register
  end

  let :register_with_irregular_readings do
    meter = Fabricate(:input_meter)
    register = meter.input_register
    Fabricate(:reading, register_id: register.id, timestamp: Time.new(2015, 6, 1), energy_milliwatt_hour: 5000, reason: Reading::DEVICE_SETUP, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: meter.manufacturer_product_serialnumber, state: 'Z86')
    Fabricate(:reading, register_id: register.id, timestamp: Time.new(2015, 12, 29), energy_milliwatt_hour: 237000, reason: Reading::REGULAR_READING, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: meter.manufacturer_product_serialnumber, state: 'Z86')
    Fabricate(:reading, register_id: register.id, timestamp: Time.new(2016, 12, 31), energy_milliwatt_hour: 239000, reason: Reading::REGULAR_READING, quality: Reading::FORECAST_VALUE, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: meter.manufacturer_product_serialnumber, state: 'Z86')
    Fabricate(:reading, register_id: register.id, timestamp: Time.new(2016, 6, 27), energy_milliwatt_hour: 1239000, reason: Reading::MIDWAY_READING, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: meter.manufacturer_product_serialnumber, state: 'Z86')
    Fabricate(:reading, register_id: register.id, timestamp: Time.new(2017, 1, 3), energy_milliwatt_hour: 2239000, reason: Reading::REGULAR_READING, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: meter.manufacturer_product_serialnumber, state: 'Z86')
    register
  end

  let :register_with_device_change_at_beginning do
    meter = Fabricate(:input_meter)
    register = meter.input_register
    Fabricate(:reading, register_id: register.id, timestamp: Time.new(2014, 12, 31), energy_milliwatt_hour: 11855000, reason: Reading::REGULAR_READING, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: 77134105, state: 'Z86')
    Fabricate(:reading, register_id: register.id, timestamp: Time.new(2015, 6, 1), energy_milliwatt_hour: 13855000, reason: Reading::DEVICE_CHANGE_1, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: 77134105, state: 'Z86')
    Fabricate(:reading, register_id: register.id, timestamp: Time.new(2015, 6, 1), energy_milliwatt_hour: 0, reason: Reading::DEVICE_CHANGE_2, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: meter.manufacturer_product_serialnumber, state: 'Z86')
    Fabricate(:reading, register_id: register.id, timestamp: Time.new(2015, 12, 31), energy_milliwatt_hour: 239000, reason: Reading::REGULAR_READING, quality: Reading::FORECAST_VALUE, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: meter.manufacturer_product_serialnumber, state: 'Z86')
    register
  end

  let :register_with_device_change_in_between do
    meter = Fabricate(:input_meter)
    register = meter.input_register
    Fabricate(:reading, register_id: register.id, timestamp: Time.new(2015, 6, 1), energy_milliwatt_hour: 11855000, reason: Reading::DEVICE_SETUP, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: 77134105, state: 'Z86')
    Fabricate(:reading, register_id: register.id, timestamp: Time.new(2015, 8, 4), energy_milliwatt_hour: 13855000, reason: Reading::DEVICE_CHANGE_1, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: 77134105, state: 'Z86')
    Fabricate(:reading, register_id: register.id, timestamp: Time.new(2015, 8, 4), energy_milliwatt_hour: 0, reason: Reading::DEVICE_CHANGE_2, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: meter.manufacturer_product_serialnumber, state: 'Z86')
    Fabricate(:reading, register_id: register.id, timestamp: Time.new(2015, 12, 31), energy_milliwatt_hour: 239000, reason: Reading::REGULAR_READING, quality: Reading::FORECAST_VALUE, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: meter.manufacturer_product_serialnumber, state: 'Z86')
    register
  end

  let :register_with_device_change_at_ending do
    meter = Fabricate(:input_meter)
    register = meter.input_register
    Fabricate(:reading, register_id: register.id, timestamp: Time.new(2015, 6, 1), energy_milliwatt_hour: 5000, reason: Reading::DEVICE_SETUP, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: meter.manufacturer_product_serialnumber, state: 'Z86')
    Fabricate(:reading, register_id: register.id, timestamp: Time.new(2015, 12, 31), energy_milliwatt_hour: 1239000, reason: Reading::DEVICE_CHANGE_1, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: meter.manufacturer_product_serialnumber, state: 'Z86')
    Fabricate(:reading, register_id: register.id, timestamp: Time.new(2015, 12, 31), energy_milliwatt_hour: 0, reason: Reading::DEVICE_CHANGE_2, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: 12345678, state: 'Z86')
    Fabricate(:reading, register_id: register.id, timestamp: Time.new(2016, 12, 31), energy_milliwatt_hour: 239000, reason: Reading::REGULAR_READING, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: 12345678, state: 'Z86')
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

  [:register_with_regular_readings, :register_with_irregular_readings, :register_with_device_change_at_beginning,
   :register_with_device_change_in_between, :register_with_device_change_at_ending].each do |scenario|

    [Time.new(2015, 12, 31), nil].each do |time|

      it "gets the right last reading for #{scenario} with time #{time.nil? ? 'nil' : time}" do
        register = send(scenario)
        if scenario != :register_with_irregular_readings || time.nil?
          last_reading = Buzzn::Localpool::ReadingCalculation.get_last_reading(register, time, 2015)
          if scenario == :register_with_device_change_at_ending && !time.nil?
            expect(last_reading).to eq Reading.by_register_id(register.id).by_reason(Reading::DEVICE_CHANGE_1).first
          else
            expect(last_reading).to eq Reading.by_register_id(register.id).in_year(2015).sort('timestamp': -1).sort('reason': 1).first
          end
        else
          expect { Buzzn::Localpool::ReadingCalculation.get_last_reading(register, time, 2015) }.to raise_error ActiveRecord::RecordNotFound
        end
      end
    end
  end

  it 'selects the closest reading' do
    date_1 = Date.new(2014, 1, 1)
    date_2 = Date.new(2015, 3, 1)
    date_3 = Date.new(2016, 1, 1)

    reading_1 = Fabricate(:reading, timestamp: Time.new(2015, 1, 1).utc)
    reading_2 = Fabricate(:reading, timestamp: Time.new(2015, 10, 1).utc)

    expect(Buzzn::Localpool::ReadingCalculation.select_closest_reading(date_1, reading_1, reading_2)).to eq reading_1
    expect(Buzzn::Localpool::ReadingCalculation.select_closest_reading(date_1, reading_2, reading_1)).to eq reading_1
    expect(Buzzn::Localpool::ReadingCalculation.select_closest_reading(date_2, reading_1, reading_2)).to eq reading_1
    expect(Buzzn::Localpool::ReadingCalculation.select_closest_reading(date_3, reading_1, reading_2)).to eq reading_2

    # corner case test: if the date is exactly in the middle of the readings, the first one is returned
    reading_3 = Fabricate(:reading, timestamp: Time.new(2015, 10, 5).utc)
    date_4 = Date.new(2015, 10, 3)

    expect(Buzzn::Localpool::ReadingCalculation.select_closest_reading(date_4, reading_3, reading_2)).to eq reading_3
    expect(Buzzn::Localpool::ReadingCalculation.select_closest_reading(date_4, reading_2, reading_3)).to eq reading_2
  end

  it 'adjusts end date' do
    end_date = Time.new(2015, 6, 1).utc
    accounting_year = 2015

    expect(Buzzn::Localpool::ReadingCalculation.adjust_end_date(end_date, accounting_year)).to eq Time.new(2015, 6, 1).end_of_year.beginning_of_day
    expect(Buzzn::Localpool::ReadingCalculation.adjust_end_date(end_date, accounting_year - 1)).to eq (Time.new(2015, 6, 1).end_of_year.beginning_of_day - 1.year)
  end

  it 'gets readings at device change' do
    begin_date = Time.new(2015, 6, 1).utc
    end_date = Time.new(2015, 12, 31).utc
    meter = Fabricate(:easymeter_60051609)
    register = meter.input_register
    Fabricate(:reading, register_id: register.id, timestamp: Time.new(2015, 6, 1), energy_milliwatt_hour: 11855000, reason: Reading::DEVICE_SETUP, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: 77134105, state: 'Z86')
    reading_1 = Fabricate(:reading, register_id: register.id, timestamp: Time.new(2015, 8, 4), energy_milliwatt_hour: 13855000, reason: Reading::DEVICE_CHANGE_1, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: 77134105, state: 'Z86')
    reading_2 = Fabricate(:reading, register_id: register.id, timestamp: Time.new(2015, 8, 4), energy_milliwatt_hour: 0, reason: Reading::DEVICE_CHANGE_2, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: meter.manufacturer_product_serialnumber, state: 'Z86')
    Fabricate(:reading, register_id: register.id, timestamp: Time.new(2015, 12, 31), energy_milliwatt_hour: 239000, reason: Reading::REGULAR_READING, quality: Reading::FORECAST_VALUE, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: meter.manufacturer_product_serialnumber, state: 'Z86')
    reading_3 = Fabricate(:reading, register_id: register.id, timestamp: Time.new(2016, 12, 31), energy_milliwatt_hour: 439000, reason: Reading::DEVICE_CHANGE_1, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: meter.manufacturer_product_serialnumber, state: 'Z86')
    reading_4 = Fabricate(:reading, register_id: register.id, timestamp: Time.new(2016, 12, 31), energy_milliwatt_hour: 0, reason: Reading::DEVICE_CHANGE_2, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: 12345678, state: 'Z86')
    reading_5 = Fabricate(:reading, register_id: register.id, timestamp: Time.new(2014, 1, 1), energy_milliwatt_hour: 439000, reason: Reading::DEVICE_CHANGE_1, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: 98765432, state: 'Z86')
    reading_6 = Fabricate(:reading, register_id: register.id, timestamp: Time.new(2014, 1, 1), energy_milliwatt_hour: 0, reason: Reading::DEVICE_CHANGE_2, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: 77134105, state: 'Z86')

    readings = Buzzn::Localpool::ReadingCalculation.get_readings_at_device_change(register, begin_date, end_date, 2015)
    expect(readings.first).to eq reading_1
    expect(readings.last).to eq reading_2

    readings = Buzzn::Localpool::ReadingCalculation.get_readings_at_device_change(register, nil, end_date, 2015)
    expect(readings.first).to eq reading_1
    expect(readings.last).to eq reading_2

    readings = Buzzn::Localpool::ReadingCalculation.get_readings_at_device_change(register, begin_date, nil, 2015)
    expect(readings.first).to eq reading_1
    expect(readings.last).to eq reading_2

    readings = Buzzn::Localpool::ReadingCalculation.get_readings_at_device_change(register, nil, nil, 2015)
    expect(readings.first).to eq reading_1
    expect(readings.last).to eq reading_2

    readings = Buzzn::Localpool::ReadingCalculation.get_readings_at_device_change(register, nil, nil, 2016)
    expect(readings.first).to eq reading_3
    expect(readings.last).to eq reading_4

    readings = Buzzn::Localpool::ReadingCalculation.get_readings_at_device_change(register, nil, nil, 2014)
    expect(readings.first).to eq reading_5
    expect(readings.last).to eq reading_6

    readings = Buzzn::Localpool::ReadingCalculation.get_readings_at_device_change(register, nil, nil, 2013)
    expect(readings.empty?).to eq true
  end

  it 'adjusts reading value without device change' do
    meter = Fabricate(:easymeter_60051593)
    register = meter.input_register
    first_reading = Fabricate(:reading, register_id: register.id, timestamp: Time.new(2015, 10, 30), energy_milliwatt_hour: 0, reason: Reading::DEVICE_SETUP, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: 77134105, state: 'Z86')
    last_reading_original = Fabricate(:reading, register_id: register.id, timestamp: Time.new(2015, 11, 30), energy_milliwatt_hour: 31000, reason: Reading::REGULAR_READING, quality: Reading::FORECAST_VALUE, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: meter.manufacturer_product_serialnumber, state: 'Z86')
    last_reading = last_reading_original.clone
    last_reading.timestamp = Time.new(2015, 12, 31)
    device_change_readings = []

    #extrapolates
    value = Buzzn::Localpool::ReadingCalculation.adjust_reading_value(first_reading, last_reading, last_reading_original, device_change_readings)
    expect(value).to eq (2 * last_reading_original.energy_milliwatt_hour)

    #intrapolates
    last_reading_original = Fabricate(:reading, register_id: register.id, timestamp: Time.new(2016, 1, 31), energy_milliwatt_hour: 93000, reason: Reading::REGULAR_READING, quality: Reading::FORECAST_VALUE, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: meter.manufacturer_product_serialnumber, state: 'Z86')
    last_reading = last_reading_original.clone
    last_reading.timestamp = Time.new(2015, 12, 31)
    value = Buzzn::Localpool::ReadingCalculation.adjust_reading_value(first_reading, last_reading, last_reading_original, device_change_readings)
    expect(value).to eq (2.0 / 3 * last_reading_original.energy_milliwatt_hour)
  end

  it 'adjusts reading value with device change' do
    meter = Fabricate(:easymeter_60051571)
    register = meter.input_register
    first_reading = Fabricate(:reading, register_id: register.id, timestamp: Time.new(2015, 10, 30), energy_milliwatt_hour: 50000, reason: Reading::DEVICE_SETUP, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: meter.manufacturer_product_serialnumber, state: 'Z86')
    reading_1 = Fabricate(:reading, register_id: register.id, timestamp: Time.new(2015, 11, 15), energy_milliwatt_hour: 66000, reason: Reading::DEVICE_CHANGE_1, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: meter.manufacturer_product_serialnumber, state: 'Z86')
    reading_2 = Fabricate(:reading, register_id: register.id, timestamp: Time.new(2015, 11, 15), energy_milliwatt_hour: 0, reason: Reading::DEVICE_CHANGE_2, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: 12345678, state: 'Z86')
    device_change_readings = [reading_1, reading_2]
    last_reading_original = Fabricate(:reading, register_id: register.id, timestamp: Time.new(2015, 11, 30), energy_milliwatt_hour: 15000, reason: Reading::REGULAR_READING, quality: Reading::FORECAST_VALUE, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: 12345678, state: 'Z86')
    last_reading = last_reading_original.clone
    last_reading.timestamp = Time.new(2015, 12, 31)

    #extrapolates
    value = Buzzn::Localpool::ReadingCalculation.adjust_reading_value(first_reading, last_reading, last_reading_original, device_change_readings)
    expect(value).to eq (46000)

    #intrapolates
    last_reading_original = Fabricate(:reading, register_id: register.id, timestamp: Time.new(2016, 1, 31), energy_milliwatt_hour: 77000, reason: Reading::REGULAR_READING, quality: Reading::FORECAST_VALUE, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: meter.manufacturer_product_serialnumber, state: 'Z86')
    last_reading = last_reading_original.clone
    last_reading.timestamp = Time.new(2015, 12, 31)
    value = Buzzn::Localpool::ReadingCalculation.adjust_reading_value(first_reading, last_reading, last_reading_original, device_change_readings)
    expect(value).to eq (46000)
  end

  it 'gets the energy from a register for a period without device change' do
    meter = Fabricate(:easymeter_60051544)
    register = meter.input_register
    begin_date = Time.new(2015, 1, 1)
    first_reading = Fabricate(:reading, register_id: register.id, timestamp: Time.new(2015, 1, 1), energy_milliwatt_hour: 0, reason: Reading::DEVICE_SETUP, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: 77134105, state: 'Z86')
    Fabricate(:reading, register_id: register.id, timestamp: Time.new(2015, 10, 30), energy_milliwatt_hour: 302000, reason: Reading::REGULAR_READING, quality: Reading::FORECAST_VALUE, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: meter.manufacturer_product_serialnumber, state: 'Z86')
    last_reading_original = Fabricate(:reading, register_id: register.id, timestamp: Time.new(2015, 11, 30), energy_milliwatt_hour: 333000, reason: Reading::REGULAR_READING, quality: Reading::FORECAST_VALUE, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: meter.manufacturer_product_serialnumber, state: 'Z86')

    # with begin_date and without ending_date
    result = Buzzn::Localpool::ReadingCalculation.get_register_energy_for_period(register, begin_date, nil, 2015)
    expect(result.value).to eq 364000
    expect(result.first_reading).to eq first_reading
    expect(result.last_reading_original).to eq last_reading_original
    expect(result.last_reading.timestamp).to eq Time.new(2015, 12, 31).utc

    # with begin_date and with ending_date
    end_date = Time.new(2015, 11, 30)
    result = Buzzn::Localpool::ReadingCalculation.get_register_energy_for_period(register, begin_date, end_date, 2015)
    expect(result.value).to eq 333000
    expect(result.first_reading).to eq first_reading
    expect(result.last_reading_original).to eq last_reading_original
    expect(result.last_reading.timestamp).to eq Time.new(2015, 11, 30).utc

    # without begin_date and with ending_date
    result = Buzzn::Localpool::ReadingCalculation.get_register_energy_for_period(register, nil, end_date, 2015)
    expect(result.value).to eq 333000
    expect(result.first_reading).to eq first_reading
    expect(result.last_reading_original).to eq last_reading_original
    expect(result.last_reading.timestamp).to eq Time.new(2015, 11, 30).utc
  end

  it 'gets the energy from a register for a period with device change in between' do
    meter = Fabricate(:easymeter_60051573)
    register = meter.input_register
    begin_date = Time.new(2015, 1, 1)
    first_reading = Fabricate(:reading, register_id: register.id, timestamp: Time.new(2015, 1, 1), energy_milliwatt_hour: 1500000, reason: Reading::DEVICE_SETUP, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: meter.manufacturer_product_serialnumber, state: 'Z86')
    reading_1 = Fabricate(:reading, register_id: register.id, timestamp: Time.new(2015, 11, 15), energy_milliwatt_hour: 1818000, reason: Reading::DEVICE_CHANGE_1, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: meter.manufacturer_product_serialnumber, state: 'Z86')
    reading_2 = Fabricate(:reading, register_id: register.id, timestamp: Time.new(2015, 11, 15), energy_milliwatt_hour: 0, reason: Reading::DEVICE_CHANGE_2, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: 12345678, state: 'Z86')
    last_reading_original = Fabricate(:reading, register_id: register.id, timestamp: Time.new(2015, 11, 30), energy_milliwatt_hour: 15000, reason: Reading::REGULAR_READING, quality: Reading::FORECAST_VALUE, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: 12345678, state: 'Z86')

    # with begin_date and without ending_date
    result = Buzzn::Localpool::ReadingCalculation.get_register_energy_for_period(register, begin_date, nil, 2015)
    expect(result.value).to eq 364000
    expect(result.first_reading).to eq first_reading
    expect(result.last_reading_original).to eq last_reading_original
    expect(result.last_reading.timestamp).to eq Time.new(2015, 12, 31).utc
    expect(result.device_change_reading_1).to eq reading_1
    expect(result.device_change_reading_2).to eq reading_2
    expect(result.device_change).to eq true

    # with begin_date and with ending_date
    end_date = Time.new(2015, 11, 30)
    result = Buzzn::Localpool::ReadingCalculation.get_register_energy_for_period(register, begin_date, end_date, 2015)
    expect(result.value).to eq 333000
    expect(result.first_reading).to eq first_reading
    expect(result.last_reading_original).to eq last_reading_original
    expect(result.last_reading.timestamp).to eq Time.new(2015, 11, 30).utc
    expect(result.device_change_reading_1).to eq reading_1
    expect(result.device_change_reading_2).to eq reading_2
    expect(result.device_change).to eq true

    # without begin_date and with ending_date
    result = Buzzn::Localpool::ReadingCalculation.get_register_energy_for_period(register, nil, end_date, 2015)
    expect(result.value).to eq 333000
    expect(result.first_reading).to eq first_reading
    expect(result.last_reading_original).to eq last_reading_original
    expect(result.last_reading.timestamp).to eq Time.new(2015, 11, 30).utc
    expect(result.device_change_reading_1).to eq reading_1
    expect(result.device_change_reading_2).to eq reading_2
    expect(result.device_change).to eq true
  end

  it 'gets the energy from a register for a period with device change at the bginning' do
    meter = Fabricate(:easymeter_60051550)
    register = meter.input_register
    begin_date = Time.new(2015, 1, 1)
    reading_1 = Fabricate(:reading, register_id: register.id, timestamp: Time.new(2015, 1, 1), energy_milliwatt_hour: 1500000, reason: Reading::DEVICE_CHANGE_1, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: meter.manufacturer_product_serialnumber, state: 'Z86')
    reading_2 = Fabricate(:reading, register_id: register.id, timestamp: Time.new(2015, 1, 1), energy_milliwatt_hour: 0, reason: Reading::DEVICE_CHANGE_2, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: 12345678, state: 'Z86')
    last_reading_original = Fabricate(:reading, register_id: register.id, timestamp: Time.new(2015, 11, 30), energy_milliwatt_hour: 333000, reason: Reading::REGULAR_READING, quality: Reading::FORECAST_VALUE, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: 12345678, state: 'Z86')

    # with begin_date and without ending_date
    result = Buzzn::Localpool::ReadingCalculation.get_register_energy_for_period(register, begin_date, nil, 2015)
    expect(result.value).to eq 364000
    expect(result.first_reading).to eq reading_2
    expect(result.last_reading_original).to eq last_reading_original
    expect(result.last_reading.timestamp).to eq Time.new(2015, 12, 31).utc
    expect(result.device_change_reading_1).to eq nil
    expect(result.device_change_reading_2).to eq nil
    expect(result.device_change).to eq false

    # with begin_date and with ending_date
    end_date = Time.new(2015, 11, 30)
    result = Buzzn::Localpool::ReadingCalculation.get_register_energy_for_period(register, begin_date, end_date, 2015)
    expect(result.value).to eq 333000
    expect(result.first_reading).to eq reading_2
    expect(result.last_reading_original).to eq last_reading_original
    expect(result.last_reading.timestamp).to eq Time.new(2015, 11, 30).utc
    expect(result.device_change_reading_1).to eq nil
    expect(result.device_change_reading_2).to eq nil
    expect(result.device_change).to eq false

    # without begin_date and with ending_date
    result = Buzzn::Localpool::ReadingCalculation.get_register_energy_for_period(register, nil, end_date, 2015)
    expect(result.value).to eq 333000
    expect(result.first_reading).to eq reading_2
    expect(result.last_reading_original).to eq last_reading_original
    expect(result.last_reading.timestamp).to eq Time.new(2015, 11, 30).utc
    expect(result.device_change_reading_1).to eq nil
    expect(result.device_change_reading_2).to eq nil
    expect(result.device_change).to eq false
  end

  it 'gets the energy from a register for a period with device change at the ending' do
    meter = Fabricate(:input_meter)
    register = meter.input_register
    begin_date = Time.new(2015, 10, 30)
    first_reading = Fabricate(:reading, register_id: register.id, timestamp: Time.new(2015, 10, 30), energy_milliwatt_hour: 0, reason: Reading::DEVICE_SETUP, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: meter.manufacturer_product_serialnumber, state: 'Z86')
    reading_1 = Fabricate(:reading, register_id: register.id, timestamp: Time.new(2015, 12, 31), energy_milliwatt_hour: 62000, reason: Reading::DEVICE_CHANGE_1, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: meter.manufacturer_product_serialnumber, state: 'Z86')
    reading_2 = Fabricate(:reading, register_id: register.id, timestamp: Time.new(2015, 12, 31), energy_milliwatt_hour: 0, reason: Reading::DEVICE_CHANGE_2, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: 12345678, state: 'Z86')
    Fabricate(:reading, register_id: register.id, timestamp: Time.new(2016, 12, 31), energy_milliwatt_hour: 239000, reason: Reading::REGULAR_READING, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: 12345678, state: 'Z86')

    # with begin_date and without ending_date
    result = Buzzn::Localpool::ReadingCalculation.get_register_energy_for_period(register, begin_date, nil, 2015)
    expect(result.value).to eq 62000
    expect(result.first_reading).to eq first_reading
    expect(result.last_reading_original).to eq reading_1
    expect(result.last_reading.timestamp).to eq Time.new(2015, 12, 31).utc
    expect(result.device_change_reading_1).to eq nil
    expect(result.device_change_reading_2).to eq nil
    expect(result.device_change).to eq false

    # with begin_date and with ending_date
    end_date = Time.new(2015, 12, 31)
    result = Buzzn::Localpool::ReadingCalculation.get_register_energy_for_period(register, begin_date, end_date, 2015)
    expect(result.value).to eq 62000
    expect(result.first_reading).to eq first_reading
    expect(result.last_reading_original).to eq reading_1
    expect(result.last_reading.timestamp).to eq Time.new(2015, 12, 31).utc
    expect(result.device_change_reading_1).to eq nil
    expect(result.device_change_reading_2).to eq nil
    expect(result.device_change).to eq false

    # without begin_date and with ending_date
    result = Buzzn::Localpool::ReadingCalculation.get_register_energy_for_period(register, nil, end_date, 2015)
    expect(result.value).to eq 62000
    expect(result.first_reading).to eq first_reading
    expect(result.last_reading_original).to eq reading_1
    expect(result.last_reading.timestamp).to eq Time.new(2015, 12, 31).utc
    expect(result.device_change_reading_1).to eq nil
    expect(result.device_change_reading_2).to eq nil
    expect(result.device_change).to eq false
  end

  it 'gets accounted energy for register with multiple contracts' do
    localpool = Fabricate(:localpool)
    meter = Fabricate(:input_meter)
    register = meter.input_register
    Fabricate(:reading, register_id: register.id, timestamp: Time.new(2015, 2, 1), energy_milliwatt_hour: 5000, reason: Reading::DEVICE_SETUP, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: meter.manufacturer_product_serialnumber, state: 'Z86')
    Fabricate(:reading, register_id: register.id, timestamp: Time.new(2015, 3, 31), energy_milliwatt_hour: 234000, reason: Reading::CONTRACT_CHANGE, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: meter.manufacturer_product_serialnumber, state: 'Z86')
    Fabricate(:reading, register_id: register.id, timestamp: Time.new(2015, 4, 1), energy_milliwatt_hour: 234000, reason: Reading::CONTRACT_CHANGE, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: meter.manufacturer_product_serialnumber, state: 'Z86')
    Fabricate(:reading, register_id: register.id, timestamp: Time.new(2015, 7, 31), energy_milliwatt_hour: 567000, reason: Reading::CONTRACT_CHANGE, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: meter.manufacturer_product_serialnumber, state: 'Z86')
    Fabricate(:reading, register_id: register.id, timestamp: Time.new(2015, 8, 1), energy_milliwatt_hour: 567000, reason: Reading::CONTRACT_CHANGE, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: meter.manufacturer_product_serialnumber, state: 'Z86')
    Fabricate(:reading, register_id: register.id, timestamp: Time.new(2015, 12, 31), energy_milliwatt_hour: 890000, reason: Reading::REGULAR_READING, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: meter.manufacturer_product_serialnumber, state: 'Z86')
    localpool.registers << register
    c1 = Fabricate(:localpool_power_taker_contract, signing_user: Fabricate(:user), contractor: Fabricate(:user), customer: Fabricate(:user), register: register, begin_date: Date.new(2015, 2, 1), end_date: Date.new(2015, 3, 31))
    c2 = Fabricate(:localpool_power_taker_contract, signing_user: Fabricate(:user), contractor: Fabricate(:user), customer: Fabricate(:user), register: register, begin_date: Date.new(2015, 4, 1), end_date: Date.new(2015, 7, 31))
    c3 = Fabricate(:localpool_power_taker_contract, signing_user: Fabricate(:user), contractor: Fabricate(:user), customer: Fabricate(:user), register: register, begin_date: Date.new(2015, 8, 1), end_date: nil)

    # 3 lsn, 0 third party
    result = Buzzn::Localpool::ReadingCalculation.get_register_energy_by_contract(register, nil, nil, 2015)
    expect(result[:consumption_lsn].size).to eq 3
    expect(result[:consumption_third_party].size).to eq 0
    result[:consumption_lsn].each do |accounted_energy|
      expect([229000, 333000, 323000].include?(accounted_energy.value)).to eq true
    end

    # 2 lsn, 1 third party at beginning
    c1.destroy
    c1 = Fabricate(:other_supplier_contract, signing_user: Fabricate(:user), contractor: Fabricate(:user), customer: Fabricate(:user), register: register, begin_date: Date.new(2015, 2, 1), end_date: Date.new(2015, 3, 31))
    result = Buzzn::Localpool::ReadingCalculation.get_register_energy_by_contract(register, nil, nil, 2015)
    expect(result[:consumption_lsn].size).to eq 2
    expect(result[:consumption_third_party].size).to eq 1
    result[:consumption_lsn].each do |accounted_energy|
      expect([333000, 323000].include?(accounted_energy.value)).to eq true
    end
    expect(result[:consumption_third_party].first.value).to eq 229000

    # 2 lsn, 1 third party in the middle
    c1.destroy
    c2.destroy
    c1 = Fabricate(:localpool_power_taker_contract, signing_user: Fabricate(:user), contractor: Fabricate(:user), customer: Fabricate(:user), register: register, begin_date: Date.new(2015, 2, 1), end_date: Date.new(2015, 3, 31))
    c2 = Fabricate(:other_supplier_contract, signing_user: Fabricate(:user), contractor: Fabricate(:user), customer: Fabricate(:user), register: register, begin_date: Date.new(2015, 4, 1), end_date: Date.new(2015, 7, 31))
    result = Buzzn::Localpool::ReadingCalculation.get_register_energy_by_contract(register, nil, nil, 2015)
    expect(result[:consumption_lsn].size).to eq 2
    expect(result[:consumption_third_party].size).to eq 1
    result[:consumption_lsn].each do |accounted_energy|
      expect([229000, 323000].include?(accounted_energy.value)).to eq true
    end
    expect(result[:consumption_third_party].first.value).to eq 333000

    # 2 lsn, 1 third party it the end
    c2.destroy
    c3.destroy
    c2 = Fabricate(:localpool_power_taker_contract, signing_user: Fabricate(:user), contractor: Fabricate(:user), customer: Fabricate(:user), register: register, begin_date: Date.new(2015, 4, 1), end_date: Date.new(2015, 7, 31))
    c3 = Fabricate(:other_supplier_contract, signing_user: Fabricate(:user), contractor: Fabricate(:user), customer: Fabricate(:user), register: register, begin_date: Date.new(2015, 8, 1), end_date: Date.new(2015, 12, 31))
    result = Buzzn::Localpool::ReadingCalculation.get_register_energy_by_contract(register, nil, nil, 2015)
    expect(result[:consumption_lsn].size).to eq 2
    expect(result[:consumption_third_party].size).to eq 1
    result[:consumption_lsn].each do |accounted_energy|
      expect([229000, 333000].include?(accounted_energy.value)).to eq true
    end
    expect(result[:consumption_third_party].first.value).to eq 323000

    # 1 lsn in the middle, 2 third party
    c1.destroy
    c2.destroy
    c3.destroy
    c1 = Fabricate(:other_supplier_contract, signing_user: Fabricate(:user), contractor: Fabricate(:user), customer: Fabricate(:user), register: register, begin_date: Date.new(2015, 2, 1), end_date: Date.new(2015, 3, 31))
    c2 = Fabricate(:localpool_power_taker_contract, signing_user: Fabricate(:user), contractor: Fabricate(:user), customer: Fabricate(:user), register: register, begin_date: Date.new(2015, 4, 1), end_date: Date.new(2015, 7, 31))
    c3 = Fabricate(:other_supplier_contract, signing_user: Fabricate(:user), contractor: Fabricate(:user), customer: Fabricate(:user), register: register, begin_date: Date.new(2015, 8, 1), end_date: Date.new(2015, 12, 31))
    result = Buzzn::Localpool::ReadingCalculation.get_register_energy_by_contract(register, nil, nil, 2015)
    expect(result[:consumption_lsn].size).to eq 1
    expect(result[:consumption_third_party].size).to eq 2
    result[:consumption_third_party].each do |accounted_energy|
      expect([229000, 323000].include?(accounted_energy.value)).to eq true
    end
    expect(result[:consumption_lsn].first.value).to eq 333000
  end

  it 'gets total energy for localpool' do
    localpool = Fabricate(:localpool_sulz_with_registers_and_readings)
    begin_date = Time.new(2016, 8, 4)
    all_energies = Buzzn::Localpool::ReadingCalculation.get_all_energy_in_localpool(localpool, begin_date, nil, 2016)
    result = all_energies.sum_and_group_by_label

    expect(result[:grid_consumption]).to eq 3631626 # this includes third party supplied!
    expect(result[:grid_feeding]).to eq 10116106 # this includes third party supplied!
    expect(result[:consumption_lsn]).to eq 10621000
    expect(result[:consumption_third_party]).to eq 410073
    expect(result[:production_pv]).to eq 7013728
    expect(result[:production_chp]).to eq 10698696
    expect(result[:demarcation_chp]).to eq 245254
    [:consumption, :demarcation_pv, :grid_consumption_corrected, :grid_feeding_corrected, :other].each do |label|
      expect(result[label]).to eq 0
    end
  end

  describe Buzzn::Localpool::TotalAccountedEnergy do
    it 'creates total accounted energy' do
      localpool = Fabricate(:localpool_sulz_with_registers_and_readings)
      result = Buzzn::Localpool::TotalAccountedEnergy.new(localpool.id)
      expect(result.accounted_energies).to eq []
    end

    it 'adds a new accounted energy' do
      localpool = Fabricate(:localpool_sulz_with_registers_and_readings)
      result = Buzzn::Localpool::TotalAccountedEnergy.new(localpool.id)
      accounted_energy = Buzzn::AccountedEnergy.new(20000, localpool.registers.inputs.first.readings[0], localpool.registers.inputs.first.readings[1], localpool.registers.inputs.first.readings[1])
      result.add(accounted_energy)
      expect(result.accounted_energies).to eq [accounted_energy]
    end
  end
end

