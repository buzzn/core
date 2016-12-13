# coding: utf-8
require 'buzzn/standard_profile/facade'

describe Buzzn::StandardProfile::Facade do


    describe 'slp' do

      it 'year_to_months' do |spec|
        energy_milliwatt_hour = 0
        berlin_time = Time.find_zone('Berlin')
        timestamp = berlin_time.local(2015,1,1)
        interval  = Buzzn::Interval.year(timestamp)
        365.times do |i|
          reading = Fabricate(:reading,
                              source: 'slp',
                              timestamp: timestamp,
                              energy_milliwatt_hour: energy_milliwatt_hour,
                              power_milliwatt: 930*1000 )
          energy_milliwatt_hour += 19000*1000
          timestamp += 1.day
        end

        facade = Buzzn::StandardProfile::Facade.new
        energy_chart = facade.aggregate('slp', interval, ['energy']).to_a

        expect(energy_chart.count).to eq 12
        energy_chart.each do |point|
          days_in_month = Time.days_in_month(point['lastTimestamp'].month, point['lastTimestamp'].year)
          expect(point['sumEnergyMilliwattHour']).to eq 19000*1000*(days_in_month-1)
        end
      end



      it 'month_to_days' do |spec|
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
        energy_chart = facade.aggregate('slp', interval, ['energy']).to_a

        expect(energy_chart.count).to eq days_in_month
        expect(energy_chart.first['sumEnergyMilliwattHour']).to eq 1300*1000*23
        expect(energy_chart.first['firstTimestamp']).to eq berlin_time.local(2015,5,1)
        expect(energy_chart.last['lastTimestamp']).to eq berlin_time.local(2015,5,days_in_month,23)
      end



      it 'day_to_minutes' do |spec|
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
        power_chart = facade.aggregate('slp', interval, ['power']).to_a

        expect(power_chart.count).to eq 96
        expect(power_chart.first['avgPowerMilliwatt']).to eq 930*1000
        expect(power_chart.first['firstTimestamp']).to eq berlin_time.local(2015,1,1)
        expect(power_chart.last['lastTimestamp']).to eq berlin_time.local(2015,1,1,23,45)
      end

    end




end
