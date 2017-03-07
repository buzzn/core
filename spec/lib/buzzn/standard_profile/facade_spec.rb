# coding: utf-8

describe Buzzn::StandardProfile::Facade do
    let(:facade) { Buzzn::StandardProfile::Facade.new }
    let(:berlin) { Time.find_zone('Berlin') }
    let(:greenland) { Time.find_zone('Greenland') }

    context 'value' do

      it 'miss' do
        power_value = facade.query_value('slp', berlin.local(2015, 1, 1, 12))
        expect(power_value).to be_nil
      end

      it 'hit' do
        timestamp = berlin.local(2015, 1, 1)
        (24 * 4).times do |i|
          reading = Fabricate(:reading, source: 'slp',
                              timestamp: timestamp + 1.days,
                              power_milliwatt: 930000 )
          timestamp -= 15.minutes
        end

        Timecop.travel(berlin.local(2015, 1, 1, 12))
        begin
          power_value = facade.query_value('slp', berlin.local(2015, 1, 1, 12))
          expect(power_value.timestamp).to eq berlin.local(2015, 1, 1, 12)
          expect(power_value.power_milliwatt).to eq 930000
        ensure
          Timecop.return
        end
      end
    end

    context 'range' do
      context 'year' do

        before(:each) do
          data = []
          energy_milliwatt_hour = 19000000
          # 1 day offset for berlin
          timestamp = Time.find_zone('Berlin').local(2015, 1 ,1).utc - 1.day
          # 3 days offset for greenland, 1 day for berlin,
          # 1 hour for next day overlap
          (365 + 1 + 3).times do |i|
            data << [timestamp, energy_milliwatt_hour]
            energy_milliwatt_hour += 19000000
            timestamp += 1.day
          end
          data.size.times.collect{|i| i}.shuffle.each do |i|
            Fabricate(:reading,
                      source: 'slp',
                      # be imprecise
                      timestamp: data[i][0] + rand * 60,
                      energy_milliwatt_hour: data[i][1] )
          end
        end

        it 'current' do
          now = berlin.local(2015, 5, 12) + 12.hours
          Timecop.freeze(now)
          begin
            interval  = Buzzn::Interval.year(now)

            range = facade.query_range('slp', interval)
            expect(range.count).to eq 5
            4.times.each do |i|
              point = range[i]
              timestamp = point['firstTimestamp'].in_time_zone('Berlin')
              days_in_month = Time.days_in_month(timestamp.month, timestamp.year)
              energy = point['sumEnergyMilliwattHour']
              expect(energy).to eq 19000000 * days_in_month
            end

            point = range[4]
            timestamp = point['firstTimestamp'].in_time_zone('Berlin')
            days_in_month = Time.days_in_month(timestamp.month, timestamp.year)
            energy = point['sumEnergyMilliwattHour']

            expect(energy).to eq 19000000 * 11
          ensure
            Timecop.return
          end
        end

        it 'past empty' do |spec|
          interval  = Buzzn::Interval.year(berlin.local(2010, 3, 5))

          range = facade.query_range('sep', interval)
          expect(range.count).to eq 0

          range = facade.query_range('slp', interval)
          expect(range.count).to eq 0
        end

        it 'past full greenland time' do |spec|
          time = greenland.local(2015, 3, 5)
          interval = Buzzn::Interval.year(time)

          range = facade.query_range('sep', interval)
          expect(range.count).to eq 0

          range = facade.query_range('slp', interval)
          expect(range.count).to eq 12
        end

        it 'past full' do |spec|
          time = berlin.local(2015, 3, 5)
          interval  = Buzzn::Interval.year(time)

          range = facade.query_range('sep', interval)
          expect(range.count).to eq 0

          year_range = facade.query_range('slp', interval)
          expect(year_range.count).to eq 12
          sum = 0
          year_range.each do |point|
            timestamp = point['firstTimestamp'].in_time_zone('Berlin')
            days_in_month = Time.days_in_month(timestamp.month, timestamp.year)
            energy = point['sumEnergyMilliwattHour']
            expect(energy).to eq 19000000 * days_in_month
            sum += energy
          end
          expect(sum).to eq 19000000 * 365

          start = time.beginning_of_year
          12.times do |i|
            interval  = Buzzn::Interval.month(start)
            month_range = facade.query_range('slp', interval)
            sum = 0
            month_range.each do |point|
              sum += point['sumEnergyMilliwattHour']
            end
            expect(year_range[i]['sumEnergyMilliwattHour']).to eq sum
            start = start.next_month
          end
        end
      end

      context 'month' do

        let(:timestamp) { berlin.local(2015, 5, 1) }
        let(:days_in_month) { Time.days_in_month(timestamp.month, timestamp.year) }
        before(:each) do
          energy_milliwatt_hour = 1300000
          time = timestamp.dup
          data = []
          (24 * (1 + days_in_month)).times do |i|
            data << [time, energy_milliwatt_hour]
            energy_milliwatt_hour += 1300000
            time += 1.hour
          end
          data.size.times.collect{|i| i}.shuffle.each do |i|
            Fabricate(:reading,
                      source: 'slp',
                      # be imprecise
                      timestamp: data[i][0] + rand,
                      energy_milliwatt_hour: data[i][1] )
          end
        end

        it 'current' do
          now = berlin.local(2015, 5, 12) + 8.hours
          Timecop.freeze(now)
          begin
            interval  = Buzzn::Interval.month(now)

            range = facade.query_range('slp', interval)
            expect(range.count).to eq 12
            11.times.each do |i|
              point = range[i]
              energy = point['sumEnergyMilliwattHour']
              expect(energy).to eq 1300 * 1000 * 24
            end

            point = range[11]
            timestamp = point['firstTimestamp'].in_time_zone('Berlin')
            days_in_month = Time.days_in_month(timestamp.month, timestamp.year)
            energy = point['sumEnergyMilliwattHour']

            expect(energy).to eq 1300 * 1000 * 7
          ensure
            Timecop.return
          end
        end

        it 'past full greenland time' do |spec|
          time = greenland.local(2015, 5, 5)
          interval  = Buzzn::Interval.month(time)

          range = facade.query_range('sep', interval)
          expect(range.count).to eq 0

          range = facade.query_range('slp', interval)
          expect(range.count).to eq 31
        end

        it 'past empty' do |spec|
          interval  = Buzzn::Interval.month(berlin.local(2010, 5, 5))

          range = facade.query_range('sep', interval)
          expect(range.count).to eq 0

          range = facade.query_range('slp', interval)
          expect(range.count).to eq 0
        end

        it 'past full' do |spec|
          interval  = Buzzn::Interval.month(timestamp)

          range = facade.query_range('sep', interval)
          expect(range.count).to eq 0

          range = facade.query_range('slp', interval)
          expect(range.first['firstTimestamp'].to_i).to eq berlin.local(2015, 5, 1).to_i
          expect(range.last['firstTimestamp'].to_i).to eq berlin.local(2015, 5, days_in_month, 0).to_i
          expect(range.count).to eq 31
          range.each do |point|
            expect(point['sumEnergyMilliwattHour']).to eq 1300 * 1000 * 24
          end
        end
      end

      context 'day' do

        let(:timestamp) { berlin.local(2015, 6, 6) }

        before(:each) do
          time = timestamp.dup
          data = []
          1440.times do |i|
            data << time
            time += 1.minute
          end
          data.size.times.collect{|i| i}.shuffle.each do |i|
            Fabricate(:reading,
                      source: 'slp',
                      # be imprecise
                      timestamp: data[i] + rand,
                      power_milliwatt: 930 * 1000 )
          end
        end

        it 'current' do
          now = berlin.local(2015, 6, 6) + 12.hours
          Timecop.freeze(now)
          begin
            interval  = Buzzn::Interval.day(now)

            range = facade.query_range('slp', interval)
            expect(range.count).to eq 12 * 4
            48.times.each do |i|
              expect(range[i]['avgPowerMilliwatt']).to eq 930 * 1000
            end
          ensure
            Timecop.return
          end
        end

        it 'past full greenland time' do |spec|
          time = greenland.local(2015, 6, 6)
          interval  = Buzzn::Interval.day(time)

          range = facade.query_range('sep', interval)
          expect(range.count).to eq 0

          range = facade.query_range('slp', interval)

          # our data in DB ends Sat, 06 Jun 2015 20:00:00 WGST -02:00
          # which is 2015-06-06 22:00:00 UTC, i.e. missing 4 hours
          expect(range.count).to eq 96 - 4 * 4
          expect(range.last['firstTimestamp'].to_i).to eq (greenland.local(2015, 6, 6, 20) - 15.minutes).to_i
        end

        it 'past empty' do |spec|
          interval  = Buzzn::Interval.day(berlin.local(2005, 6, 6))

          range = facade.query_range('slp', interval)
          expect(range.count).to eq 0

          range = facade.query_range('sep', interval)
          expect(range.count).to eq 0
        end

        it 'past full' do |spec|
          interval  = Buzzn::Interval.day(timestamp)

          range = facade.query_range('sep', interval)
          expect(range.count).to eq 0

          range = facade.query_range('slp', interval)
          expect(range.first['firstTimestamp'].to_i).to eq berlin.local(2015, 6, 6).to_i
          expect(range.last['firstTimestamp'].to_i).to eq berlin.local(2015, 6, 6, 23, 45).to_i
          expect(range.count).to eq 24 * 4
          range.each do |point|
            expect(point['avgPowerMilliwatt']).to eq 930 * 1000
          end
        end
      end


      context 'hour' do

        let(:timestamp) { berlin.local(2015, 11, 14) }

        before(:each) do
          time = timestamp.dup
          data = []
          360.times do |i|
            data << time
            time += 10.seconds
          end
          data.size.times.collect{|i| i}.shuffle.each do |i|
            Fabricate(:reading,
                      source: 'slp',
                      # be imprecise
                      timestamp: data[i] + rand,
                      power_milliwatt: 930 * 1000 )
          end
        end

        it 'past full greenland time' do |spec|
          time = greenland.local(2015, 6, 6)
          interval  = Buzzn::Interval.hour(time)

          range = facade.query_range('sep', interval)
          expect(range.count).to eq 0

          range = facade.query_range('slp', interval)
          # there is no overlap with existing data in DB
          expect(range.count).to eq 0
        end

        it 'current' do
          now = berlin.local(2015, 11, 14) + 23.minutes
          Timecop.freeze(now)
          begin
            interval  = Buzzn::Interval.hour(now)

            range = facade.query_range('slp', interval)
            expect(range.count).to eq 23
            23.times.each do |i|
              expect(range[i]['avgPowerMilliwatt']).to eq 930 * 1000
            end
          ensure
            Timecop.return
          end
        end

        it 'past empty' do |spec|
          interval  = Buzzn::Interval.hour(berlin.local(2005, 6, 6))

          range = facade.query_range('slp', interval)
          expect(range.count).to eq 0

          range = facade.query_range('sep', interval)
          expect(range.count).to eq 0
        end

        it 'past full' do |spec|
          interval  = Buzzn::Interval.hour(timestamp)

          range = facade.query_range('slp', interval)
          expect(range.first['firstTimestamp'].to_i).to eq berlin.local(2015, 11, 14).to_i
          expect(range.last['firstTimestamp'].to_i).to be < berlin.local(2015, 11, 14,  23, 59, 50).to_i
          expect(range.count).to eq 60
          range.each do |point|
            expect(point['avgPowerMilliwatt']).to eq 930 * 1000
          end
        end
      end
    end
end
