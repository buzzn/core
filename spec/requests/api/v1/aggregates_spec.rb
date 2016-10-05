describe "Aggregates API" do

  before do
    Fabricate(:metering_point_operator, name: 'buzzn Metering')
    Fabricate(:metering_point_operator, name: 'Discovergy')
    Fabricate(:metering_point_operator, name: 'MySmartGrid')
  end





  xit 'does not aggregate to many metering_points at once as admin' do
  end

  xit 'does not aggregate many metering_points with different type as admin' do
  end







  #   _____ _      _____
  #  / ____| |    |  __ \
  # | (___ | |    | |__) |
  #  \___ \| |    |  ___/
  #  ____) | |____| |
  # |_____/|______|_|


  describe 'SLP' do

    it 'does aggregate slp past energy by year_to_months as admin in summertime' do
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

      get_with_token "/api/v1/aggregates/past", request_params, access_token.token

      expect(response).to have_http_status(200)
      expect(json.count).to eq(12) # 12 month

      timestamp = Time.find_zone('Moscow').local(2015,1,1)

      json.each do |item|
        expect(Time.parse(item['timestamp']).utc).to eq(timestamp.utc)
        expect(item['energy_milliwatt_hour']).to eq(1300*1000 * (Time.days_in_month(timestamp.month, timestamp.year)-1)) # -1 day becouse it is in the next day
        timestamp += 1.month
      end
    end


    it 'does aggregate slp past energy by month_to_days as stranger in wintertime' do
      metering_point = Fabricate(:metering_point, readable: 'world')

      energy_a_milliwatt_hour = 0
      timestamp = Time.find_zone('Berlin').local(2016,1,1)
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

      access_token  = Fabricate(:simple_access_token)


      request_params = {
        metering_point_ids: metering_point.id,
        timestamp: Time.find_zone('Berlin').local(2016,1,17),
        resolution: 'month_to_days'
      }

      get_with_token "/api/v1/aggregates/past", request_params, access_token.token

      expect(response).to have_http_status(200)
      expect(json.count).to eq(30)
      timestamp = Time.find_zone('Berlin').local(2016,1,1)
      json.each do |item|
        expect(Time.parse(item['timestamp']).utc).to eq(timestamp.utc)
        expect(item['power_milliwatt']).to eq(nil)
        expect(item['energy_milliwatt_hour']).to eq(23*1300*1000)
        expect(item['energy_b_milliwatt_hour']).to eq(nil)
        timestamp += 1.day
      end
    end



    it 'does aggregate slp energy past by month_to_days as admin in summertime ' do
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


      request_params = {
        metering_point_ids: metering_point.id,
        resolution: 'month_to_days',
        timestamp: Time.find_zone('Berlin').local(2016,6,2)
      }

      get_with_token "/api/v1/aggregates/past", request_params, access_token.token

      expect(response).to have_http_status(200)
      expect(json.count).to eq(30)
      timestamp = Time.find_zone('Berlin').local(2016,6,1)
      json.each do |item|
        expect(Time.parse(item['timestamp']).utc).to eq(timestamp.utc)
        expect(item['power_milliwatt']).to eq(nil)
        expect(item['energy_milliwatt_hour']).to eq(23*1300*1000)
        expect(item['energy_b_milliwatt_hour']).to eq(nil)
        timestamp += 1.day
      end
    end





    it 'does aggregate slp power past by day_to_minutes as admin' do
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

      get_with_token "/api/v1/aggregates/past", request_params, access_token.token

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




    it 'does aggregate slp power past by hour_to_minutes as admin' do
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

      get_with_token "/api/v1/aggregates/past", request_params, access_token.token

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


    it 'does not aggregate multiple metering_points power past by hour_to_minutes with differend data_sources as admin' do
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

      get_with_token "/api/v1/aggregates/past", request_params, access_token.token

      expect(response).to have_http_status(406)
    end




    it 'does not aggregate more than 5 metering_points as admin' do
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

      get_with_token "/api/v1/aggregates/past", request_params, access_token.token

      expect(response).to have_http_status(413)
    end





    it 'does aggregate multiple slp power past by hour_to_minutes as admin' do
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

      get_with_token "/api/v1/aggregates/past", request_params, access_token.token

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




    it 'does aggregate multiple slp power past by hour_to_minutes with forecast_kwh_pa as admin' do
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
        timestamp: Time.find_zone('Berlin').local(2015,2,1,0,30)
      }

      get_with_token "/api/v1/aggregates/past", request_params, access_token.token

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


    #
    # Last Reading
    #
    it 'does aggregate slp present as admin' do
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

      get_with_token "/api/v1/aggregates/present", request_params, access_token.token

      expect(response).to have_http_status(200)
      expect(json['readings'].count).to eq(1)
      expect(json['power_milliwatt']).to eq(930*1000 + 7)
      Timecop.return
    end


    it 'does aggregate slp present with forecast_kwh_pa as admin' do
      access_token = Fabricate(:full_access_token_as_admin)

      metering_point = Fabricate(:metering_point, forecast_kwh_pa: 3000)
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

      Timecop.freeze(Time.find_zone('Berlin').local(2016,2,1, 1,30,55)) # 6*15 minutes and 55 seconds
      request_params = {
        metering_point_ids: metering_point.id
      }

      get_with_token "/api/v1/aggregates/present", request_params, access_token.token

      expect(response).to have_http_status(200)
      expect(json['readings'].count).to eq(1)
      expect(json['power_milliwatt']).to eq(900*1000*3)
      Timecop.return
    end





    it 'does aggregate multiple slp presents with forecast_kwh_pa as admin' do
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

      get_with_token "/api/v1/aggregates/present", request_params, access_token.token
      expect(response).to have_http_status(200)
      expect(json['readings'].count).to eq(2)
      expect(json['power_milliwatt']).to eq(900*1000*(3+8))
      Timecop.return
    end

    it 'does aggregate slp past energy by year_to_months as admin in summertime just until now' do
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

      get_with_token "/api/v1/aggregates/past", request_params, access_token.token

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

    it 'does aggregate slp power past by day_to_minutes as admin just until now' do
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

      get_with_token "/api/v1/aggregates/past", request_params, access_token.token

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

    it 'does aggregate slp energy past by month_to_days as admin in summertime just until now' do
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
        timestamp: Time.find_zone('Berlin').local(2016,6,2)
      }

      get_with_token "/api/v1/aggregates/past", request_params, access_token.token

      expect(response).to have_http_status(200)
      expect(json.count).to eq(13)
      timestamp = Time.find_zone('Berlin').local(2016,6,1)
      i = 1
      json.each do |item|
        expect(Time.parse(item['timestamp']).utc).to eq(timestamp.utc)
        expect(item['power_milliwatt']).to eq(nil)
        expect(item['energy_milliwatt_hour']).to eq(23*1300*1000) if i < 13
        expect(item['energy_b_milliwatt_hour']).to eq(nil)
        timestamp += 1.day
        i+=1
      end
      Timecop.return
    end

  end

  
  #   _____ ______ _____
  #  / ____|  ____|  __ \
  # | (___ | |__  | |__) |
  #  \___ \|  __| |  ___/
  #  ____) | |____| |
  # |_____/|______|_|


  describe 'SEP' do
  
    it 'does aggregate sep bhkw past energy by year_to_months as admin in summertime' do
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


      get_with_token "/api/v1/aggregates/past", request_params, access_token.token

      expect(response).to have_http_status(200)
      expect(json.count).to eq(12) # 12 month

      timestamp = Time.find_zone('Moscow').local(2015,1,1)

      json.each do |item|
        expect(Time.parse(item['timestamp']).utc).to eq(timestamp.utc)
        expect(item['energy_milliwatt_hour']).to eq(1300*1000 * (Time.days_in_month(timestamp.month, timestamp.year)-1)) # -1 day becouse it is in the next day
        timestamp += 1.month
      end
    end

    it 'does aggregate sep bhkw energy past by month_to_days as admin in summertime ' do
      access_token = Fabricate(:full_access_token_as_admin)
      metering_point = Fabricate(:metering_point, mode: 'out')

      energy_a_milliwatt_hour = 0
      timestamp = Time.find_zone('Berlin').local(2016,6,1)
      (24*30).times do |i|
        Fabricate(:reading,
                  source: 'sep_bhkw',
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
        timestamp: Time.find_zone('Berlin').local(2016,6,2)
      }

      get_with_token "/api/v1/aggregates/past", request_params, access_token.token

      expect(response).to have_http_status(200)
      expect(json.count).to eq(30)
      timestamp = Time.find_zone('Berlin').local(2016,6,1)
      json.each do |item|
        expect(Time.parse(item['timestamp']).utc).to eq(timestamp.utc)
        expect(item['power_milliwatt']).to eq(nil)
        expect(item['energy_milliwatt_hour']).to eq(23*1300*1000)
        expect(item['energy_b_milliwatt_hour']).to eq(nil)
        timestamp += 1.day
      end
    end
    
  end



  #  _                                    _____ _____
  # | |                             /\   |  __ \_   _|
  # | |__  _   _ _________ __      /  \  | |__) || |
  # | '_ \| | | |_  /_  / '_ \    / /\ \ |  ___/ | |
  # | |_) | |_| |/ / / /| | | |  / ____ \| |    _| |_
  # |_.__/ \__,_/___/___|_| |_| /_/    \_\_|   |_____|


  describe 'buzzn API' do

    it 'handles empty readings' do
      access_token = Fabricate(:full_access_token_as_admin)
      meter = Fabricate(:easymeter_fixed_serial) # in_out meter
      input_metering_point  = meter.metering_points.inputs.first
      output_metering_point = meter.metering_points.outputs.first

      request_params = {
        metering_point_ids: input_metering_point.id
      }

      get_with_token "/api/v1/aggregates/present", request_params, access_token.token

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



    it 'does aggregate buzzn energy past by year_to_months as admin in summertime' do
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

      get_with_token "/api/v1/aggregates/past", request_params, access_token.token

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

    it 'does aggregate buzzn energy past by month_to_days as stranger in wintertime' do

      meter = Fabricate(:easy_meter_q3d_with_metering_point)
      metering_point = meter.metering_points.first
      metering_point.update(readable: 'world')

      energy_a_milliwatt_hour = 0
      timestamp = Time.find_zone('Berlin').local(2016,1,1)
      (24*30).times do |i|
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
        timestamp: Time.find_zone('Berlin').local(2016,1,17),
        resolution: 'month_to_days'
      }


      get_with_token "/api/v1/aggregates/past", request_params, access_token.token

      expect(response).to have_http_status(200)
      expect(json.count).to eq(30)
      timestamp = Time.find_zone('Berlin').local(2016,1,1)
      json.each do |item|
        expect(Time.parse(item['timestamp']).utc).to eq(timestamp.utc)
        expect(item['power_milliwatt']).to eq(nil)
        expect(item['energy_milliwatt_hour']).to eq(23*1300*1000)
        expect(item['energy_b_milliwatt_hour']).to eq(nil)
        timestamp += 1.day
      end
    end



    it 'does aggregate buzzn energy past by month_to_days as admin in summertime ' do
      access_token = Fabricate(:full_access_token_as_admin)

      meter = Fabricate(:easy_meter_q3d_with_metering_point)

      energy_a_milliwatt_hour = 0
      timestamp = Time.find_zone('Berlin').local(2016,6,1)
      (24*30).times do |i|
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
        timestamp: Time.find_zone('Berlin').local(2016,6,2)
      }

      get_with_token "/api/v1/aggregates/past", request_params, access_token.token

      expect(response).to have_http_status(200)
      expect(json.count).to eq(30)
      timestamp = Time.find_zone('Berlin').local(2016,6,1)
      json.each do |item|
        expect(Time.parse(item['timestamp']).utc).to eq(timestamp.utc)
        expect(item['power_milliwatt']).to eq(nil)
        expect(item['energy_milliwatt_hour']).to eq(23*1300*1000)
        expect(item['energy_b_milliwatt_hour']).to eq(nil)
        timestamp += 1.day
      end
    end



    it 'does aggregate multiple buzzn power past by hour_to_minutes as admin' do
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
                  power_a_milliwatt: 900*1000
                 )

        Fabricate(:reading,
                  meter_id: meter2.id,
                  timestamp: timestamp,
                  energy_a_milliwatt_hour: energy_a_milliwatt_hour,
                  power_a_milliwatt: 900*1000
                 )

        energy_a_milliwatt_hour += 1300*1000
        timestamp += 1.seconds
      end


      request_params = {
        metering_point_ids: "#{meter1.metering_points.first.id},#{meter2.metering_points.first.id}",
        resolution: 'hour_to_minutes',
        timestamp: Time.find_zone('Fiji').local(2015,2,1, 0,30)
      }

      get_with_token "/api/v1/aggregates/past", request_params, access_token.token

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



    it 'does aggregate in and out metering_point buzzn present as admin' do
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
                  power_b_milliwatt: 70*1000
                 )
      end

      Timecop.freeze(Time.local(2016,2,1, 1,30)) # 6*15 minutes


      request_params = {
        metering_point_ids: metering_point_out.id
      }
      get_with_token "/api/v1/aggregates/present", request_params, access_token.token
      expect(response).to have_http_status(200)
      expect(json['readings'].count).to eq(1)
      expect(json['power_milliwatt']).to eq(70*1000)



      request_params = {
        metering_point_ids: metering_point_in.id
      }
      get_with_token "/api/v1/aggregates/present", request_params, access_token.token
      expect(response).to have_http_status(200)
      expect(json['readings'].count).to eq(1)
      expect(json['power_milliwatt']).to eq(900*1000)


      Timecop.return
    end




    it 'does aggregate multiple buzzn present as admin' do
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

      get_with_token "/api/v1/aggregates/present", request_params, access_token.token
      expect(response).to have_http_status(200)
      expect(json['readings'].count).to eq(2)
      expect(json['power_milliwatt']).to eq((900*1000)+(800*1000))
      Timecop.return
    end

  end



  #   _____  _
  #  |  __ \(_)
  #  | |  | |_ ___  ___ _____   _____ _ __ __ _ _   _
  #  | |  | | / __|/ __/ _ \ \ / / _ \ '__/ _` | | | |
  #  | |__| | \__ \ (_| (_) \ V /  __/ | | (_| | |_| |
  #  |_____/|_|___/\___\___/ \_/ \___|_|  \__, |\__, |
  #                                        __/ | __/ |
  #                                       |___/ |___/


  describe 'Discovergy' do

    it 'does aggregate Discovergy past month_to_days for out metering_point as admin' do
      access_token = Fabricate(:full_access_token_as_admin)

      meter = Fabricate(:easymeter_60051599)
      metering_point = meter.metering_points.first

      request_params = {
        metering_point_ids: metering_point.id,
        resolution: 'month_to_days',
        timestamp: Time.find_zone('Berlin').local(2016,2,1)
      }

      get_with_token "/api/v1/aggregates/past", request_params, access_token.token

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



    it 'does not aggregate on http error with discovergy' do
      access_token = Fabricate(:full_access_token_as_admin)
      meter = Fabricate(:easymeter_60051560) # BHKW
      metering_point = meter.metering_points.first

      request_params = {
        metering_point_ids: metering_point.id,
        resolution: 'day_to_minutes',
        timestamp: Time.find_zone('Berlin').local(2016,6,6)
      }

      get_with_token "/api/v1/aggregates/past", request_params, access_token.token

      expect(response).to have_http_status(503)
      expect(json['error']).not_to be_nil
    end



    it 'does aggregate Discovergy past day_to_minutes for out metering_point as admin' do
      access_token = Fabricate(:full_access_token_as_admin)
      meter = Fabricate(:easymeter_60051560) # BHKW
      metering_point = meter.metering_points.first

      request_params = {
        metering_point_ids: metering_point.id,
        resolution: 'day_to_minutes',
        timestamp: Time.find_zone('Berlin').local(2016,5,6)
      }

      get_with_token "/api/v1/aggregates/past", request_params, access_token.token

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



    it 'does aggregate Discovergy past day_to_minutes for in metering_point on a two-way meter as admin' do
      access_token = Fabricate(:full_access_token_as_admin)

      meter = Fabricate(:easymeter_60139082)
      input_metering_point  = meter.metering_points.inputs.first
      output_metering_point = meter.metering_points.outputs.first


      request_params = {
        metering_point_ids: input_metering_point.id,
        resolution: 'day_to_minutes',
        timestamp: Time.find_zone('Berlin').local(2016,4,6)
      }

      get_with_token "/api/v1/aggregates/past", request_params, access_token.token

      expect(response).to have_http_status(200)
      expect(json.count).to eq(96)

      expect(json[0]['power_milliwatt']).to eq(10304)

      timestamp = Time.find_zone('Berlin').local(2016,4,6)
      json.each do |item|
        expect(Time.parse(item['timestamp']).utc).to eq(timestamp.utc)
        timestamp += 15.minute
      end
    end



    it 'does aggregate Discovergy past day_to_minutes for out metering_point on a two-way meter as admin' do
      access_token = Fabricate(:full_access_token_as_admin)

      meter = Fabricate(:easymeter_60139082)
      input_metering_point  = meter.metering_points.inputs.first
      output_metering_point = meter.metering_points.outputs.first

      request_params = {
        metering_point_ids: output_metering_point.id,
        resolution: 'day_to_minutes',
        timestamp: Time.find_zone('Berlin').local(2016,4,6)
      }

      get_with_token "/api/v1/aggregates/past", request_params, access_token.token

      expect(response).to have_http_status(200)
      expect(json.count).to eq(96)

      expect(json[0]['power_milliwatt']).to eq(109988)

      timestamp = Time.find_zone('Berlin').local(2016,4,6)
      json.each do |item|
        expect(Time.parse(item['timestamp']).utc).to eq(timestamp.utc)
        timestamp += 15.minute
      end
    end







    it 'does aggregate multiple Discovergy past day_to_minutes metering_point as admin' do
      access_token = Fabricate(:full_access_token_as_admin)


      easymeter_60051599 = Fabricate(:easymeter_60051599) # PV
      easymeter_60051560 = Fabricate(:easymeter_60051560) # BHKW

      mp_z2 = easymeter_60051599.metering_points.outputs.first
      mp_z4 = easymeter_60051560.metering_points.outputs.first



      request_params = {
        metering_point_ids: mp_z2.id,
        resolution: 'day_to_minutes',
        timestamp: Time.find_zone('Berlin').local(2016,4,6)
      }

      get_with_token "/api/v1/aggregates/past", request_params, access_token.token

      expect(response).to have_http_status(200)
      expect(json.count).to eq(96)
      expect(json[50]['power_milliwatt']).to eq(1507120)





      request_params = {
        metering_point_ids: mp_z4.id,
        resolution: 'day_to_minutes',
        timestamp: Time.find_zone('Berlin').local(2016,4,6)
      }

      get_with_token "/api/v1/aggregates/past", request_params, access_token.token

      expect(response).to have_http_status(200)
      expect(json.count).to eq(96)
      expect(json[50]['power_milliwatt']).to eq(907367)




      request_params = {
        metering_point_ids: "#{mp_z2.id},#{mp_z4.id}",
        resolution: 'day_to_minutes',
        timestamp: Time.find_zone('Berlin').local(2016,4,6)
      }

      get_with_token "/api/v1/aggregates/past", request_params, access_token.token

      expect(response).to have_http_status(200)
      expect(json.count).to eq(96)
      expect(json[50]['power_milliwatt']).to eq(907367 + 1507120)



      timestamp = Time.find_zone('Berlin').local(2016,4,6)
      json.each do |item|
        expect(Time.parse(item['timestamp']).utc).to eq(timestamp.utc)
        timestamp += 15.minute
      end
    end


    it 'does aggregate Discovergy power present for out metering_point as admin' do
      access_token = Fabricate(:full_access_token_as_admin)
      meter = Fabricate(:easymeter_60139082) # in_out meter
      input_metering_point  = meter.metering_points.inputs.first
      output_metering_point = meter.metering_points.outputs.first

      Timecop.freeze(Time.find_zone('Berlin').local(2016,2,1, 1,30,1)) # 6*15 minutes and 1 seconds


      request_params = {
        metering_point_ids: input_metering_point.id
      }

      get_with_token "/api/v1/aggregates/present", request_params, access_token.token

      expect(response).to have_http_status(200)
      expect(json['readings'].count).to eq(1)
      expect(json['power_milliwatt']).to eq(0)



      request_params = {
        metering_point_ids: output_metering_point.id
      }

      get_with_token "/api/v1/aggregates/present", request_params, access_token.token

      expect(response).to have_http_status(200)
      expect(json['readings'].count).to eq(1)
      expect(json['power_milliwatt']).to eq(6412000)
      Timecop.return
    end

    it 'return data for metering point readable by world which belongs to a group not readable by world without token' do
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

    it 'return data for metering point not readable by world which belongs to a group readable by world without token' do
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

    it 'does not return data for metering point not readable by world which belongs to a group not readable by world without token' do
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




    #
    # Virtual
    #


    it 'does aggregate Virtual metering_points past month_to_days as admin' do
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
        get_with_token "/api/v1/aggregates/past", request_params, access_token.token
        single_energy_values << json.first['energy_milliwatt_hour']
      end

      request_params = {
        metering_point_ids: virtual_metering_point.id,
        resolution: 'month_to_days',
        timestamp: Time.find_zone('Berlin').local(2016,4,6)
      }

      get_with_token "/api/v1/aggregates/past", request_params, access_token.token
      sum_value = single_energy_values[0] + single_energy_values[1] - single_energy_values[2] # last single_energy_value is a negativ formulapart metering_point
      expect(json.first['energy_milliwatt_hour']).to eq(sum_value)
    end



    it 'does aggregate Virtual metering_points present as manager' do
      access_token = Fabricate(:full_access_token_as_admin)

      virtual_metering_point = Fabricate(:mp_forstenried_erzeugung) # discovergy Virtual metering_point

      request_params = {
        metering_point_ids: virtual_metering_point.id,
        timestamp: Time.find_zone('Berlin').local(2016,4,6)
      }

      get_with_token "/api/v1/aggregates/present", request_params, access_token.token

      sum_value = 0
      json['readings'].each do |item|
        sum_value += item['data']['power_milliwatt']
      end

      expect(json['power_milliwatt']).to eq(sum_value)
    end

  end

end
