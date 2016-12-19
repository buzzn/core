# coding: utf-8
require 'buzzn/standard_profile/facade'

describe Buzzn::StandardProfile::Facade do
    let(:facade) { Buzzn::StandardProfile::Facade.new }
    let(:berlin_time) { Time.find_zone('Berlin') }

    it 'value' do |spec|
      energy_milliwatt_hour = 0
      timestamp = berlin_time.local(2015,1,1)
      (24*4).times do |i|
        reading = Fabricate(:reading, source: 'slp',
                            timestamp: timestamp,
                            energy_milliwatt_hour: energy_milliwatt_hour,
                            power_milliwatt: 930*1000 )
        energy_milliwatt_hour += 1300*1000
        timestamp += 15.minutes
      end

      power_value = facade.query_value('slp', berlin_time.local(2015,1,1, 12), ['power'])
      expect(power_value.timestamp).to eq berlin_time.local(2015,1,1, 12)
      expect(power_value.power_milliwatt).to eq 930*1000

      energy_value = facade.query_value('slp', berlin_time.local(2015,1,1, 12), ['energy'])
      expect(energy_value.timestamp).to eq berlin_time.local(2015,1,1, 12)
      expect(energy_value.energy_milliwatt_hour).to eq 4*12*1300*1000
    end




    context 'range' do
      it 'year_to_months' do |spec|
        energy_milliwatt_hour = 0
        timestamp = berlin_time.local(2016,1,1)
        interval  = Buzzn::Interval.year(timestamp)
        366.times do |i|
          reading = Fabricate(:reading,
                              source: 'slp',
                              timestamp: timestamp,
                              energy_milliwatt_hour: energy_milliwatt_hour,
                              power_milliwatt: 930*1000 )
          energy_milliwatt_hour += 19000*1000
          timestamp += 1.day
        end

        power_range = facade.query_range('slp', interval.from_as_time, interval.to_as_time, :year_to_months, ['power']).to_a
        expect(power_range.count).to eq 12
        power_range.each do |point|
          days_in_month = Time.days_in_month(point['lastTimestamp'].month, point['lastTimestamp'].year)
          expect(point['avgPowerMilliwatt']).to eq 930*1000
        end

        energy_range = facade.query_range('slp', interval.from_as_time, interval.to_as_time, :year_to_months, ['energy']).to_a
        expect(energy_range.count).to eq 12
        energy_range.each do |point|
          days_in_month = Time.days_in_month(point['lastTimestamp'].month, point['lastTimestamp'].year)
          expect(point['sumEnergyMilliwattHour']).to eq 19000*1000*(days_in_month-1)
        end
      end


      it 'month_to_days' do |spec|
        energy_milliwatt_hour = 0
        timestamp = berlin_time.local(2015,5,1)
        interval  = Buzzn::Interval.month(timestamp)
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

        power_range = facade.query_range('slp', interval.from_as_time, interval.to_as_time, :month_to_days, ['power']).to_a
        expect(power_range.first['firstTimestamp']).to eq berlin_time.local(2015,5,1)
        expect(power_range.last['lastTimestamp']).to eq berlin_time.local(2015,5,days_in_month,24-1)
        expect(power_range.count).to eq days_in_month
        power_range.each do |point|
          expect(point['avgPowerMilliwatt']).to eq 930*1000
        end

        energy_range = facade.query_range('slp', interval.from_as_time, interval.to_as_time, :month_to_days, ['energy']).to_a
        expect(energy_range.first['firstTimestamp']).to eq berlin_time.local(2015,5,1)
        expect(energy_range.last['lastTimestamp']).to eq berlin_time.local(2015,5,days_in_month,24-1)
        expect(energy_range.count).to eq days_in_month
        energy_range.each do |point|
          expect(point['sumEnergyMilliwattHour']).to eq 1300*1000*(24-1)
        end
      end


      it 'day_to_hours' do |spec|
        energy_milliwatt_hour = 0
        timestamp = berlin_time.local(2015,1,1)
        interval  = Buzzn::Interval.day(timestamp)
        1440.times do |i|
          reading = Fabricate(:reading,
                              source: 'slp',
                              timestamp: timestamp,
                              energy_milliwatt_hour: energy_milliwatt_hour,
                              power_milliwatt: 930*1000 )
          energy_milliwatt_hour += 1300*1000
          timestamp += 1.minute
        end

        power_range = facade.query_range('slp', interval.from_as_time, interval.to_as_time, :day_to_hours, ['power']).to_a
        expect(power_range.first['firstTimestamp']).to eq berlin_time.local(2015,1,1)
        expect(power_range.last['lastTimestamp']).to eq berlin_time.local(2015,1,1, 23,59)
        expect(power_range.count).to eq 24
        power_range.each do |point|
          expect(point['avgPowerMilliwatt']).to eq 930*1000
        end

        energy_range = facade.query_range('slp', interval.from_as_time, interval.to_as_time, :day_to_hours, ['energy']).to_a
        expect(energy_range.count).to eq 24
        expect(energy_range.first['firstTimestamp']).to eq berlin_time.local(2015,1,1)
        expect(energy_range.last['lastTimestamp']).to eq berlin_time.local(2015,1,1, 23,59)
        energy_range.each do |point|
          expect(point['sumEnergyMilliwattHour']).to eq 1300*1000*59
        end
      end


      it 'day_to_minutes' do |spec|
        energy_milliwatt_hour = 0
        timestamp = berlin_time.local(2015,1,1)
        interval  = Buzzn::Interval.day(timestamp)
        (1440*6).times do |i|
          reading = Fabricate(:reading,
                              source: 'slp',
                              timestamp: timestamp,
                              energy_milliwatt_hour: energy_milliwatt_hour,
                              power_milliwatt: 930*1000 )
          energy_milliwatt_hour += 1300*1000
          timestamp += 10.second
        end

        power_range = facade.query_range('slp', interval.from_as_time, interval.to_as_time, :day_to_minutes, ['power']).to_a
        expect(power_range.first['firstTimestamp']).to eq berlin_time.local(2015,1,1)
        expect(power_range.last['lastTimestamp']).to eq berlin_time.local(2015,1,1, 23,59,50)
        expect(power_range.count).to eq 1440
        power_range.each do |point|
          expect(point['avgPowerMilliwatt']).to eq 930*1000
        end

        energy_range = facade.query_range('slp', interval.from_as_time, interval.to_as_time, :day_to_minutes, ['energy']).to_a
        expect(energy_range.first['firstTimestamp']).to eq berlin_time.local(2015,1,1)
        expect(energy_range.last['lastTimestamp']).to eq berlin_time.local(2015,1,1, 23,59,50)
        expect(energy_range.count).to eq 1440
        energy_range.each do |point|
          expect(point['sumEnergyMilliwattHour']).to eq 1300*1000*5 # 5*10 seconds
        end
      end
    end


end
