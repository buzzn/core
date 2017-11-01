describe Buzzn::Services::ReadingCalculation do

  entity :register_with_regular_readings do
    meter = Fabricate(:input_meter)
    register = meter.input_register
    Fabricate(:single_reading, register: register, date: Date.new(2015, 6, 1), value: 5000000, reason: Reading::Single::DEVICE_SETUP)
    Fabricate(:single_reading, register: register, date: Date.new(2015, 12, 31), value: 239000000, reason: Reading::Single::REGULAR_READING)
    Fabricate(:single_reading, register: register, date: Date.new(2016, 12, 31), value: 1239000000, reason: Reading::Single::REGULAR_READING)
    register
  end

  entity :register_with_irregular_readings do
    meter = Fabricate(:input_meter)
    register = meter.input_register
    Fabricate(:single_reading, register: register, date: Date.new(2015, 6, 1), value: 5000000, reason: Reading::Single::DEVICE_SETUP)
    Fabricate(:single_reading, register: register, date: Date.new(2015, 12, 29), value: 237000000, reason: Reading::Single::REGULAR_READING)
    Fabricate(:single_reading, register: register, date: Date.new(2016, 12, 31), value: 239000000, reason: Reading::Single::REGULAR_READING, quality: Reading::Single::FORECAST_VALUE, source: Reading::Single::BUZZN, status: Reading::Single::Z86)
    Fabricate(:single_reading, register: register, date: Date.new(2016, 6, 27), value: 1239000000, reason: Reading::Single::MIDWAY_READING)
    Fabricate(:single_reading, register: register, date: Date.new(2017, 1, 3), value: 2239000000, reason: Reading::Single::REGULAR_READING)
    register
  end

  entity :register_with_device_change_at_beginning do
    meter = Fabricate(:input_meter)
    register = meter.input_register
    Fabricate(:single_reading, register: register, date: Date.new(2014, 12, 31), value: 11855000000, reason: Reading::Single::REGULAR_READING, quality: Reading::Single::READ_OUT, source: Reading::Single::BUZZN, meter_serialnumber: 77134105, status: Reading::Single::Z86)
    Fabricate(:single_reading, register: register, date: Date.new(2015, 6, 1), value: 13855000000, reason: Reading::Single::DEVICE_CHANGE_1, quality: Reading::Single::READ_OUT, source: Reading::Single::BUZZN, meter_serialnumber: 77134105, status: Reading::Single::Z86)
    Fabricate(:single_reading, register: register, date: Date.new(2015, 6, 1), value: 0, reason: Reading::Single::DEVICE_CHANGE_2)
    Fabricate(:single_reading, register: register, date: Date.new(2015, 12, 31), value: 239000000, reason: Reading::Single::REGULAR_READING, quality: Reading::Single::FORECAST_VALUE, source: Reading::Single::BUZZN, status: Reading::Single::Z86)
    register
  end

  entity :register_with_device_change_in_between do
    meter = Fabricate(:input_meter)
    register = meter.input_register
    Fabricate(:single_reading, register: register, date: Date.new(2015, 6, 1), value: 11855000000, reason: Reading::Single::DEVICE_SETUP, quality: Reading::Single::READ_OUT, source: Reading::Single::BUZZN, meter_serialnumber: 77134105, status: Reading::Single::Z86)
    Fabricate(:single_reading, register: register, date: Date.new(2015, 8, 4), value: 13855000000, reason: Reading::Single::DEVICE_CHANGE_1, quality: Reading::Single::READ_OUT, source: Reading::Single::BUZZN, meter_serialnumber: 77134105, status: Reading::Single::Z86)
    Fabricate(:single_reading, register: register, date: Date.new(2015, 8, 4), value: 0, reason: Reading::Single::DEVICE_CHANGE_2)
    Fabricate(:single_reading, register: register, date: Date.new(2015, 12, 31), value: 239000000, reason: Reading::Single::REGULAR_READING, quality: Reading::Single::FORECAST_VALUE, source: Reading::Single::BUZZN, status: Reading::Single::Z86)
    register
  end

  entity :register_with_device_change_at_ending do
    meter = Fabricate(:input_meter)
    register = meter.input_register
    Fabricate(:single_reading, register: register, date: Date.new(2015, 6, 1), value: 5000000, reason: Reading::Single::DEVICE_SETUP)
    Fabricate(:single_reading, register: register, date: Date.new(2015, 12, 31), value: 1239000000, reason: Reading::Single::DEVICE_CHANGE_1)
    Fabricate(:single_reading, register: register, date: Date.new(2015, 12, 31), value: 0, reason: Reading::Single::DEVICE_CHANGE_2, quality: Reading::Single::READ_OUT, source: Reading::Single::BUZZN, meter_serialnumber: 12345678, status: Reading::Single::Z86)
    Fabricate(:single_reading, register: register, date: Date.new(2016, 12, 31), value: 239000000, reason: Reading::Single::REGULAR_READING, quality: Reading::Single::READ_OUT, source: Reading::Single::BUZZN, meter_serialnumber: 12345678, status: Reading::Single::Z86)
    register
  end

  entity!(:meter) { Fabricate(:easymeter_60051609) }


  [:register_with_regular_readings, :register_with_irregular_readings, :register_with_device_change_at_beginning,
   :register_with_device_change_in_between, :register_with_device_change_at_ending].each do |scenario|

    [Time.new(2015, 6, 1), nil].each do |time|

      xit "gets the right first reading for #{scenario} with time #{time.nil? ? 'nil' : time}" do
        register = send(scenario)
        first_reading = subject.get_first_reading(register, time, 2015)
        if scenario == :register_with_device_change_at_beginning && !time.nil?
          expect(first_reading).to eq Reading::Single.by_register_id(register.id).with_reason(Reading::Single::DEVICE_CHANGE_2).first
        else
          expect(first_reading).to eq Reading::Single.by_register_id(register.id).sort('timestamp': 1).sort('reason': 1).first
        end
      end
    end
  end

  [:register_with_regular_readings, :register_with_irregular_readings, :register_with_device_change_at_beginning,
   :register_with_device_change_in_between, :register_with_device_change_at_ending].each do |scenario|

    [Time.new(2015, 12, 31), nil].each do |time|

      xit "gets the right last reading with time #{time.nil? ? 'nil' : time} for #{scenario}" do
        register = send(scenario)
        if scenario != :register_with_irregular_readings || time.nil?
          last_reading = subject.get_last_reading(register, time, 2015)
          if scenario == :register_with_device_change_at_ending && !time.nil?
            expect(last_reading).to eq Reading::Single.by_register_id(register.id).with_reason(Reading::Single::DEVICE_CHANGE_1).first
          else
            expect(last_reading).to eq Reading::Single.by_register_id(register.id).in_year(2015).sort('timestamp': -1).sort('reason': 1).first
          end
        else
          expect { subject.get_last_reading(register, time, 2015) }.to raise_error ArgumentError
        end
      end
    end
  end

  it 'selects the closest reading' do
    date_1 = Date.new(2014, 1, 1)
    date_2 = Date.new(2015, 3, 1)
    date_3 = Date.new(2016, 1, 1)

    reading_1 = Fabricate(:single_reading, date: Date.new(2015, 1, 1))
    reading_2 = Fabricate(:single_reading, date: Date.new(2015, 10, 1))

    expect(subject.select_closest_reading(date_1, reading_1, reading_2)).to eq reading_1
    expect(subject.select_closest_reading(date_1, reading_2, reading_1)).to eq reading_1
    expect(subject.select_closest_reading(date_2, reading_1, reading_2)).to eq reading_1
    expect(subject.select_closest_reading(date_3, reading_1, reading_2)).to eq reading_2

    # corner case test: if the date is exactly in the middle of the readings, the first one is returned
    reading_3 = Fabricate(:single_reading, date: Date.new(2015, 10, 5))
    date_4 = Date.new(2015, 10, 3)

    expect(subject.select_closest_reading(date_4, reading_3, reading_2)).to eq reading_3
    expect(subject.select_closest_reading(date_4, reading_2, reading_3)).to eq reading_2
  end

  it 'adjusts end date' do
    end_date = Date.new(2015, 6, 1)
    accounting_year = 2015

    expect(subject.adjust_end_date(end_date, accounting_year)).to eq Date.new(2015, 6, 1).end_of_year.beginning_of_day
    expect(subject.adjust_end_date(end_date, accounting_year - 1)).to eq (Date.new(2015, 6, 1).end_of_year.beginning_of_day - 1.year)
  end

  it 'adjusts end date2' do
    end_date = Date.new(2015, 6, 1)
    expect(subject.adjust_end_date2(end_date, 2015)).to eq Date.new(2016, 1, 1)
    expect(subject.adjust_end_date2(end_date, 2011)).to eq Date.new(2012, 1, 1)
    expect { subject.adjust_end_date2(end_date, 2016) }.to raise_error ArgumentError
  end

  entity!(:register) { meter.input_register }
  entity!(:first_reading) do
    Fabricate(:single_reading, register: register, date: Date.new(2015, 10, 30), value: 0, reason: Reading::Single::DEVICE_SETUP)
  end

  entity(:last_reading) do
    Fabricate(:single_reading, register: register, date: Date.new(2015, 12, 31), value: 31000000)
  end

  entity(:last_reading_original) do
    Fabricate(:single_reading, register: register, date: Date.new(2015, 11, 30), value: 31000000)
  end

  xit 'gets readings at device change' do
    begin_date = Date.new(2014, 6, 1)
    end_date = Date.new(2014, 12, 31)
    # some cleanup
    register.readings.where(reason: [Reading::Single::DEVICE_CHANGE_1, Reading::Single::DEVICE_CHANGE_2]).delete_all
    Fabricate(:single_reading, register: register, date: Date.new(2014, 6, 1), value: 11855000000, reason: Reading::Single::DEVICE_SETUP)
    reading_1 = Fabricate(:single_reading, register: register, date: Date.new(2014, 8, 4), value: 13855000000, reason: Reading::Single::DEVICE_CHANGE_1)
    reading_2 = Fabricate(:single_reading, register: register, date: Date.new(2014, 8, 4), value: 0, reason: Reading::Single::DEVICE_CHANGE_2)
    Fabricate(:single_reading, register: register, date: Date.new(2014, 12, 31), value: 239000000)
    reading_3 = Fabricate(:single_reading, register: register, date: Date.new(2015, 12, 31), value: 439000000, reason: Reading::Single::DEVICE_CHANGE_1)
    reading_4 = Fabricate(:single_reading, register: register, date: Date.new(2015, 12, 31), value: 0, reason: Reading::Single::DEVICE_CHANGE_2)
    reading_5 = Fabricate(:single_reading, register: register, date: Date.new(2013, 1, 1), value: 439000000, reason: Reading::Single::DEVICE_CHANGE_1)
    reading_6 = Fabricate(:single_reading, register: register, date: Date.new(2013, 1, 1), value: 0, reason: Reading::Single::DEVICE_CHANGE_2)

    readings = subject.get_readings_at_device_change(register, begin_date, end_date, 2014)
    expect(readings).to match_array [reading_1, reading_2]

    readings = subject.get_readings_at_device_change(register, nil, end_date, 2014)
    expect(readings).to match_array [reading_1, reading_2]

    readings = subject.get_readings_at_device_change(register, begin_date, nil, 2014)
    expect(readings).to match_array [reading_1, reading_2]

    readings = subject.get_readings_at_device_change(register, nil, nil, 2014)
    expect(readings).to match_array [reading_1, reading_2]

    readings = subject.get_readings_at_device_change(register, nil, nil, 2015)
    expect(readings).to match_array [reading_3, reading_4]

    readings = subject.get_readings_at_device_change(register, nil, nil, 2013)
    expect(readings).to match_array [reading_5, reading_6]

    readings = subject.get_readings_at_device_change(register, nil, nil, 2012)
    expect(readings.empty?).to eq true
  end

  context 'adjusts reading value' do

    context 'without device change' do
      before do
        first_reading.update(date: Date.new(2015, 10, 30), value: 0)
        last_reading_original.update(date: Date.new(2015, 11, 30), value: 31000000)
        last_reading.update(date: Date.new(2015, 12, 31), value: 31000000)
      end

      it 'extrapolates' do
        device_change_readings = []
        value = subject.adjust_reading_value(first_reading, last_reading, last_reading_original, device_change_readings)
        expect(value).to eq watt_hour(last_reading_original.value * 2)
      end

      it 'intrapolates' do
        device_change_readings = []
        last_reading_original.update(date: Date.new(2016, 1, 31), value: 93000000)
        last_reading.update(date: Date.new(2015, 12, 31), value: 93000000)
        value = subject.adjust_reading_value(first_reading, last_reading, last_reading_original, device_change_readings)
        expect(value).to eq watt_hour(last_reading_original.value * 2.0 / 3.0)
      end
    end

    context 'with device change' do
      entity(:reading_1) do
        Fabricate(:single_reading, register: register, date: Date.new(2015, 11, 15), value: 66000000, reason: Reading::Single::DEVICE_CHANGE_1)
      end

      entity(:reading_2) do
        Fabricate(:single_reading, register: register, date: Date.new(2015, 11, 15), value: 0, reason: Reading::Single::DEVICE_CHANGE_2)
      end

      before do
        # some cleanup
        register.readings.where(reason: [Reading::Single::DEVICE_CHANGE_1, Reading::Single::DEVICE_CHANGE_2]).delete_all
        first_reading.update(date: Date.new(2015, 10, 30), value: 50000000)
      end

      xit 'extrapolates' do
        device_change_readings = [reading_1, reading_2]
        reading_2.update(date: Date.new(2015, 11, 15))
        last_reading_original.update(date: Date.new(2015, 11, 30), value: 15000000)
        last_reading.update(date: Date.new(2015, 12, 31), value: 15000000)

        value = subject.adjust_reading_value(first_reading, last_reading, last_reading_original, device_change_readings)
        expect(value).to eq watt_hour(46000000)

        reading_2.update(date: last_reading_original.date)
        value = subject.adjust_reading_value(first_reading, last_reading, last_reading_original, device_change_readings)
        # FIXME double check value with Stefon + Phlipp
        expect(value).to eq watt_hour(33066666.666666668)
      end

      xit 'intrapolates' do
        device_change_readings = [reading_1, reading_2]
        reading_2.update(date: Date.new(2015, 11, 15))
        last_reading_original.update(date: Date.new(2016, 1, 31), value: 77000000)
        last_reading.update(date: Date.new(2015, 12, 31), value: 77000000)

        value = subject.adjust_reading_value(first_reading, last_reading, last_reading_original, device_change_readings)
        expect(value).to eq watt_hour(46000000)

        reading_2.update(date: last_reading_original.date)
        value = subject.adjust_reading_value(first_reading, last_reading, last_reading_original, device_change_readings)

        # FIXME negative enegy values !?
        expect(value).to eq watt_hour(-6441558.441558441)
      end
    end
  end

  context 'gets the energy from a register for a period' do

    let(:begin_date) { Date.new(2015, 1, 1) }
    let(:end_date) { Date.new(2015, 11, 30) }

    context 'without device change' do

      before do
        # some cleanup
        register.readings.where(reason: [Reading::Single::DEVICE_CHANGE_1, Reading::Single::DEVICE_CHANGE_2]).delete_all
        first_reading.update(date: Date.new(2015, 1, 1), value: 0)
        last_reading.update(date: Date.new(2015, 10, 30), value: 302000000)
        last_reading_original.update(date: Date.new(2015, 11, 30), value: 333000000)
      end

      xit 'with begin_date and without ending_date' do
        result = subject.get_register_energy_for_period(register, begin_date, nil, 2015)
        expect(result.value).to eq watt_hour(364000000)
        expect(result.first_reading).to eq first_reading
        expect(result.last_reading_original).to eq last_reading_original
        expect(result.last_reading.date).to eq Date.new(2015, 12, 31)
      end

      xit 'with begin_date and with ending_date' do
        result = subject.get_register_energy_for_period(register, begin_date, end_date, 2015)
        expect(result.value).to eq watt_hour(333000000)
        expect(result.first_reading).to eq first_reading
        expect(result.last_reading_original).to eq last_reading_original
        expect(result.last_reading.date).to eq Date.new(2015, 11, 30)
      end

      xit 'without begin_date and with ending_date' do
        result = subject.get_register_energy_for_period(register, nil, end_date, 2015)
        expect(result.value).to eq watt_hour(333000000)
        expect(result.first_reading).to eq first_reading
        expect(result.last_reading_original).to eq last_reading_original
        expect(result.last_reading.date).to eq Date.new(2015, 11, 30)
      end
    end

    context 'with device change in between' do

      let(:reading_1) do
        register.readings.where(reason: Reading::Single::DEVICE_CHANGE_1).first
      end

      let(:reading_2) do
        register.readings.where(reason: Reading::Single::DEVICE_CHANGE_2).first
      end

      before(:all) do
        # some cleanup
        register.readings.where(reason: [Reading::Single::DEVICE_CHANGE_1, Reading::Single::DEVICE_CHANGE_2]).delete_all

        first_reading.update(date: Date.new(2015, 1, 1), value: 1500000000)
        last_reading_original.update(date: Date.new(2015, 11, 30), value: 15000000)
        Fabricate(:single_reading, register: register, date: Date.new(2015, 11, 15), value: 1818000000, reason: Reading::Single::DEVICE_CHANGE_1)
        Fabricate(:single_reading, register: register, date: Date.new(2015, 11, 15), value: 0, reason: Reading::Single::DEVICE_CHANGE_2)
      end

      xit 'with begin_date and without ending_date' do
        result = subject.get_register_energy_for_period(register, begin_date, nil, 2015)
        expect(result.value).to eq watt_hour(364000000)
        expect(result.first_reading).to eq first_reading
        expect(result.last_reading_original).to eq last_reading_original
        expect(result.last_reading.date).to eq Date.new(2015, 12, 31)
        expect(result.device_change_reading_1).to eq reading_1
        expect(result.device_change_reading_2).to eq reading_2
        expect(result.device_change).to eq true
      end

      xit 'with begin_date and with ending_date' do
        result = subject.get_register_energy_for_period(register, begin_date, end_date, 2015)
        expect(result.value).to eq watt_hour(333000000)
        expect(result.first_reading).to eq first_reading
        expect(result.last_reading_original).to eq last_reading_original
        expect(result.last_reading.date).to eq Date.new(2015, 11, 30)
        expect(result.device_change_reading_1).to eq reading_1
        expect(result.device_change_reading_2).to eq reading_2
        expect(result.device_change).to eq true
      end

      xit 'without begin_date and with ending_date' do
        result = subject.get_register_energy_for_period(register, nil, end_date, 2015)
        expect(result.value).to eq watt_hour(333000000)
        expect(result.first_reading).to eq first_reading
        expect(result.last_reading_original).to eq last_reading_original
        expect(result.last_reading.date).to eq Date.new(2015, 11, 30)
        expect(result.device_change_reading_1).to eq reading_1
        expect(result.device_change_reading_2).to eq reading_2
        expect(result.device_change).to eq true
      end
    end

    context 'with device change at the beginning' do

      let(:reading_1) do
        register.readings.where(reason: Reading::Single::DEVICE_CHANGE_1).first
      end

      let(:reading_2) do
        register.readings.where(reason: Reading::Single::DEVICE_CHANGE_2).first
      end

      before(:all) do
        # some cleanup
        register.readings.where(reason: [Reading::Single::DEVICE_CHANGE_1, Reading::Single::DEVICE_CHANGE_2]).delete_all

        first_reading.update(date: Date.new(2015, 1, 1), value: 00000000)
        last_reading_original.update(date: Date.new(2015, 11, 30), value: 333000000)
        Fabricate(:single_reading, register: register, date: Date.new(2015, 1, 1), value: 1500000000, reason: Reading::Single::DEVICE_CHANGE_1)
        Fabricate(:single_reading, register: register, date: Date.new(2015, 1, 1), value: 0, reason: Reading::Single::DEVICE_CHANGE_2)
      end

      xit 'with begin_date and without ending_date' do
        result = subject.get_register_energy_for_period(register, begin_date, nil, 2015)
        #expect(result.value).to eq watt_hour(364000000)
        #expect(result.first_reading).to eq reading_2
        expect(result.last_reading_original).to eq last_reading_original
        expect(result.last_reading.date).to eq Date.new(2015, 12, 31)
        #expect(result.device_change_reading_1).to eq nil
        #expect(result.device_change_reading_2).to eq nil
        #expect(result.device_change).to eq false
      end

      xit 'with begin_date and with ending_date' do
        result = subject.get_register_energy_for_period(register, begin_date, end_date, 2015)
        #expect(result.value).to eq watt_hour(333000000)
        #expect(result.first_reading).to eq reading_2
        expect(result.last_reading_original).to eq last_reading_original
        expect(result.last_reading.date).to eq Date.new(2015, 11, 30)
        #expect(result.device_change_reading_1).to eq nil
        #expect(result.device_change_reading_2).to eq nil
        #expect(result.device_change).to eq false
      end

      xit 'without begin_date and with ending_date' do
        result = subject.get_register_energy_for_period(register, nil, end_date, 2015)
        expect(result.value).to eq watt_hour(333000000)
        #expect(result.first_reading).to eq reading_2
        expect(result.last_reading_original).to eq last_reading_original
        expect(result.last_reading.date).to eq Date.new(2015, 11, 30)
        expect(result.device_change_reading_1).to eq nil
        expect(result.device_change_reading_2).to eq nil
        expect(result.device_change).to eq false
      end
    end
    #end
    context 'with device change at the ending' do

      let(:reading_1) do
        register.readings.where(reason: Reading::Single::DEVICE_CHANGE_1).first
      end

      let(:reading_2) do
        register.readings.where(reason: Reading::Single::DEVICE_CHANGE_2).first
      end

      let(:begin_date) { Date.new(2015, 10, 30) }
      let(:end_date) { Date.new(2015, 12, 31) }

      before(:all) do
        # some cleanup
        register.readings.where(reason: [Reading::Single::DEVICE_CHANGE_1, Reading::Single::DEVICE_CHANGE_2]).delete_all

        first_reading.update(date: Date.new(2015, 10, 30), value: 0)
        Fabricate(:single_reading, register: register, date: Date.new(2015, 12, 31), value: 62000000, reason: Reading::Single::DEVICE_CHANGE_1)
        Fabricate(:single_reading, register: register, date: Date.new(2015, 12, 31), value: 0, reason: Reading::Single::DEVICE_CHANGE_2)
        Fabricate(:single_reading, register: register, date: Date.new(2016, 12, 31), value: 239000000)
      end

      xit '# with begin_date and without ending_date' do
        result = subject.get_register_energy_for_period(register, begin_date, nil, 2015)
        #expect(result.value).to eq watt_hour(62000000)
        #expect(result.first_reading).to eq first_reading
        expect(result.last_reading_original).to eq reading_1
        expect(result.last_reading.date).to eq Date.new(2015, 12, 31)
        expect(result.device_change_reading_1).to eq nil
        expect(result.device_change_reading_2).to eq nil
        expect(result.device_change).to eq false
      end

      xit 'with begin_date and with ending_date' do
        result = subject.get_register_energy_for_period(register, begin_date, end_date, 2015)
        #expect(result.value).to eq watt_hour(62000000)
        expect(result.first_reading).to eq first_reading
        expect(result.last_reading_original).to eq reading_1
        expect(result.last_reading.date).to eq Date.new(2015, 12, 31)
        expect(result.device_change_reading_1).to eq nil
        expect(result.device_change_reading_2).to eq nil
        expect(result.device_change).to eq false
      end

      xit 'without begin_date and with ending_date' do
        result = subject.get_register_energy_for_period(register, nil, end_date, 2015)
        #expect(result.value).to eq watt_hour(62000000)
        #expect(result.first_reading).to eq first_reading
        expect(result.last_reading_original).to eq reading_1
        expect(result.last_reading.date).to eq Date.new(2015, 12, 31)
        expect(result.device_change_reading_1).to eq nil
        expect(result.device_change_reading_2).to eq nil
        expect(result.device_change).to eq false
      end
    end
  end

  xit 'gets accounted energy for register with multiple contracts' do
    localpool = Fabricate(:localpool)
    register = meter.input_register
   # Reading::Single.all.by_register_id(register.id).each { |reading| reading.delete }
    Fabricate(:single_reading, register: register, date: Date.new(2015, 2, 1), value: 5000000, reason: Reading::Single::DEVICE_SETUP)
    Fabricate(:single_reading, register: register, date: Date.new(2015, 3, 31), value: 234000000, reason: Reading::Single::CONTRACT_CHANGE)
    Fabricate(:single_reading, register: register, date: Date.new(2015, 4, 1), value: 234000000, reason: Reading::Single::CONTRACT_CHANGE)
    Fabricate(:single_reading, register: register, date: Date.new(2015, 7, 31), value: 567000000, reason: Reading::Single::CONTRACT_CHANGE)
    Fabricate(:single_reading, register: register, date: Date.new(2015, 8, 1), value: 567000000, reason: Reading::Single::CONTRACT_CHANGE)
    Fabricate(:single_reading, register: register, date: Date.new(2015, 12, 31), value: 890000000, reason: Reading::Single::REGULAR_READING)
    localpool.registers << register
    someone = Fabricate(:person)
    c1 = Fabricate(:localpool_power_taker_contract, signing_user: FFaker::Name.name, contractor: someone, customer: someone, register: register, begin_date: Date.new(2015, 2, 1), end_date: Date.new(2015, 3, 31))
    c2 = Fabricate(:localpool_power_taker_contract, signing_user: FFaker::Name.name, contractor: someone, customer: someone, register: register, begin_date: Date.new(2015, 4, 1), end_date: Date.new(2015, 7, 31))
    c3 = Fabricate(:localpool_power_taker_contract, signing_user: FFaker::Name.name, contractor: someone, customer: someone, register: register, begin_date: Date.new(2015, 8, 1), end_date: nil)

    # 3 lsn, 0 third party
    result = subject.get_register_energy_by_contract(register, nil, nil, 2015)
    expect(result[Buzzn::AccountedEnergy::CONSUMPTION_LSN_FULL_EEG].size).to eq 3
    expect(result[Buzzn::AccountedEnergy::CONSUMPTION_THIRD_PARTY].size).to eq 0
    result[Buzzn::AccountedEnergy::CONSUMPTION_LSN_FULL_EEG].each do |accounted_energy|
      expect([229000000, 333000000, 323000000].include?(accounted_energy.value)).to eq true
    end

    # 2 lsn, 1 third party at beginning
    c1.destroy
    c1 = Fabricate(:other_supplier_contract, signing_user: FFaker::Name.name, contractor: someone, customer: someone, register: register, begin_date: Date.new(2015, 2, 1), end_date: Date.new(2015, 3, 31))
    result = subject.get_register_energy_by_contract(register, nil, nil, 2015)
    expect(result[Buzzn::AccountedEnergy::CONSUMPTION_LSN_FULL_EEG].size).to eq 2
    expect(result[Buzzn::AccountedEnergy::CONSUMPTION_THIRD_PARTY].size).to eq 1
    result[Buzzn::AccountedEnergy::CONSUMPTION_LSN_FULL_EEG].each do |accounted_energy|
      expect([333000000, 323000000].include?(accounted_energy.value)).to eq true
    end
    expect(result[Buzzn::AccountedEnergy::CONSUMPTION_THIRD_PARTY].first.value).to eq 229000000

    # 2 lsn, 1 third party in the middle
    c1.destroy
    c2.destroy
    c1 = Fabricate(:localpool_power_taker_contract, signing_user: FFaker::Name.name, contractor: someone, customer: someone, register: register, begin_date: Date.new(2015, 2, 1), end_date: Date.new(2015, 3, 31))
    c2 = Fabricate(:other_supplier_contract, signing_user: FFaker::Name.name, contractor: someone, customer: someone, register: register, begin_date: Date.new(2015, 4, 1), end_date: Date.new(2015, 7, 31))
    result = subject.get_register_energy_by_contract(register, nil, nil, 2015)
    expect(result[Buzzn::AccountedEnergy::CONSUMPTION_LSN_FULL_EEG].size).to eq 2
    expect(result[Buzzn::AccountedEnergy::CONSUMPTION_THIRD_PARTY].size).to eq 1
    result[Buzzn::AccountedEnergy::CONSUMPTION_LSN_FULL_EEG].each do |accounted_energy|
      expect([229000000, 323000000].include?(accounted_energy.value)).to eq true
    end
    expect(result[Buzzn::AccountedEnergy::CONSUMPTION_THIRD_PARTY].first.value).to eq 333000000

    # 2 lsn, 1 third party it the end
    c2.destroy
    c3.destroy
    c2 = Fabricate(:localpool_power_taker_contract, signing_user: FFaker::Name.name, contractor: someone, customer: someone, register: register, begin_date: Date.new(2015, 4, 1), end_date: Date.new(2015, 7, 31))
    c3 = Fabricate(:other_supplier_contract, signing_user: FFaker::Name.name, contractor: someone, customer: someone, register: register, begin_date: Date.new(2015, 8, 1), end_date: Date.new(2015, 12, 31))
    result = subject.get_register_energy_by_contract(register, nil, nil, 2015)
    expect(result[Buzzn::AccountedEnergy::CONSUMPTION_LSN_FULL_EEG].size).to eq 2
    expect(result[Buzzn::AccountedEnergy::CONSUMPTION_THIRD_PARTY].size).to eq 1
    result[Buzzn::AccountedEnergy::CONSUMPTION_LSN_FULL_EEG].each do |accounted_energy|
      expect([229000000, 333000000].include?(accounted_energy.value)).to eq true
    end
    expect(result[Buzzn::AccountedEnergy::CONSUMPTION_THIRD_PARTY].first.value).to eq 323000000

    # 1 lsn in the middle, 2 third party
    c1.destroy
    c2.destroy
    c3.destroy
    c1 = Fabricate(:other_supplier_contract, signing_user: FFaker::Name.name, contractor: someone, customer: someone, register: register, begin_date: Date.new(2015, 2, 1), end_date: Date.new(2015, 3, 31))
    c2 = Fabricate(:localpool_power_taker_contract, signing_user: FFaker::Name.name, contractor: someone, customer: someone, register: register, begin_date: Date.new(2015, 4, 1), end_date: Date.new(2015, 7, 31))
    c3 = Fabricate(:other_supplier_contract, signing_user: FFaker::Name.name, contractor: someone, customer: someone, register: register, begin_date: Date.new(2015, 8, 1), end_date: Date.new(2015, 12, 31))
    result = subject.get_register_energy_by_contract(register, nil, nil, 2015)
    expect(result[Buzzn::AccountedEnergy::CONSUMPTION_LSN_FULL_EEG].size).to eq 1
    expect(result[Buzzn::AccountedEnergy::CONSUMPTION_THIRD_PARTY].size).to eq 2
    result[Buzzn::AccountedEnergy::CONSUMPTION_THIRD_PARTY].each do |accounted_energy|
      expect([229000000, 323000000].include?(accounted_energy.value)).to eq true
    end
    expect(result[Buzzn::AccountedEnergy::CONSUMPTION_LSN_FULL_EEG].first.value).to eq 333000000
  end

  it 'gets total energy for localpool' do
    skip "Broken after Organization --> market partner refactoring."
    localpool = Fabricate(:localpool_sulz_with_registers_and_readings)
    begin_date = Date.new(2016, 8, 4)
    result = subject.get_all_energy_in_localpool(localpool, begin_date, nil, 2016)

    expect(result.get(Buzzn::AccountedEnergy::GRID_CONSUMPTION).value).to eq watt_hour(3631626666.6666665) # this includes third party supplied!
    expect(result.get(Buzzn::AccountedEnergy::GRID_FEEDING).value).to eq watt_hour(10116106666.666666) # this includes third party supplied!
    # FIXME
    #expect(result.sum(Buzzn::AccountedEnergy::CONSUMPTION_LSN_FULL_EEG)).to eq watt_hour(10191000000)
    #expect(result.sum(Buzzn::AccountedEnergy::CONSUMPTION_LSN_REDUCED_EEG)).to eq watt_hour(430000000)
    expect(result.sum(Buzzn::AccountedEnergy::CONSUMPTION_THIRD_PARTY)).to eq watt_hour(410073913.043478)
    expect(result.sum(Buzzn::AccountedEnergy::PRODUCTION_PV)).to eq watt_hour(7013728000)
    expect(result.sum(Buzzn::AccountedEnergy::PRODUCTION_CHP)).to eq watt_hour(10698696666.666666)
    expect(result.get(Buzzn::AccountedEnergy::DEMARCATION_CHP).value).to eq watt_hour(4905080000)
    expect(result.get(Buzzn::AccountedEnergy::GRID_CONSUMPTION_CORRECTED).value).to eq watt_hour(3221552753.6231885)
    expect(result.get(Buzzn::AccountedEnergy::GRID_FEEDING_CORRECTED).value).to eq watt_hour(10116106666.666666)
    expect(result[Buzzn::AccountedEnergy::DEMARCATION_PV]).to be_nil
    expect(result[Buzzn::AccountedEnergy::OTHER]).to be_nil
  end

  xit 'creates the corrected reading' do
    meter = Fabricate(:meter, registers: [Fabricate.build(:input_register, label: Register::Base.labels[:grid_consumption_corrected]),
                                          Fabricate.build(:output_register, label: Register::Base.labels[:grid_feeding_corrected])])

    [Buzzn::AccountedEnergy::GRID_CONSUMPTION_CORRECTED,
     Buzzn::AccountedEnergy::GRID_FEEDING_CORRECTED].each do |label|
      register_id = label == Buzzn::AccountedEnergy::GRID_FEEDING_CORRECTED ? meter.output_register.id : meter.input_register.id
      size = Reading::Single.all.by_register_id(register_id).size
      result = subject.create_corrected_reading(register_id, label, 500000000, Time.new(2015, 12, 31).utc)
      expect(Reading::Single.all.by_register_id(register_id).size).to eq size + 1
      expect(result.value).to eq 500000000
      expect(result.first_reading).to eq nil
      expect(result.last_reading).to eq Reading::Single.all.by_register_id(register_id).first
      expect(result.last_reading_original).to eq Reading::Single.all.by_register_id(register_id).first
      expect(result.label).to eq label
      Reading::Single.all.by_register_id(register_id).each { |reading| reading.delete }
    end

    Fabricate(:single_reading, register_id: meter.input_register.id, date: Date.new(2015, 2, 1), value: 1000000, reason: Reading::Single::DEVICE_SETUP, quality: Reading::Single::ENERGY_QUANTITY_SUMMARIZED, source: Reading::Single::BUZZN, status: Reading::Single::Z86)
    Fabricate(:single_reading, register_id: meter.output_register.id, date: Date.new(2015, 2, 1), value: 1000000, reason: Reading::Single::DEVICE_SETUP, quality: Reading::Single::ENERGY_QUANTITY_SUMMARIZED, source: Reading::Single::BUZZN, status: Reading::Single::Z86)

    [Buzzn::AccountedEnergy::GRID_CONSUMPTION_CORRECTED,
     Buzzn::AccountedEnergy::GRID_FEEDING_CORRECTED].each do |label|
      register_id = label == Buzzn::AccountedEnergy::GRID_FEEDING_CORRECTED ? meter.output_register.id : meter.input_register.id
      size = Reading::Single.all.by_register_id(register_id).size
      result = subject.create_corrected_reading(register_id, label, 500000000, Time.new(2015, 12, 31).utc)
      expect(Reading::Single.all.by_register_id(register_id).size).to eq size + 1
      expect(result.value).to eq 500000000
      expect(result.first_reading).to eq Reading::Single.all.by_register_id(register_id).sort('timestamp': 1).first
      expect(result.last_reading).to eq Reading::Single.all.by_register_id(register_id).sort('timestamp': -1).first
      expect(result.last_reading_original).to eq Reading::Single.all.by_register_id(register_id).sort('timestamp': -1).first
      expect(result.label).to eq label
    end
  end

  context 'calculates the corrected grid values' do
    let(:ten) { watt_hour(10000000000) }
    let(:three) { watt_hour(3000000000) }
    let(:seven) { watt_hour(7000000000) }
    let(:twelfe) { watt_hour(12000000000) }
    let(:thirteen) { watt_hour(13000000000) }
    entity(:sample_reading) { Fabricate(:single_reading) }
    entity(:grid_meter) do
      Fabricate(:meter, registers: [Fabricate.build(:input_register, label: Register::Base.labels[:grid_consumption_corrected]),
                                    Fabricate.build(:output_register, label: Register::Base.labels[:grid_feeding_corrected])])
    end
    let(:accounted_energy_grid_feeding) do
      accounted_energy_grid_feeding = Buzzn::AccountedEnergy.new(ten, sample_reading, sample_reading, sample_reading)
      accounted_energy_grid_feeding.label = Buzzn::AccountedEnergy::GRID_FEEDING
      accounted_energy_grid_feeding
    end

    let(:accounted_energy_grid_consumption) do
      accounted_energy_grid_consumption = Buzzn::AccountedEnergy.new(ten, sample_reading, sample_reading, sample_reading)
      accounted_energy_grid_consumption.label = Buzzn::AccountedEnergy::GRID_CONSUMPTION
      accounted_energy_grid_consumption
    end

    it 'with more lsn than third party supplied' do
      # cleanup
      grid_meter.input_register.readings.where(quality: Reading::Single::ENERGY_QUANTITY_SUMMARIZED).delete_all
      grid_meter.output_register.readings.where(quality: Reading::Single::ENERGY_QUANTITY_SUMMARIZED).delete_all

      accounted_energy_consumption_third_party = Buzzn::AccountedEnergy.new(three, sample_reading, sample_reading, sample_reading)
      accounted_energy_consumption_third_party.label = Buzzn::AccountedEnergy::CONSUMPTION_THIRD_PARTY
      total_accounted_energy = Buzzn::Localpool::TotalAccountedEnergy.new("some-localpool-id")
      total_accounted_energy.add(accounted_energy_grid_feeding)
      total_accounted_energy.add(accounted_energy_grid_consumption)
      total_accounted_energy.add(accounted_energy_consumption_third_party)

      size = Reading::Single.all.size
      consumption_corrected, feeding_corrected = subject.calculate_corrected_grid_values(total_accounted_energy, grid_meter.input_register, grid_meter.output_register)
      expect(Reading::Single.all.size).to eq size + 2
      expect(consumption_corrected.value).to eq seven
      expect(consumption_corrected.last_reading.corrected_value).to eq seven
      expect(feeding_corrected.value).to eq ten
      expect(feeding_corrected.last_reading.corrected_value).to eq ten
    end

    it 'with more third party supplied than lsn' do
      # cleanup
      grid_meter.input_register.readings.where(quality: Reading::Single::ENERGY_QUANTITY_SUMMARIZED).delete_all
      grid_meter.output_register.readings.where(quality: Reading::Single::ENERGY_QUANTITY_SUMMARIZED).delete_all

      accounted_energy_consumption_third_party_2 = Buzzn::AccountedEnergy.new(twelfe, sample_reading, sample_reading, sample_reading)
      accounted_energy_consumption_third_party_2.label = Buzzn::AccountedEnergy::CONSUMPTION_THIRD_PARTY
      total_accounted_energy = Buzzn::Localpool::TotalAccountedEnergy.new("some-localpool-id")
      total_accounted_energy.add(accounted_energy_grid_feeding)
      total_accounted_energy.add(accounted_energy_grid_consumption)
      total_accounted_energy.add(accounted_energy_consumption_third_party_2)


      size = Reading::Single.all.size
      consumption_corrected, feeding_corrected = subject.calculate_corrected_grid_values(total_accounted_energy, grid_meter.input_register, grid_meter.output_register)
      expect(Reading::Single.all.size).to eq size + 2
      expect(consumption_corrected.value).to eq Buzzn::Utils::Energy::ZERO
      expect(consumption_corrected.last_reading.corrected_value).to eq  Buzzn::Utils::Energy::ZERO
      expect(feeding_corrected.value).to eq twelfe
      expect(feeding_corrected.last_reading.corrected_value).to eq twelfe
    end
  end

  xit 'gets missing reading' do |spec|
    meter = Fabricate(:meter, registers: [Fabricate.build(:input_register, label: Register::Base.labels[:grid_consumption_corrected]),
                                          Fabricate.build(:output_register, label: Register::Base.labels[:grid_feeding_corrected])])
    expect{ subject.get_missing_reading(meter.input_register, Date.new(2016, 1, 1)) }.to raise_error ArgumentError

    VCR.use_cassette("lib/buzzn/discovergy/gets_single_reading") do
      meter = Fabricate(:input_meter, product_serialnumber: 60009485)
      broker = Fabricate(:discovergy_broker, mode: 'in',
                         resource: meter, external_id: "EASYMETER_#{meter.product_serialnumber}")
      time = Time.find_zone('Berlin').local(2016, 7, 1, 0, 0, 0)

      result = subject.get_missing_reading(meter.registers.first, time)
      expect(result.is_a?(Reading::Single)).to eq true
      expect(result.timestamp).to eq time
    end
  end
end
