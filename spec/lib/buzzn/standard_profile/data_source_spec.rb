require 'buzzn/discovergy/data_source'

describe Buzzn::StandardProfile::DataSource do
  let(:data_source) { Buzzn::StandardProfile::DataSource.new }


  describe 'value' do
    it 'power' do |spec|
      meter = Fabricate(:meter_with_input_register)
      register = meter.registers.inputs.first
      energy_milliwatt_hour = 0
      berlin_time = Time.find_zone('Berlin')
      timestamp = berlin_time.local(2015,1,1)

      365.times do |i|
        reading = Fabricate(:reading,
                            source: 'slp',
                            timestamp: timestamp,
                            energy_milliwatt_hour: energy_milliwatt_hour,
                            power_milliwatt: 930*1000 )
        energy_milliwatt_hour += 19000*1000
        timestamp += 1.day
      end

      single_value = data_source.single_value(register, berlin_time.local(2015,4,6))

      expect(single_value.mode).to eq register.mode.to_sym
      expect(single_value.resource_id).to eq register.id
      expect(single_value.value).to eq 930*1000
      expect(single_value.timestamp).to eq berlin_time.local(2015,4,6)
    end
  end


  describe 'range' do

    it 'year_to_months' do |spec|
      meter = Fabricate(:meter_with_input_register)
      register = meter.registers.inputs.first
      energy_milliwatt_hour = 0
      berlin_time = Time.find_zone('Berlin')
      timestamp = berlin_time.local(2015,1,1)
      year_interval = Buzzn::Interval.year(timestamp)
      365.times do |i|
        reading = Fabricate(:reading,
                            source: 'slp',
                            timestamp: timestamp,
                            energy_milliwatt_hour: energy_milliwatt_hour,
                            power_milliwatt: 930*1000 )
        energy_milliwatt_hour += 19000*1000
        timestamp += 1.day
      end

      chart = data_source.chart(register, year_interval)

      expect(chart.in.count).to eq 12
      chart.in.each do |point|
        # the timestamp of a data_result is not working with .utc_offset, so i guess the utc_offset with 2 hours.
        timestamp = point.timestamp + 2.hours
        days_in_month = Time.days_in_month(timestamp.month, timestamp.year)
        expect(point.value).to eq 19000*1000*(days_in_month-1)
      end
    end


    it 'month_to_days' do |spec|
      meter = Fabricate(:meter_with_input_register)
      register = meter.registers.inputs.first
      energy_milliwatt_hour = 0
      berlin_time = Time.find_zone('Berlin')
      timestamp = berlin_time.local(2015,1,1)
      month_interval = Buzzn::Interval.month(timestamp)
      days_in_month = Time.days_in_month(timestamp.month, timestamp.year)
      (24*days_in_month).times do |i|
        reading = Fabricate(:reading,
                            source: 'slp',
                            timestamp: timestamp,
                            energy_milliwatt_hour: energy_milliwatt_hour,
                            power_milliwatt: 930*1000 )
        energy_milliwatt_hour += 1300*1000
        timestamp += 1.hour
      end

      chart = data_source.chart(register, month_interval)

      expect(chart.in.count).to eq days_in_month
      chart.in.each do |point|
        expect(point.value).to eq 1300*1000*(24-1)
      end
    end


    it 'day_to_minutes' do |spec|
      meter = Fabricate(:meter_with_input_register)
      register = meter.registers.inputs.first
      energy_milliwatt_hour = 0
      berlin_time = Time.find_zone('Berlin')
      timestamp = berlin_time.local(2015,1,1)
      day_interval = Buzzn::Interval.day(timestamp)
      (1440*6).times do |i|
        reading = Fabricate(:reading,
                            source: 'slp',
                            timestamp: timestamp,
                            energy_milliwatt_hour: energy_milliwatt_hour,
                            power_milliwatt: 930*1000 )
        energy_milliwatt_hour += 1300*1000
        timestamp += 10.second
      end

      chart = data_source.chart(register, day_interval)

      expect(chart.in.count).to eq 1440
      chart.in.each do |point|
        expect(point.value).to eq 930*1000
      end
    end
  end




end
