describe '/api/v1/aggregates' do

  before do
    Fabricate(:metering_point_operator, name: 'buzzn Metering')
    Fabricate(:metering_point_operator, name: 'Discovergy')
    Fabricate(:metering_point_operator, name: 'MySmartGrid')
  end

  api_version = '/api/v1'
  api_controller = '/aggregates'

  describe '/past' do
    api_endpoint = api_version + api_controller + '/past'




    it 'slp energy by year_to_months as admin in summertime' do
      access_token = Fabricate(:full_access_token_as_admin)
      metering_point = Fabricate(:metering_point)
      energy_a_milliwatt_hour = 0
      timestamp = Time.find_zone('Moscow').local(2015,1,1)
      (400).times do |i|
        Fabricate(:reading,
                  source: 'slp',
                  timestamp: timestamp,
                  energy_a_milliwatt_hour: energy_a_milliwatt_hour,
                  power_a_milliwatt: 930*1000
                 )
        energy_a_milliwatt_hour += 1300*1000
        timestamp += 1.day
      end
      request_params = {
        metering_point_ids: metering_point.id,
        resolution: 'year_to_months',
        timestamp: Time.find_zone('Moscow').local(2015,6).iso8601
      }
      get_with_token api_endpoint, request_params, access_token.token
      expect(response).to have_http_status(200)
      expect(json.count).to eq(12) # 12 month
      timestamp = Time.find_zone('Moscow').local(2015,1,1)
      json.each do |item|
        expect(Time.parse(item['timestamp']).utc).to eq(timestamp.utc)
        expect(item['energy_milliwatt_hour']).to eq(1300*1000 * (Time.days_in_month(timestamp.month, timestamp.year)-1)) # -1 day becouse it is in the next day
        timestamp += 1.month
      end
    end



    it 'slp energy by month_to_days as stranger in wintertime' do
      metering_point = Fabricate(:metering_point, readable: 'world')
      access_token  = Fabricate(:simple_access_token)
      energy_a_milliwatt_hour = 0
      timestamp = Time.find_zone('Berlin').local(2016,1,1)
      (24*32).times do |i|
        Fabricate(:reading,
                  source: 'slp',
                  timestamp: timestamp,
                  energy_a_milliwatt_hour: energy_a_milliwatt_hour,
                  power_a_milliwatt: 930*1000
                 )
        energy_a_milliwatt_hour += 1300*1000
        timestamp += 1.hour
      end
      request_params = {
        metering_point_ids: metering_point.id,
        timestamp: Time.find_zone('Berlin').local(2016,1,17).iso8601,
        resolution: 'month_to_days'
      }
      get_with_token api_endpoint, request_params, access_token.token
      expect(response).to have_http_status(200)
      expect(json.count).to eq(31)
      timestamp = Time.find_zone('Berlin').local(2016,1,1)
      json.each do |item|
        expect(Time.parse(item['timestamp']).utc).to eq(timestamp.utc)
        expect(item['power_milliwatt']).to eq(nil)
        expect(item['energy_milliwatt_hour']).to eq(24*1300*1000)
        expect(item['energy_b_milliwatt_hour']).to eq(nil)
        timestamp += 1.day
      end
    end



    it 'slp energy by month_to_days as admin in summertime ' do
      access_token = Fabricate(:full_access_token_as_admin)
      metering_point = Fabricate(:metering_point)
      energy_a_milliwatt_hour = 0
      timestamp = Time.find_zone('Berlin').local(2016,6,1)
      (24*31).times do |i|
        Fabricate(:reading,
                  source: 'slp',
                  timestamp: timestamp,
                  energy_a_milliwatt_hour: energy_a_milliwatt_hour,
                  power_a_milliwatt: 930*1000
                 )
        energy_a_milliwatt_hour += 1300*1000
        timestamp += 1.hour
      end
      request_params = {
        metering_point_ids: metering_point.id,
        resolution: 'month_to_days',
        timestamp: Time.find_zone('Berlin').local(2016,6,2).iso8601
      }
      get_with_token api_endpoint, request_params, access_token.token
      expect(response).to have_http_status(200)
      expect(json.count).to eq(30)
      timestamp = Time.find_zone('Berlin').local(2016,6,1)
      json.each do |item|
        expect(Time.parse(item['timestamp']).utc).to eq(timestamp.utc)
        expect(item['power_milliwatt']).to eq(nil)
        expect(item['energy_milliwatt_hour']).to eq(24*1300*1000)
        expect(item['energy_b_milliwatt_hour']).to eq(nil)
        timestamp += 1.day
      end
    end




    it 'slp power by day_to_minutes as admin' do
      access_token = Fabricate(:full_access_token_as_admin)
      metering_point = Fabricate(:metering_point)
      energy_a_milliwatt_hour = 0
      timestamp = Time.find_zone('Berlin').local(2015,2,1)
      # 3 hours * 60 minutes * 60/2 seconds
      (3*60*30).times do |i|
        Fabricate(:reading,
                  source: 'slp',
                  timestamp: timestamp,
                  energy_a_milliwatt_hour: energy_a_milliwatt_hour,
                  power_a_milliwatt: 930*1000
                 )
        energy_a_milliwatt_hour += 1300*1000
        timestamp += 2.second
      end
      request_params = {
        metering_point_ids: metering_point.id,
        resolution: 'day_to_minutes',
        timestamp: Time.find_zone('Berlin').local(2015,2,1).iso8601
      }
      get_with_token api_endpoint, request_params, access_token.token
      expect(response).to have_http_status(200)
      expect(json.count).to eq(3*60) # 3 hours
      timestamp = Time.find_zone('Berlin').local(2015,2,1)
      json.each do |item|
        expect( Time.parse(item['timestamp']).utc ).to eq(timestamp.utc)
        expect(item['power_milliwatt']).to eq(930*1000)
        expect(item['energy_milliwatt_hour']).to eq(nil)
        expect(item['energy_b_milliwatt_hour']).to eq(nil)
        timestamp += 1.minutes
      end
    end


    it 'slp power by hour_to_minutes as admin' do
      access_token = Fabricate(:full_access_token_as_admin)
      metering_point = Fabricate(:metering_point)
      energy_a_milliwatt_hour = 0
      timestamp = Time.find_zone('Bangkok').local(2015,2,1)
      4.times do |i|
        Fabricate(:reading,
                  source: 'slp',
                  timestamp: timestamp,
                  energy_a_milliwatt_hour: energy_a_milliwatt_hour,
                  power_a_milliwatt: 930*1000
                 )
        energy_a_milliwatt_hour += 1300*1000
        timestamp += 15.minutes
      end
      request_params = {
        metering_point_ids: metering_point.id,
        resolution: 'hour_to_minutes',
        timestamp: Time.find_zone('Bangkok').local(2015,2,1, 0,30).iso8601
      }
      get_with_token api_endpoint, request_params, access_token.token
      expect(response).to have_http_status(200)
      expect(json.count).to eq(4)
      timestamp = Time.find_zone('Bangkok').local(2015,2,1)
      json.each do |item|
        expect( Time.parse(item['timestamp']).utc ).to eq(timestamp.utc)
        expect(item['power_milliwatt']).to eq(930*1000)
        expect(item['energy_milliwatt_hour']).to eq(nil)
        expect(item['energy_b_milliwatt_hour']).to eq(nil)
        timestamp += 15.minutes
      end
    end



    it 'differend power by hour_to_minutes as admin' do
      access_token = Fabricate(:full_access_token_as_admin)
      slp = Fabricate(:metering_point)
      pv = Fabricate(:easymeter_60051599).metering_points.first
      energy_a_milliwatt_hour = 0
      timestamp = Time.find_zone('Sydney').local(2015,2,1)
      (60*60).times do |i|
        Fabricate(:reading,
                  source: 'slp',
                  timestamp: timestamp,
                  energy_a_milliwatt_hour: energy_a_milliwatt_hour,
                  power_a_milliwatt: 930*1000
                 )
        energy_a_milliwatt_hour += 1300
        timestamp += 1.second
      end
      request_params = {
        metering_point_ids: "#{slp.id},#{pv.id}",
        resolution: 'hour_to_minutes',
        timestamp: Time.find_zone('Sydney').local(2015,2,1, 0,30).iso8601
      }

      get_with_token api_endpoint, request_params, access_token.token
      expect(response).to have_http_status(406)

    end



    it 'no more than 5 metering_points as admin' do
      access_token = Fabricate(:full_access_token_as_admin)
      slp1 = Fabricate(:metering_point)
      slp2 = Fabricate(:metering_point)
      slp3 = Fabricate(:metering_point)
      slp4 = Fabricate(:metering_point)
      slp5 = Fabricate(:metering_point)
      slp6 = Fabricate(:metering_point)
      energy_a_milliwatt_hour = 0
      timestamp = Time.find_zone('Sydney').local(2015,2,1)
      (60*60).times do |i|
        Fabricate(:reading,
                  source: 'slp',
                  timestamp: timestamp,
                  energy_a_milliwatt_hour: energy_a_milliwatt_hour,
                  power_a_milliwatt: 930*1000
                 )
        energy_a_milliwatt_hour += 1300
        timestamp += 1.second
      end
      request_params = {
        metering_point_ids: "#{slp1.id},#{slp2.id},#{slp3.id},#{slp4.id},#{slp5.id},#{slp6.id}",
        resolution: 'hour_to_minutes',
        timestamp: Time.find_zone('Sydney').local(2015,2,1, 0,30).iso8601
      }

      get_with_token api_endpoint, request_params, access_token.token
      expect(response).to have_http_status(413)

    end




    it 'multiple slp power by hour_to_minutes as admin' do
      access_token = Fabricate(:full_access_token_as_admin)
      metering_point1 = Fabricate(:metering_point)
      metering_point2 = Fabricate(:metering_point)
      energy_a_milliwatt_hour = 0
      timestamp = Time.find_zone('Sydney').local(2015,2,1)
      (60*60).times do |i|
        Fabricate(:reading,
                  source: 'slp',
                  timestamp: timestamp,
                  energy_a_milliwatt_hour: energy_a_milliwatt_hour,
                  power_a_milliwatt: 930*1000
                 )
        energy_a_milliwatt_hour += 1300
        timestamp += 1.second
      end
      request_params = {
        metering_point_ids: "#{metering_point1.id},#{metering_point2.id}",
        resolution: 'hour_to_minutes',
        timestamp: Time.find_zone('Sydney').local(2015,2,1, 0,30).iso8601
      }

      get_with_token api_endpoint, request_params, access_token.token
      expect(response).to have_http_status(200)

      expect(json.count).to eq(60)
      timestamp = Time.find_zone('Sydney').local(2015,2,1)
      json.each do |item|
        expect(Time.parse(item['timestamp'])).to eq(timestamp.utc)
        expect(item['power_milliwatt']).to eq(2*930*1000)
        expect(item['energy_milliwatt_hour']).to eq(nil)
        expect(item['energy_b_milliwatt_hour']).to eq(nil)
        timestamp += 1.minute
      end
    end



    it 'multiple slp power by hour_to_minutes with forecast_kwh_pa as admin' do
      access_token = Fabricate(:full_access_token_as_admin)
      metering_point1 = Fabricate(:metering_point, forecast_kwh_pa: 3000)
      metering_point2 = Fabricate(:metering_point, forecast_kwh_pa: 8000)
      energy_a_milliwatt_hour = 0
      timestamp = Time.find_zone('Berlin').local(2015,2,1)
      4.times do |i|
        Fabricate(:reading,
                  source: 'slp',
                  timestamp: timestamp,
                  energy_a_milliwatt_hour: energy_a_milliwatt_hour,
                  power_a_milliwatt: 930*1000
                 )
        energy_a_milliwatt_hour += 1300*1000
        timestamp += 15.minutes
      end
      request_params = {
        metering_point_ids: "#{metering_point1.id},#{metering_point2.id}",
        resolution: 'hour_to_minutes',
        timestamp: Time.find_zone('Berlin').local(2015,2,1,0,30).iso8601
      }

      get_with_token api_endpoint, request_params, access_token.token
      expect(response).to have_http_status(200)

      expect(json.count).to eq(4)
      timestamp = Time.find_zone('Berlin').local(2015,2,1)
      json.each do |item|
        expect(Time.parse(item['timestamp'])).to eq(timestamp.utc)
        expect(item['power_milliwatt']).to eq(930*1000*11) # 3000 + 8000 / 1000 = 11
        expect(item['energy_milliwatt_hour']).to eq(nil)
        expect(item['energy_b_milliwatt_hour']).to eq(nil)
        timestamp += 15.minutes
      end
    end


    it 'slp energy by year_to_months in summertime just until now as admin' do
      access_token = Fabricate(:full_access_token_as_admin)
      metering_point = Fabricate(:metering_point)
      energy_a_milliwatt_hour = 0
      timestamp = Time.find_zone('Moscow').local(2015,1,1)
      (400).times do |i|
        Fabricate(:reading,
                  source: 'slp',
                  timestamp: timestamp,
                  energy_a_milliwatt_hour: energy_a_milliwatt_hour,
                  power_a_milliwatt: 930*1000
                 )
        energy_a_milliwatt_hour += 1300*1000
        timestamp += 1.day
      end
      Timecop.freeze( Time.find_zone('Moscow').local(2015,7,2, 1,30,1) )
      request_params = {
        metering_point_ids: metering_point.id,
        resolution: 'year_to_months',
        timestamp: Time.find_zone('Moscow').local(2015,6).iso8601
      }

      get_with_token api_endpoint, request_params, access_token.token
      expect(response).to have_http_status(200)
      expect(json.count).to eq(7) # 7 month

      timestamp = Time.find_zone('Moscow').local(2015,1,1)
      i = 1
      json.each do |item|
        expect(Time.parse(item['timestamp']).utc).to eq(timestamp.utc)
        if i < 7
          expect(item['energy_milliwatt_hour']).to eq(1300*1000 * (Time.days_in_month(timestamp.month, timestamp.year)-1)) # -1 day becouse it is in the next day
        end
        timestamp += 1.month
        i+=1
      end
      Timecop.return
    end


    it 'slp power by day_to_minutes just until now as admin' do
      access_token = Fabricate(:full_access_token_as_admin)
      metering_point = Fabricate(:metering_point)
      energy_a_milliwatt_hour = 0
      timestamp = Time.find_zone('Berlin').local(2015,2,1)
      # 24 hours * 60 minutes * 60/2 seconds
      (24*60*30).times do |i|
        Fabricate(:reading,
                  source: 'slp',
                  timestamp: timestamp,
                  energy_a_milliwatt_hour: energy_a_milliwatt_hour,
                  power_a_milliwatt: 930*1000
                 )
        energy_a_milliwatt_hour += 1300*1000
        timestamp += 2.second
      end
      Timecop.freeze( Time.find_zone('Berlin').local(2015,2,1, 11,30,1) )
      request_params = {
        metering_point_ids: metering_point.id,
        resolution: 'day_to_minutes',
        timestamp: Time.find_zone('Berlin').local(2015,2,1).iso8601
      }

      get_with_token api_endpoint, request_params, access_token.token
      expect(response).to have_http_status(200)
      expect(json.count).to eq(11.5*60 + 1)

      timestamp = Time.find_zone('Berlin').local(2015,2,1)
      json.each do |item|
        expect( Time.parse(item['timestamp']).utc ).to eq(timestamp.utc)
        expect(item['power_milliwatt']).to eq(930*1000)
        expect(item['energy_milliwatt_hour']).to eq(nil)
        expect(item['energy_b_milliwatt_hour']).to eq(nil)
        timestamp += 1.minutes
      end
      Timecop.return
    end


    it 'slp energy by month_to_days in summertime just until now as admin' do
      access_token = Fabricate(:full_access_token_as_admin)
      metering_point = Fabricate(:metering_point)
      energy_a_milliwatt_hour = 0
      timestamp = Time.find_zone('Berlin').local(2016,6,1)
      (24*30).times do |i|
        Fabricate(:reading,
                  source: 'slp',
                  timestamp: timestamp,
                  energy_a_milliwatt_hour: energy_a_milliwatt_hour,
                  power_a_milliwatt: 930*1000
                 )
        energy_a_milliwatt_hour += 1300*1000
        timestamp += 1.hour
      end
      Timecop.freeze( Time.find_zone('Berlin').local(2016,6,13, 11,30,1) )
      request_params = {
        metering_point_ids: metering_point.id,
        resolution: 'month_to_days',
        timestamp: Time.find_zone('Berlin').local(2016,6,2).iso8601
      }

      get_with_token api_endpoint, request_params, access_token.token
      expect(response).to have_http_status(200)
      expect(json.count).to eq(13)

      timestamp = Time.find_zone('Berlin').local(2016,6,1)
      i = 1
      json.each do |item|
        expect(Time.parse(item['timestamp']).utc).to eq(timestamp.utc)
        expect(item['power_milliwatt']).to eq(nil)
        expect(item['energy_milliwatt_hour']).to eq(24*1300*1000) if i < 13
        expect(item['energy_b_milliwatt_hour']).to eq(nil)
        timestamp += 1.day
        i+=1
      end
      Timecop.return
    end



    it 'sep bhkw energy by year_to_months in summertime as admin' do
      access_token = Fabricate(:full_access_token_as_admin)
      metering_point = Fabricate(:metering_point, mode: 'out')
      energy_a_milliwatt_hour = 0
      timestamp = Time.find_zone('Moscow').local(2015,1,1)
      (400).times do |i|
        Fabricate(:reading,
                  source: 'sep_bhkw',
                  timestamp: timestamp,
                  energy_a_milliwatt_hour: energy_a_milliwatt_hour,
                  power_a_milliwatt: 930*1000
                 )
        energy_a_milliwatt_hour += 1300*1000
        timestamp += 1.day
      end
      request_params = {
        metering_point_ids: metering_point.id,
        resolution: 'year_to_months',
        timestamp: Time.find_zone('Moscow').local(2015,6).iso8601
      }

      get_with_token api_endpoint, request_params, access_token.token
      expect(response).to have_http_status(200)
      expect(json.count).to eq(12) # 12 month

      timestamp = Time.find_zone('Moscow').local(2015,1,1)
      json.each do |item|
        expect(Time.parse(item['timestamp']).utc).to eq(timestamp.utc)
        expect(item['energy_milliwatt_hour']).to eq(1300*1000 * (Time.days_in_month(timestamp.month, timestamp.year)-1)) # -1 day becouse it is in the next day
        timestamp += 1.month
      end
    end


    it 'sep bhkw energy by month_to_days in summertime as admin' do
      access_token = Fabricate(:full_access_token_as_admin)
      metering_point = Fabricate(:metering_point, mode: 'out')
      energy_a_milliwatt_hour = 0
      timestamp = Time.find_zone('UTC').local(2016,6,1) - 1.day
      (24*32).times do |i|
        Fabricate(:reading,
                  source: 'sep_bhkw',
                  timestamp: timestamp,
                  energy_a_milliwatt_hour: energy_a_milliwatt_hour,
                  power_a_milliwatt: 930*1000
                 )
        energy_a_milliwatt_hour += 1300*1000
        timestamp += 1.hour
      end
      ['Berlin', 'Moscow', 'Greenland', 'Iceland'].each do |zone|
        request_params = {
          metering_point_ids: metering_point.id,
          resolution: 'month_to_days',
          timestamp: Time.find_zone(zone).local(2016,6,2)
        }

        get_with_token api_endpoint, request_params, access_token.token
        expect(response).to have_http_status(200)
        expect(json.count).to eq(30)

        timestamp = Time.find_zone(zone).local(2016,6,1)
        json.each do |item|
          expect(Time.parse(item['timestamp'])).to eq(timestamp.utc)
          expect(item['power_milliwatt']).to eq(nil)
          expect(item['energy_milliwatt_hour']).to eq(24*1300*1000)
          expect(item['energy_b_milliwatt_hour']).to eq(nil)
          timestamp += 1.day
        end
      end
    end

    it 'buzzn energy by year_to_months in summertime as admin' do
      access_token = Fabricate(:full_access_token_as_admin)
      meter = Fabricate(:easy_meter_q3d_with_metering_point)
      energy_a_milliwatt_hour = 0
      timestamp = Time.find_zone('Moscow').local(2015,1,1)
      (400).times do |i|
        Fabricate(:reading,
                  meter_id: meter.id,
                  timestamp: timestamp,
                  energy_a_milliwatt_hour: energy_a_milliwatt_hour,
                  power_a_milliwatt: 930*1000
                 )
        energy_a_milliwatt_hour += 1300*1000
        timestamp += 1.day
      end
      request_params = {
        metering_point_ids: meter.metering_points.first.id,
        resolution: 'year_to_months',
        timestamp: Time.find_zone('Moscow').local(2015,6).iso8601
      }

      get_with_token api_endpoint, request_params, access_token.token
      expect(response).to have_http_status(200)
      expect(json.count).to eq(12) # 12 month

      timestamp = Time.find_zone('Moscow').local(2015,1,1)
      json.each do |item|
        expect(Time.parse(item['timestamp']).utc).to eq(timestamp.utc)
        expect(item['power_milliwatt']).to eq(nil)
        expect(item['energy_milliwatt_hour']).to eq(1300*1000 * (Time.days_in_month(timestamp.month, timestamp.year)-1)) # -1 day becouse it is in the next day
        expect(item['energy_b_milliwatt_hour']).to eq(nil)
        timestamp += 1.month
      end
    end



    it 'buzzn energy by month_to_days in wintertime as stranger' do
      meter = Fabricate(:easy_meter_q3d_with_metering_point)
      metering_point = meter.metering_points.first
      metering_point.update(readable: 'world')
      energy_a_milliwatt_hour = 0
      timestamp = Time.find_zone('Berlin').local(2016,1,1)
      (24*32).times do |i|
        Fabricate(:reading,
                  meter_id: meter.id,
                  timestamp: timestamp,
                  energy_a_milliwatt_hour: energy_a_milliwatt_hour,
                  power_a_milliwatt: 930*1000
                 )
        energy_a_milliwatt_hour += 1300*1000
        timestamp += 1.hour
      end
      access_token  = Fabricate(:simple_access_token)
      request_params = {
        metering_point_ids: metering_point.id,
        timestamp: Time.find_zone('Berlin').local(2016,1,17).iso8601,
        resolution: 'month_to_days'
      }

      get_with_token api_endpoint, request_params, access_token.token
      expect(response).to have_http_status(200)
      expect(json.count).to eq(31)

      timestamp = Time.find_zone('Berlin').local(2016,1,1)
      json.each do |item|
        expect(Time.parse(item['timestamp']).utc).to eq(timestamp.utc)
        expect(item['power_milliwatt']).to eq(nil)
        expect(item['energy_milliwatt_hour']).to eq(24*1300*1000)
        expect(item['energy_b_milliwatt_hour']).to eq(nil)
        timestamp += 1.day
      end
    end


    it 'buzzn energy by month_to_days in summertime as admin' do
      access_token = Fabricate(:full_access_token_as_admin)
      meter = Fabricate(:easy_meter_q3d_with_metering_point)
      energy_a_milliwatt_hour = 0
      timestamp = Time.find_zone('Berlin').local(2016,6,1)
      (24*31).times do |i|
        Fabricate(:reading,
                  meter_id: meter.id,
                  timestamp: timestamp,
                  energy_a_milliwatt_hour: energy_a_milliwatt_hour,
                  power_a_milliwatt: 930*1000
                 )
        energy_a_milliwatt_hour += 1300*1000
        timestamp += 1.hour
      end
      request_params = {
        metering_point_ids: meter.metering_points.first.id,
        resolution: 'month_to_days',
        timestamp: Time.find_zone('Berlin').local(2016,6,2).iso8601
      }

      get_with_token api_endpoint, request_params, access_token.token
      expect(response).to have_http_status(200)
      expect(json.count).to eq(30)

      timestamp = Time.find_zone('Berlin').local(2016,6,1)
      json.each do |item|
        expect(Time.parse(item['timestamp']).utc).to eq(timestamp.utc)
        expect(item['power_milliwatt']).to eq(nil)
        expect(item['energy_milliwatt_hour']).to eq(24*1300*1000)
        expect(item['energy_b_milliwatt_hour']).to eq(nil)
        timestamp += 1.day
      end
    end


    it 'multiple buzzn power by hour_to_minutes as admin' do
      access_token = Fabricate(:full_access_token_as_admin)
      meter1 = Fabricate(:easy_meter_q3d_with_metering_point)
      meter2 = Fabricate(:easy_meter_q3d_with_metering_point)
      energy_a_milliwatt_hour = 0
      timestamp = Time.find_zone('Fiji').local(2015,2,1)
      (60*60).times do |i|
        Fabricate(:reading,
                  meter_id: meter1.id,
                  timestamp: timestamp,
                  energy_a_milliwatt_hour: energy_a_milliwatt_hour,
                  power_a_milliwatt: 900*1000)
        Fabricate(:reading,
                  meter_id: meter2.id,
                  timestamp: timestamp,
                  energy_a_milliwatt_hour: energy_a_milliwatt_hour,
                  power_a_milliwatt: 900*1000)
        energy_a_milliwatt_hour += 1300*1000
        timestamp += 1.seconds
      end
      request_params = {
        metering_point_ids: "#{meter1.metering_points.first.id},#{meter2.metering_points.first.id}",
        resolution: 'hour_to_minutes',
        timestamp: Time.find_zone('Fiji').local(2015,2,1, 0,30).iso8601
      }

      get_with_token api_endpoint, request_params, access_token.token
      expect(response).to have_http_status(200)
      expect(json.count).to eq(60)

      timestamp = Time.find_zone('Fiji').local(2015,2,1)
      json.each do |item|
        expect(Time.parse(item['timestamp']).utc).to eq(timestamp.utc)
        expect(item['power_milliwatt']).to eq(2*900*1000)
        expect(item['energy_milliwatt_hour']).to eq(nil)
        expect(item['energy_b_milliwatt_hour']).to eq(nil)
        timestamp += 1.minutes
      end
    end

    it 'discovergy out month_to_days as admin' do |spec|
      VCR.use_cassette("#{api_endpoint}/#{spec.metadata[:description].downcase}") do
        access_token = Fabricate(:full_access_token_as_admin)
        meter = Fabricate(:easymeter_60051599)
        metering_point = meter.metering_points.first
        request_params = {
          metering_point_ids: metering_point.id,
          resolution: 'month_to_days',
          timestamp: Time.find_zone('Berlin').local(2016,2,1).iso8601
        }

        get_with_token api_endpoint, request_params, access_token.token
        expect(response).to have_http_status(200)
        expect(json.count).to eq(29)
        expect(json[15]['power_milliwatt']).to eq(nil)
        expect(json[15]['energy_a_milliwatt_hour']).to eq(nil)
        expect(json[15]['energy_milliwatt_hour']).to eq(2146232)
        timestamp = Time.find_zone('Berlin').local(2016,2,1)
        json.each do |item|
          expect(Time.parse(item['timestamp']).utc).to eq(timestamp.utc)
          timestamp += 1.day
        end
      end
    end


    it 'Discovergy not on http error' do |spec|
      VCR.use_cassette("#{api_endpoint}/#{spec.metadata[:description].downcase}") do
        access_token = Fabricate(:full_access_token_as_admin)
        meter = Fabricate(:easymeter_60051560) # BHKW
        metering_point = meter.metering_points.first
        request_params = {
          metering_point_ids: metering_point.id,
          resolution: 'day_to_minutes',
          timestamp: Time.find_zone('Berlin').local(2016,6,6).iso8601
        }

        get_with_token api_endpoint, request_params, access_token.token
        expect(response).to have_http_status(504)

        expect(json['error']).not_to be_nil
      end
    end



    it 'Discovergy out day_to_minutes as admin' do |spec|
      VCR.use_cassette("#{api_endpoint}/#{spec.metadata[:description].downcase}") do
        access_token = Fabricate(:full_access_token_as_admin)
        meter = Fabricate(:easymeter_60051560) # BHKW
        metering_point = meter.metering_points.first
        request_params = {
          metering_point_ids: metering_point.id,
          resolution: 'day_to_minutes',
          timestamp: Time.find_zone('Berlin').local(2016,5,6).iso8601
        }

        get_with_token api_endpoint, request_params, access_token.token
        expect(response).to have_http_status(200)
        expect(json.count).to eq(96)

        expect(json[15]['power_milliwatt']).to eq(881706)
        expect(json[15]['energy_a_milliwatt_hour']).to eq(nil)
        expect(json[15]['energy_milliwatt_hour']).to eq(nil)
        timestamp = Time.find_zone('Berlin').local(2016,5,6)
        json.each do |item|
          expect(Time.parse(item['timestamp']).utc).to eq(timestamp.utc)
          timestamp += 15.minute
        end
      end
    end


    it 'Discovergy in two-way meter day_to_minutes as admin' do |spec|
      VCR.use_cassette("#{api_endpoint}/#{spec.metadata[:description].downcase}") do
        access_token = Fabricate(:full_access_token_as_admin)
        meter = Fabricate(:easymeter_60139082)
        input_metering_point  = meter.metering_points.inputs.first
        output_metering_point = meter.metering_points.outputs.first
        request_params = {
          metering_point_ids: input_metering_point.id,
          resolution: 'day_to_minutes',
          timestamp: Time.find_zone('Berlin').local(2016,4,6).iso8601
        }

        get_with_token api_endpoint, request_params, access_token.token
        expect(response).to have_http_status(200)
        expect(json.count).to eq(96)

        expect(json[0]['power_milliwatt']).to eq(10304)
        timestamp = Time.find_zone('Berlin').local(2016,4,6)
        json.each do |item|
          expect(Time.parse(item['timestamp']).utc).to eq(timestamp.utc)
          timestamp += 15.minute
        end
      end
    end


    it 'Discovergy out two-way meter day_to_minutes as admin' do |spec|
      VCR.use_cassette("#{api_endpoint}/#{spec.metadata[:description].downcase}") do
        access_token = Fabricate(:full_access_token_as_admin)
        meter = Fabricate(:easymeter_60139082)
        input_metering_point  = meter.metering_points.inputs.first
        output_metering_point = meter.metering_points.outputs.first
        request_params = {
          metering_point_ids: output_metering_point.id,
          resolution: 'day_to_minutes',
          timestamp: Time.find_zone('Berlin').local(2016,4,6).iso8601
        }

        get_with_token api_endpoint, request_params, access_token.token
        expect(response).to have_http_status(200)
        expect(json.count).to eq(96)

        expect(json[0]['power_milliwatt']).to eq(109988)
        timestamp = Time.find_zone('Berlin').local(2016,4,6)
        json.each do |item|
          expect(Time.parse(item['timestamp']).utc).to eq(timestamp.utc)
          timestamp += 15.minute
        end
      end
    end



    it 'Multiple Discovergy day_to_minutes as admin' do |spec|
      VCR.use_cassette("#{api_endpoint}/#{spec.metadata[:description].downcase}") do
        access_token = Fabricate(:full_access_token_as_admin)
        easymeter_60051599 = Fabricate(:easymeter_60051599) # PV
        easymeter_60051560 = Fabricate(:easymeter_60051560) # BHKW
        mp_z2 = easymeter_60051599.metering_points.outputs.first
        mp_z4 = easymeter_60051560.metering_points.outputs.first
        request_params = {
          metering_point_ids: "#{mp_z4.id},#{mp_z2.id}",
          resolution: 'day_to_minutes',
          timestamp: Time.find_zone('Berlin').local(2016,4,6).iso8601
        }

        get_with_token api_endpoint, request_params, access_token.token
        expect(response).to have_http_status(200)
        expect(json.count).to eq(96)

        expect(json[50]['power_milliwatt']).to eq(907367 + 1507120)
        timestamp = Time.find_zone('Berlin').local(2016,4,6)
        json.each do |item|
          expect(Time.parse(item['timestamp']).utc).to eq(timestamp.utc)
          timestamp += 15.minute
        end
      end
    end


    it 'Virtual past month_to_days as admin' do |spec|
      VCR.use_cassette("#{api_endpoint}/#{spec.metadata[:description].downcase}") do
        access_token = Fabricate(:full_access_token_as_admin)
        virtual_metering_point = Fabricate(:mp_forstenried_erzeugung) # discovergy Virtual metering_point
        single_energy_values = []
        virtual_metering_point.formula_parts.each do |formula_part|
          metering_point = MeteringPoint.find(formula_part.operand_id)
          request_params = {
            metering_point_ids: metering_point.id,
            resolution: 'month_to_days',
            timestamp: Time.find_zone('Berlin').local(2016,4,6)
          }
          get_with_token api_endpoint, request_params, access_token.token
          single_energy_values << json.first['energy_milliwatt_hour']
        end
        request_params = {
          metering_point_ids: virtual_metering_point.id,
          resolution: 'month_to_days',
          timestamp: Time.find_zone('Berlin').local(2016,4,6).iso8601
        }
        
        get_with_token "/api/v1/aggregates/past", request_params, access_token.token

        sum_value = single_energy_values[0] + single_energy_values[1] - single_energy_values[2] # last single_energy_value is a negativ formulapart metering_point
        expect(json.first['energy_milliwatt_hour']).to eq(sum_value)
      end
    end

  end







  describe '/present' do
    api_endpoint = api_version + api_controller + '/present'

    it 'Does aggregate Virtual metering_points present as manager' do |spec|
      VCR.use_cassette("#{api_endpoint}/#{spec.metadata[:description].downcase}") do
        access_token = Fabricate(:full_access_token_as_admin)
        virtual_metering_point = Fabricate(:mp_forstenried_erzeugung) # discovergy Virtual metering_point
        request_params = {
          metering_point_ids: virtual_metering_point.id,
          timestamp: Time.find_zone('Berlin').local(2016,4,6).iso8601
        }
        get_with_token api_endpoint, request_params, access_token.token
        sum_value = 0
        json['readings'].each do |item|
          sum_value += item['data']['power_milliwatt']
        end
        expect(json['power_milliwatt']).to eq(sum_value)
      end
    end


    it 'power readable by world which belongs to a group not readable by world without token' do |spec|
      VCR.use_cassette("#{api_endpoint}/#{spec.metadata[:description].downcase}") do
        meter                   = Fabricate(:easymeter_60139082)
        metering_point          = meter.metering_points.inputs.first
        metering_point.readable = 'world'
        metering_point.save
        group                   = Fabricate(:group_readable_by_community)
        group.metering_points << metering_point
        request_params = {
          metering_point_ids: metering_point.id
        }
        get_without_token '/api/v1/aggregates/present', request_params
        expect(response).to have_http_status(200)
      end
    end

    it 'power not readable by world which belongs to a group readable by world without token' do |spec|
      VCR.use_cassette("#{api_endpoint}/#{spec.metadata[:description].downcase}") do
        meter                   = Fabricate(:easymeter_60139082)
        metering_point          = meter.metering_points.inputs.first
        metering_point.readable = 'community'
        metering_point.save
        group                   = Fabricate(:group)
        group.metering_points << metering_point
        request_params = {
          metering_point_ids: metering_point.id
        }
        get_without_token '/api/v1/aggregates/present', request_params
        expect(response).to have_http_status(200)
      end
    end

    it 'power not readable by world which belongs to a group not readable by world without token' do |spec|
      VCR.use_cassette("#{api_endpoint}/#{spec.metadata[:description].downcase}") do
        meter                   = Fabricate(:easymeter_60139082)
        metering_point          = meter.metering_points.inputs.first
        metering_point.readable = 'community'
        metering_point.save
        group                   = Fabricate(:group_readable_by_community)
        group.metering_points << metering_point
        request_params = {
          metering_point_ids: metering_point.id
        }
        get_without_token '/api/v1/aggregates/present', request_params
        expect(response).to have_http_status(403)
      end
    end


    it 'Discovergy power out as admin' do |spec|
      VCR.use_cassette("#{api_endpoint}/#{spec.metadata[:description].downcase}") do
        access_token = Fabricate(:full_access_token_as_admin)
        meter = Fabricate(:easymeter_60139082) # in_out meter
        input_metering_point  = meter.metering_points.inputs.first
        output_metering_point = meter.metering_points.outputs.first
        Timecop.freeze(Time.find_zone('Berlin').local(2016,2,1, 1,30,1)) # 6*15 minutes and 1 seconds
        request_params = { metering_point_ids: input_metering_point.id }
        get_with_token api_endpoint, request_params, access_token.token
        expect(response).to have_http_status(200)
        expect(json['readings'].count).to eq(1)
        expect(json['power_milliwatt']).to eq(0)
        request_params = { metering_point_ids: output_metering_point.id }
        get_with_token api_endpoint, request_params, access_token.token
        expect(response).to have_http_status(200)
        expect(json['readings'].count).to eq(1)
        expect(json['power_milliwatt']).to eq(113000)
        Timecop.return
      end
    end


    it 'multiple buzzn as admin' do
      access_token = Fabricate(:full_access_token_as_admin)
      meter1 = Fabricate(:easy_meter_q3d_with_metering_point)
      meter2 = Fabricate(:easy_meter_q3d_with_metering_point)
      energy_a_milliwatt_hour = 0
      timestamp = Time.new(2016,2,1)
      (60*60).times do |i|
        Fabricate(:reading,
                  meter_id: meter1.id,
                  timestamp: timestamp,
                  energy_a_milliwatt_hour: energy_a_milliwatt_hour,
                  power_a_milliwatt: 900*1000
                 )
        Fabricate(:reading,
                  meter_id: meter2.id,
                  timestamp: timestamp,
                  energy_a_milliwatt_hour: energy_a_milliwatt_hour,
                  power_a_milliwatt: 800*1000
                 )
        energy_a_milliwatt_hour += 1300*1000
        timestamp += 1.seconds
      end
      Timecop.freeze(Time.local(2016,2,1, 1,30)) # 6*15 minutes
      request_params = {
        metering_point_ids: "#{meter1.metering_points.first.id},#{meter2.metering_points.first.id}"
      }
      get_with_token api_endpoint, request_params, access_token.token
      expect(response).to have_http_status(200)
      expect(json['readings'].count).to eq(2)
      expect(json['power_milliwatt']).to eq((900*1000)+(800*1000))
      Timecop.return
    end


    it 'buzzn in and out as admin' do
      access_token = Fabricate(:full_access_token_as_admin)
      meter = Fabricate(:easy_meter_q3d_with_in_out_metering_point)
      metering_point_out  = meter.metering_points.outputs.first
      metering_point_in   = meter.metering_points.inputs.first
      energy_a_milliwatt_hour = 0
      energy_b_milliwatt_hour = 1000
      timestamp = Time.new(2016,2,1)
      (60*60).times do |i|
        Fabricate(:reading,
                  meter_id: meter.id,
                  timestamp: timestamp,
                  energy_a_milliwatt_hour: energy_a_milliwatt_hour,
                  power_a_milliwatt: 900*1000,
                  energy_b_milliwatt_hour: energy_b_milliwatt_hour,
                  power_b_milliwatt: 70*1000)
      end
      Timecop.freeze(Time.local(2016,2,1, 1,30)) # 6*15 minutes
      request_params = { metering_point_ids: metering_point_out.id }
      get_with_token api_endpoint, request_params, access_token.token
      expect(response).to have_http_status(200)
      expect(json['readings'].count).to eq(1)
      expect(json['power_milliwatt']).to eq(70*1000)
      request_params = { metering_point_ids: metering_point_in.id }
      get_with_token api_endpoint, request_params, access_token.token
      expect(response).to have_http_status(200)
      expect(json['readings'].count).to eq(1)
      expect(json['power_milliwatt']).to eq(900*1000)
      Timecop.return
    end


    it 'discovergy handles empty readings as admin' do |spec|
      VCR.use_cassette("#{api_endpoint}/#{spec.metadata[:description]}") do
        access_token = Fabricate(:full_access_token_as_admin)
        meter = Fabricate(:easymeter_fixed_serial) # in_out meter
        input_metering_point  = meter.metering_points.inputs.first
        output_metering_point = meter.metering_points.outputs.first
        request_params = {
          metering_point_ids: input_metering_point.id
        }
        get_with_token api_endpoint, request_params, access_token.token
        expect(response).to have_http_status(200)
        expect(json['readings'].count).to eq(0)
        expect(json['power_milliwatt']).to eq(0)
        expect(json['timestamp']).to eq("0000-01-01T00:00:00.000Z")
        request_params = {
          metering_point_ids: output_metering_point.id
        }
        get_with_token "/api/v1/aggregates/present", request_params, access_token.token
        expect(response).to have_http_status(200)
        expect(json['readings'].count).to eq(0)
        expect(json['power_milliwatt']).to eq(0)
        expect(json['timestamp']).to eq("0000-01-01T00:00:00.000Z")
      end
    end

    it 'slp as admin' do
      access_token = Fabricate(:full_access_token_as_admin)
      metering_point = Fabricate(:metering_point)

      energy_a_milliwatt_hour = 0
      timestamp = Time.find_zone('Berlin').local(2016,2,1)
      (24*4).times do |i|
        Fabricate(:reading,
                  source: 'slp',
                  timestamp: timestamp,
                  energy_a_milliwatt_hour: energy_a_milliwatt_hour,
                  power_a_milliwatt: 930*1000+i
                 )
        energy_a_milliwatt_hour += 1300*1000
        timestamp += 15.minutes
      end

      Timecop.freeze(Time.find_zone('Berlin').local(2016,2,1, 1,30,1)) # 6*15 minutes and 1 seconds
      request_params = {
        metering_point_ids: metering_point.id
      }
      get_with_token api_endpoint, request_params, access_token.token
      expect(response).to have_http_status(200)
      expect(json['readings'].count).to eq(1)
      expect(json['power_milliwatt']).to eq(930*1000 + 7)
      Timecop.return
    end


    it 'slp with forecast_kwh_pa as admin' do
      access_token = Fabricate(:full_access_token_as_admin)
      metering_point = Fabricate(:metering_point, forecast_kwh_pa: 3000)
      energy_a_milliwatt_hour = 0
      timestamp = Time.find_zone('Berlin').local(2016,2,1)
      (24*4).times do |i|
        Fabricate(:reading,
                  source: 'slp',
                  timestamp: timestamp.iso8601,
                  energy_a_milliwatt_hour: energy_a_milliwatt_hour,
                  power_a_milliwatt: 900*1000
                 )
        energy_a_milliwatt_hour += 1300*1000
        timestamp += 15.minutes
      end
      Timecop.freeze(Time.find_zone('Berlin').local(2016,2,1, 1,30,55)) # 6*15 minutes and 55 seconds
      request_params = {
        metering_point_ids: metering_point.id
      }
      get_with_token api_endpoint, request_params, access_token.token
      expect(response).to have_http_status(200)
      expect(json['readings'].count).to eq(1)
      expect(json['power_milliwatt']).to eq(900*1000*3)
      Timecop.return
    end


    it 'multiple slp with forecast_kwh_pa as admin' do
      access_token = Fabricate(:full_access_token_as_admin)
      metering_point1 = Fabricate(:metering_point, forecast_kwh_pa: 3000)
      metering_point2 = Fabricate(:metering_point, forecast_kwh_pa: 8000)
      energy_a_milliwatt_hour = 0
      timestamp = Time.find_zone('Berlin').local(2016,2,1)
      (24*4).times do |i|
        Fabricate(:reading,
                  source: 'slp',
                  timestamp: timestamp,
                  energy_a_milliwatt_hour: energy_a_milliwatt_hour,
                  power_a_milliwatt: 900*1000
                 )
        energy_a_milliwatt_hour += 1300*1000
        timestamp += 15.minutes
      end
      Timecop.freeze( Time.find_zone('Berlin').local(2016,2,1, 1,30,1) ) # 6*15 minutes and 1 seconds
      request_params = {
        metering_point_ids: "#{metering_point1.id},#{metering_point2.id}"
      }
      get_with_token api_endpoint, request_params, access_token.token
      expect(response).to have_http_status(200)
      expect(json['readings'].count).to eq(2)
      expect(json['power_milliwatt']).to eq(900*1000*(3+8))
      Timecop.return
    end



  end

end
