require 'buzzn/discovergy/data_source'

describe Buzzn::StandardProfile::DataSource do

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

      data_source = Buzzn::StandardProfile::DataSource.new
      data_result = data_source.power_value(register, berlin_time.local(2015,4,6))

      expect(data_result.mode).to eq register.mode.to_sym
      expect(data_result.resource_id).to eq register.id
      expect(data_result.value).to eq 930*1000
      expect(data_result.timestamp).to eq berlin_time.local(2015,4,6)
    end

    it 'energy' do |spec|
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

      data_source = Buzzn::StandardProfile::DataSource.new
      data_result = data_source.energy_value(register, berlin_time.local(2015,1,6))

      expect(data_result.mode).to eq register.mode.to_sym
      expect(data_result.resource_id).to eq register.id
      expect(data_result.value).to eq 19000*1000*5
      expect(data_result.timestamp).to eq berlin_time.local(2015,1,6)

    end
  end

  describe 'range' do

    it 'power' do |spec|
      meter = Fabricate(:meter_with_input_register)
      register = meter.registers.inputs.first
      energy_milliwatt_hour = 0
      berlin_time = Time.find_zone('Berlin')
      timestamp = berlin_time.local(2015,1,1)
      interval = Buzzn::Interval.year(timestamp)
      365.times do |i|
        reading = Fabricate(:reading,
                            source: 'slp',
                            timestamp: timestamp,
                            energy_milliwatt_hour: energy_milliwatt_hour,
                            power_milliwatt: 930*1000 )
        energy_milliwatt_hour += 19000*1000
        timestamp += 1.day
      end

      data_source = Buzzn::StandardProfile::DataSource.new
      data_result_set = data_source.power_range(register, interval.from, interval.to, :year_to_months)

      expect(data_result_set.in.count).to eq 12
      data_result_set.in.each do |data_point|
        expect(data_point.value).to eq 930*1000
      end
    end


    it 'energy' do |spec|
      meter = Fabricate(:meter_with_input_register)
      register = meter.registers.inputs.first
      energy_milliwatt_hour = 0
      berlin_time = Time.find_zone('Berlin')
      timestamp = berlin_time.local(2015,1,1)
      interval = Buzzn::Interval.year(timestamp)
      365.times do |i|
        reading = Fabricate(:reading,
                            source: 'slp',
                            timestamp: timestamp,
                            energy_milliwatt_hour: energy_milliwatt_hour,
                            power_milliwatt: 930*1000 )
        energy_milliwatt_hour += 19000*1000
        timestamp += 1.day
      end

      data_source = Buzzn::StandardProfile::DataSource.new
      data_result_set = data_source.energy_range(register, interval.from, interval.to, :year_to_months)
      expect(data_result_set.in.count).to eq 12
    end

  end




end
