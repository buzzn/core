# coding: utf-8
require 'buzzn/standard_profile/facade'

describe Buzzn::StandardProfile::Facade do

    describe 'value' do

      it 'power' do |spec|
        energy_milliwatt_hour = 0
        berlin_time = Time.find_zone('Berlin')
        timestamp = berlin_time.local(2015,1,1)

        (24*4).times do |i|
          reading = Fabricate(:reading,
                              source: 'slp',
                              timestamp: timestamp,
                              energy_milliwatt_hour: energy_milliwatt_hour,
                              power_milliwatt: 930*1000 )
          energy_milliwatt_hour += 1300*1000
          timestamp += 15.minutes
        end

        facade = Buzzn::StandardProfile::Facade.new
        power_value = facade.query_value('slp', berlin_time.local(2015,1,1, 12), ['power'])
        expect(power_value.timestamp).to eq berlin_time.local(2015,1,1, 12)
        expect(power_value.power_milliwatt).to eq 930*1000
      end


      it 'energy' do |spec|
        energy_milliwatt_hour = 0
        berlin_time = Time.find_zone('Berlin')
        timestamp = berlin_time.local(2015,1,1)

        (24*4).times do |i|
          reading = Fabricate(:reading,
                              source: 'slp',
                              timestamp: timestamp,
                              energy_milliwatt_hour: energy_milliwatt_hour,
                              power_milliwatt: 930*1000 )
          energy_milliwatt_hour += 1300*1000
          timestamp += 15.minutes
        end

        facade = Buzzn::StandardProfile::Facade.new
        energy_value = facade.query_value('slp', berlin_time.local(2015,1,1, 12), ['energy'])
        expect(energy_value.timestamp).to eq berlin_time.local(2015,1,1, 12)
        expect(energy_value.energy_milliwatt_hour).to eq 4*12*1300*1000
      end

    end


    describe 'range' do

      it 'energy year_to_months' do |spec|
        energy_milliwatt_hour = 0
        berlin_time = Time.find_zone('Berlin')
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

        facade = Buzzn::StandardProfile::Facade.new
        energy_range = facade.query_range('slp',
                                          interval.from,
                                          interval.to,
                                          :year_to_months,
                                          ['energy']).to_a

        expect(energy_range.count).to eq 12
        energy_range.each do |point|
          days_in_month = Time.days_in_month(point['lastTimestamp'].month, point['lastTimestamp'].year)
          expect(point['sumEnergyMilliwattHour']).to eq 19000*1000*(days_in_month-1)
        end
      end



      it 'energy month_to_days' do |spec|
        energy_milliwatt_hour = 0
        berlin_time = Time.find_zone('Berlin')
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

        facade = Buzzn::StandardProfile::Facade.new
        energy_range = facade.query_range('slp',
                                          interval.from,
                                          interval.to,
                                          :month_to_days,
                                          ['energy']).to_a

        expect(energy_range.count).to eq days_in_month
        expect(energy_range.first['sumEnergyMilliwattHour']).to eq 1300*1000*23
        expect(energy_range.first['firstTimestamp']).to eq berlin_time.local(2015,5,1)
        expect(energy_range.last['lastTimestamp']).to eq berlin_time.local(2015,5,days_in_month,23)
      end



      it 'power day_to_minutes' do |spec|
        energy_milliwatt_hour = 0
        berlin_time = Time.find_zone('Berlin')
        timestamp = berlin_time.local(2015,1,1)
        interval  = Buzzn::Interval.day(timestamp)

        (24*4).times do |i|
          reading = Fabricate(:reading,
                              source: 'slp',
                              timestamp: timestamp,
                              energy_milliwatt_hour: energy_milliwatt_hour,
                              power_milliwatt: 930*1000 )
          energy_milliwatt_hour += 1300*1000
          timestamp += 15.minutes
        end

        facade = Buzzn::StandardProfile::Facade.new
        power_range = facade.query_range( 'slp',
                                          interval.from,
                                          interval.to,
                                          :day_to_minutes,
                                          ['power']).to_a

        expect(power_range.count).to eq 96
        expect(power_range.first['avgPowerMilliwatt']).to eq 930*1000
        expect(power_range.first['firstTimestamp']).to eq berlin_time.local(2015,1,1)
        expect(power_range.last['lastTimestamp']).to eq berlin_time.local(2015,1,1,23,45)
      end

    end




end
