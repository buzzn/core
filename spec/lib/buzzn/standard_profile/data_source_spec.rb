require 'buzzn/discovergy/data_source'

describe Buzzn::StandardProfile::DataSource do
  let(:data_source) { Buzzn::StandardProfile::DataSource.new }
  let(:berlin_time) { Time.find_zone('Berlin') }


  describe 'single_aggregated' do
    it 'power for a slp register' do |spec|
      meter = Fabricate(:meter_with_input_register)
      register = meter.registers.inputs.first
      energy_milliwatt_hour = 0
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

      Timecop.freeze(berlin_time.local(2015,4,6))
      single_aggregated = data_source.single_aggregated(register, :in)
      expect(single_aggregated.mode).to eq :in
      expect(single_aggregated.resource_id).to eq register.id
      expect(single_aggregated.value).to eq 930*1000
      expect(single_aggregated.timestamp).to eq berlin_time.local(2015,4,6).to_i
      Timecop.return
    end

    it 'power for a sep_bhkw register' do |spec|
      meter = Fabricate(:meter_with_output_register)
      register = meter.registers.outputs.first
      energy_milliwatt_hour = 0
      timestamp = berlin_time.local(2015,1,1)

      365.times do |i|
        reading = Fabricate(:reading,
                            source: 'sep_bhkw',
                            timestamp: timestamp,
                            energy_milliwatt_hour: energy_milliwatt_hour,
                            power_milliwatt: 930*1000 )
        energy_milliwatt_hour += 19000*1000
        timestamp += 1.day
      end

      Timecop.freeze(berlin_time.local(2015,4,6))
      single_aggregated = data_source.single_aggregated(register, :out)
      expect(single_aggregated.mode).to eq :out
      expect(single_aggregated.resource_id).to eq register.id
      expect(single_aggregated.value).to eq 930*1000
      expect(single_aggregated.timestamp).to eq berlin_time.local(2015,4,6).to_i
      Timecop.return
    end

    xit 'single_aggregated power for a group' do |spec|
    end

  end


  describe 'collection' do

    it 'power for a group' do |spec|
      meter1 = Fabricate(:meter_with_input_register)
      meter2 = Fabricate(:meter_with_input_register)
      meter3 = Fabricate(:meter_with_output_register)
      group  = Fabricate(:tribe)
      group.registers << meter1.registers.inputs.first
      group.registers << meter2.registers.inputs.first
      group.registers << meter3.registers.outputs.first

      energy_milliwatt_hour = 0
      timestamp = berlin_time.local(2015,1,1)
      365.times do |i|

        Fabricate(:reading,
                  source: 'slp',
                  timestamp: timestamp,
                  energy_milliwatt_hour: energy_milliwatt_hour,
                  power_milliwatt: 930*1000 )

        Fabricate(:reading,
                  source: 'sep_bhkw',
                  timestamp: timestamp,
                  energy_milliwatt_hour: energy_milliwatt_hour,
                  power_milliwatt: 1900*1000 )

        energy_milliwatt_hour += 19000*1000
        timestamp += 1.day
      end

      Timecop.freeze(berlin_time.local(2015,4,6))
      collection = data_source.collection(group, :in)
      expect(collection.count).to eq group.registers.inputs.count
      sum_values = 0
      collection.each do |data_result|
        sum_values += data_result.value
      end
      expect(sum_values).to eq (930+930)*1000
      Timecop.return
    end

  end




  describe 'aggregated' do

    it 'year_to_months' do |spec|
      meter = Fabricate(:meter_with_input_register)
      register = meter.registers.inputs.first
      energy_milliwatt_hour = 0
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

      aggregated = data_source.aggregated(register, :in, year_interval)
      expect(aggregated.in.count).to eq 12
      aggregated.in.each do |point|
        timestamp = Time.at(point.timestamp)
        days_in_month = Time.days_in_month(timestamp.month, timestamp.year)
        expect(point.value).to eq 19000*1000*(days_in_month-1)
      end
    end


    it 'month_to_days' do |spec|
      meter = Fabricate(:meter_with_input_register)
      register = meter.registers.inputs.first
      energy_milliwatt_hour = 0
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

      aggregated = data_source.aggregated(register, :in, month_interval)
      expect(aggregated.in.count).to eq days_in_month
      aggregated.in.each do |point|
        expect(point.value).to eq 1300*1000*(24-1)
      end
    end


    it 'day_to_minutes' do |spec|
      meter = Fabricate(:meter_with_input_register)
      register = meter.registers.inputs.first
      energy_milliwatt_hour = 0
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

      aggregated = data_source.aggregated(register, :in, day_interval)

      expect(aggregated.in.count).to eq 1440
      aggregated.in.each do |point|
        expect(point.value).to eq 930*1000
      end
    end
  end




end
