
describe Buzzn::StandardProfile::DataSource do
  let(:data_source) { Buzzn::StandardProfile::DataSource.new }
  let(:utc) { Time.find_zone('UTC') }
  let(:berlin) { Time.find_zone('Berlin') }
  let(:greenland) { Time.find_zone('Greenland') }
  let(:sep_bhkw_register) do
    meter = Fabricate(:output_meter)
    meter.output_register
  end
  let(:slp_register) do
    meter = Fabricate(:input_meter)
    meter.input_register
  end
  let(:sep_pv_register) do
    meter = Fabricate(:output_meter)
    meter.output_register.devices << Fabricate(:dach_pv_justus)
    meter.output_register
  end
  let(:group) do
    group = Fabricate(:tribe)
    group.registers << Fabricate(:input_meter).input_register
    group.registers << slp_register
    group.registers << sep_bhkw_register
    group.registers << sep_pv_register
    group
  end

  let(:virtual_register) do
    register = Fabricate(:virtual_meter).register
    Fabricate(:fp_plus, operand_id: Fabricate(:input_meter).input_register.id, register_id: register.id)
    Fabricate(:fp_minus, operand_id: slp_register.id, register_id: register.id)
    Fabricate(:fp_plus, operand_id: sep_bhkw_register.id, register_id: register.id)
    Fabricate(:fp_minus, operand_id: sep_pv_register.id, register_id: register.id)
    register
  end

  describe 'single_aggregated' do

    [Reading::SLP, Reading::SEP_BHKW, Reading::SEP_PV].each do |type|

      it "#{type} register" do
        register = send("#{type}_register".to_sym)
        timestamp = utc.local(2015,4,1)

        16.times do |i|
          reading = Fabricate(:reading,
                              source: type,
                              timestamp: timestamp,
                              power_milliwatt: 930000 )
          timestamp += 1.day
        end

        Timecop.freeze(utc.local(2015,4,6))
        begin
          direction = type == Reading::SLP ? :in : :out
          single_aggregated = data_source.single_aggregated(register, direction)
          expect(single_aggregated.mode).to eq direction
          expect(single_aggregated.resource_id).to eq register.id
          expect(single_aggregated.value).to eq 930000
          expect(single_aggregated.timestamp).to eq utc.local(2015, 4, 6).to_i
        ensure
          Timecop.return
        end
      end
    end

    it :group do

      timestamp = utc.local(2015, 4, 1)
      10.times do |i|

        Fabricate(:reading,
                  source: 'slp',
                  timestamp: timestamp,
                  power_milliwatt: 930000 )

        Fabricate(:reading,
                  source: 'sep_bhkw',
                  timestamp: timestamp,
                  power_milliwatt: 1900000 )

        Fabricate(:reading,
                  source: 'sep_pv',
                  timestamp: timestamp,
                  power_milliwatt: 110000 )

        timestamp += 1.day
      end

      Timecop.freeze(utc.local(2015,4,6))
      begin
        [:in, :out].each do |direction|
          single_aggregated = data_source.single_aggregated(group, direction)
          expect(single_aggregated.mode).to eq direction
          expect(single_aggregated.resource_id).to eq group.id
          expect(single_aggregated.value).to eq (direction == :in ? 1860000 : 2010000)
          expect(single_aggregated.timestamp).to eq utc.local(2015, 4, 6).to_i
        end
      ensure
        Timecop.return
      end
    end

  end


  describe 'collection' do

    [:group, :virtual_register].each do |resource_name|
      it resource_name do
        resource = send resource_name

        timestamp = utc.local(2015, 4, 1)
        10.times do |i|

          Fabricate(:reading,
                    source: 'slp',
                    timestamp: timestamp,
                    power_milliwatt: 930000 )

          Fabricate(:reading,
                    source: 'sep_bhkw',
                    timestamp: timestamp,
                    power_milliwatt: 1900000 )

          Fabricate(:reading,
                    source: 'sep_pv',
                    timestamp: timestamp,
                    power_milliwatt: 110000 )

          timestamp += 1.day
        end

        Timecop.freeze(utc.local(2015, 4, 6))
        begin
          [:in, :out].each do |direction|
            collection = data_source.collection(resource, direction)
            expect(collection.count).to eq resource.registers.send("#{direction}puts".to_sym).count
            sum_values = 0
            collection.each do |data_result|
              sum_values += data_result.value
            end
            if direction == :out
              expect(sum_values).to eq (1900000 + 110000)
            else
              expect(sum_values).to eq (collection.count * 930000.0)
            end
          end
        ensure
          Timecop.return
        end
      end
    end
  end




  describe 'aggregated' do

    context 'year' do
      before do
        energy_milliwatt_hour = 19200000 # 24 * 800000
        # 1 day offset for berlin
        timestamp = utc.local(2015, 1 ,1) - 1.day
        # 3 days offset for greenland, 1 day for berlin,
        # 1 hour for next day overlap
        ((365 + 1 + 3 ) * 24 + 1).times do |i|
          reading = Fabricate(:reading,
                              source: 'slp',
                              timestamp: timestamp,
                              energy_milliwatt_hour: energy_milliwatt_hour )
          energy_milliwatt_hour += 800000
          timestamp += 1.hour
        end
      end

      [:utc, :greenland, :berlin].each do |tz|
        it "#{tz}" do
          timezone = send tz
          register = Fabricate(:input_meter).input_register
          year_interval = Buzzn::Interval.year(timezone.local(2015, 3, 2))
          aggregated = data_source.aggregated(register, :in, year_interval)
          expect(aggregated.in.count).to eq 12
          aggregated.in.each_with_index do |point, index|
            timestamp = Time.at(point.timestamp)
            days_in_month = Time.days_in_month(timestamp.month, timestamp.year)
            # the data is constructed to have a datapoint at the beginning of
            # the month
            time = Time.at(point.timestamp).in_time_zone(timezone).strftime('%Y-%m-%d %H:%M:%S')
            # need to compensate daylight saving
            expected = %r{2015-#{index >= 9 ? '' : '0'}#{index + 1}-01 0[0,1]:00:00}
            expect(time).to match expected
            expect(point.value).to eq 19200000 * days_in_month
          end
        end
      end
    end

    context 'month' do

      before do
        energy_milliwatt_hour = 1320000 # 55000 * 24
        # 1 day offset for berlin
        timestamp = utc.local(2015, 1 ,1) - 1.day
        # 3 days offset for greenland, 1 day for berlin,
        # 1 hour for next day overlap
        ((31 + 1 + 3) * 24 + 1).times do |i|
          reading = Fabricate(:reading,
                              source: 'slp',
                              timestamp: timestamp,
                              energy_milliwatt_hour: energy_milliwatt_hour )
          energy_milliwatt_hour += 55000
          timestamp += 1.hour
        end
      end

      [:utc, :greenland, :berlin].each do |tz|
        it "#{tz}" do
          timezone = send tz
          register = Fabricate(:input_meter).input_register
          month_interval = Buzzn::Interval.month(timezone.local(2015, 1, 1))

          aggregated = data_source.aggregated(register, :in, month_interval)
          expect(aggregated.in.count).to eq 31
          aggregated.in.each_with_index do |point, index|
            # the data is constructed to have a datapoint at the beginning of
            # the day
            time = Time.at(point.timestamp).in_time_zone(timezone).strftime('%Y-%m-%d %H:%M:%S')
            # need to compensate daylight saving
            expected = %r{2015-01-#{index >= 9 ? '' : '0'}#{index + 1} 0[0,1]:00:00}
            expect(time).to match expected
            expect(point.value).to eq 1320000 # 55000 * 24
          end
        end
      end
    end


    context 'day' do

      before do
        # 1 day offset for berlin
        timestamp = utc.local(2015, 1 ,1) - 1.day
        # 3 days offset for greenland, 1 day for berlin,
        (1440 * 4).times do |i|
          reading = Fabricate(:reading,
                              source: 'slp',
                              timestamp: timestamp,
                              power_milliwatt: 930000 )
          timestamp += 1.minutes
        end
      end

      let(:fifteens) { ['00', '15', '30', '45' ] }

      [:utc, :greenland, :berlin].each do |tz|
         it "#{tz}" do
           timezone = send tz
           register = Fabricate(:input_meter).input_register
           day_interval = Buzzn::Interval.day(timezone.local(2015, 1, 1))

           aggregated = data_source.aggregated(register, :in, day_interval)

           expect(aggregated.in.count).to eq 96
           aggregated.in.each_with_index do |point, index|

             # the data is constructed to have a datapoint at every 15 minutes
             time = Time.at(point.timestamp).in_time_zone(timezone).strftime('%Y-%m-%d %H:%M:%S')
             hour = index / 4
             expected = %r{2015-01-01 #{hour > 9 ? '' : '0'}#{hour}:#{fifteens[index % 4]}:00}
             expect(time).to match expected
             expect(point.value).to eq 930000
           end
         end
      end
    end


    context 'hour' do

      before do
        # 1 day offset for berlin
        timestamp = utc.local(2015, 1 ,1) - 1.hour
        # 3 days offset for greenland, 1 day for berlin,
        (60 * 5).times do |i|
          reading = Fabricate(:reading,
                              source: 'slp',
                              timestamp: timestamp,
                              power_milliwatt: 930000 )
          timestamp += 1.minutes
        end
      end

      [:utc, :greenland, :berlin].each do |tz|
         it "#{tz}" do
           timezone = send tz
           register = Fabricate(:input_meter).input_register
           interval = Buzzn::Interval.hour(timezone.local(2015, 1, 1))

           aggregated = data_source.aggregated(register, :in, interval)

           expect(aggregated.in.count).to eq 60
           aggregated.in.each_with_index do |point, index|
             # the data is constructed to have a datapoint at each minute
             time = Time.at(point.timestamp).in_time_zone(timezone).strftime('%Y-%m-%d %H:%M:%S')
             # need to compensate daylight saving
             expected = %r{2015-01-01 0[0,1]:#{index > 9 ? '' : '0'}#{index}:00}
             expect(time).to match expected
             expect(point.value).to eq 930000
           end
         end
      end
    end
  end




end
