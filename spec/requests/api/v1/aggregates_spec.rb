describe "Aggregates API" do

  before(:all) do
    Fabricate(:metering_point_operator, name: 'buzzn Metering')
    Fabricate(:metering_point_operator, name: 'Discovergy')
    Fabricate(:metering_point_operator, name: 'MySmartGrid')
  end



  #   _____ _      _____
  #  / ____| |    |  __ \
  # | (___ | |    | |__) |
  #  \___ \| |    |  ___/
  #  ____) | |____| |
  # |_____/|______|_|
  #

  it 'does aggregate slp past energy by year_to_months as admin in sommertime' do
    access_token = Fabricate(:admin_access_token)
    metering_point = Fabricate(:metering_point)

    energy_a_milliwatt_hour = 0
    timestamp = Time.find_zone('Moscow').local(2015,1,1)
    (400).times do |i|
      Fabricate(:reading,
        source: 'slp',
        timestamp: timestamp,
        energy_a_milliwatt_hour: energy_a_milliwatt_hour,
        power_milliwatt: 930*1000
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
      expect(item['power_milliwatt']).to eq(nil)
      expect(item['energy_a_milliwatt_hour']).to eq(1300*1000 * (Time.days_in_month(timestamp.month, timestamp.year)-1)) # -1 day becouse it is in the next day
      expect(item['energy_b_milliwatt_hour']).to eq(nil)
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
        power_milliwatt: 930*1000
      )
      energy_a_milliwatt_hour += 1300*1000
      timestamp += 1.hour
    end

    access_token  = Fabricate(:access_token)

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
      expect(item['energy_a_milliwatt_hour']).to eq(23*1300*1000)
      expect(item['energy_b_milliwatt_hour']).to eq(nil)
      timestamp += 1.day
    end
  end



  it 'does aggregate slp energy past by month_to_days as admin in sommertime ' do
    access_token = Fabricate(:admin_access_token)
    metering_point = Fabricate(:metering_point)

    energy_a_milliwatt_hour = 0
    timestamp = Time.find_zone('Berlin').local(2016,6,1)
    (24*30).times do |i|
      Fabricate(:reading,
        source: 'slp',
        timestamp: timestamp,
        energy_a_milliwatt_hour: energy_a_milliwatt_hour,
        power_milliwatt: 930*1000
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
      expect(item['energy_a_milliwatt_hour']).to eq(23*1300*1000)
      expect(item['energy_b_milliwatt_hour']).to eq(nil)
      timestamp += 1.day
    end
  end





  it 'does aggregate slp power past by day_to_minutes as admin' do
    access_token = Fabricate(:admin_access_token)
    metering_point = Fabricate(:metering_point)

    energy_a_milliwatt_hour = 0
    timestamp = Time.find_zone('Berlin').local(2015,2,1)
    # 3 hours * 60 minutes * 60/2 seconds
    (3*60*30).times do |i|
      Fabricate(:reading,
        source: 'slp',
        timestamp: timestamp,
        energy_a_milliwatt_hour: energy_a_milliwatt_hour,
        power_milliwatt: 930*1000
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
      expect(item['energy_a_milliwatt_hour']).to eq(nil)
      expect(item['energy_b_milliwatt_hour']).to eq(nil)
      timestamp += 1.minutes
    end
  end




  it 'does aggregate slp power past by hour_to_minutes as admin' do
    access_token = Fabricate(:admin_access_token)
    metering_point = Fabricate(:metering_point)

    energy_a_milliwatt_hour = 0
    timestamp = Time.find_zone('Bangkok').local(2015,2,1)
    4.times do |i|
      Fabricate(:reading,
        source: 'slp',
        timestamp: timestamp,
        energy_a_milliwatt_hour: energy_a_milliwatt_hour,
        power_milliwatt: 930*1000
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
      expect(item['energy_a_milliwatt_hour']).to eq(nil)
      expect(item['energy_b_milliwatt_hour']).to eq(nil)
      timestamp += 15.minutes
    end
  end



  it 'does aggregate multiple slp power pasts by hour_to_minutes as admin' do
    access_token = Fabricate(:admin_access_token)
    metering_point1 = Fabricate(:metering_point)
    metering_point2 = Fabricate(:metering_point)

    energy_a_milliwatt_hour = 0
    timestamp = Time.find_zone('Sydney').local(2015,2,1)
    (60*60).times do |i|
      Fabricate(:reading,
        source: 'slp',
        timestamp: timestamp,
        energy_a_milliwatt_hour: energy_a_milliwatt_hour,
        power_milliwatt: 930*1000
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
      expect(item['energy_a_milliwatt_hour']).to eq(nil)
      expect(item['energy_b_milliwatt_hour']).to eq(nil)
      timestamp += 1.minute
    end
  end




  it 'does aggregate multiple slp power pasts by hour_to_minutes with forecast_kwh_pa as admin' do
    access_token = Fabricate(:admin_access_token)
    metering_point1 = Fabricate(:metering_point, forecast_kwh_pa: 3000)
    metering_point2 = Fabricate(:metering_point, forecast_kwh_pa: 8000)

    energy_a_milliwatt_hour = 0
    timestamp = Time.find_zone('Berlin').local(2015,2,1)
    4.times do |i|
      Fabricate(:reading,
        source: 'slp',
        timestamp: timestamp,
        energy_a_milliwatt_hour: energy_a_milliwatt_hour,
        power_milliwatt: 930*1000
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
      expect(item['energy_a_milliwatt_hour']).to eq(nil)
      expect(item['energy_b_milliwatt_hour']).to eq(nil)
      timestamp += 15.minutes
    end
  end


  #
  # Last Reading
  #
  it 'does aggregate slp present as admin' do
    access_token = Fabricate(:admin_access_token)
    metering_point = Fabricate(:metering_point)

    energy_a_milliwatt_hour = 0
    timestamp = Time.find_zone('Berlin').local(2016,2,1)
    (24*4).times do |i|
      Fabricate(:reading,
        source: 'slp',
        timestamp: timestamp,
        energy_a_milliwatt_hour: energy_a_milliwatt_hour,
        power_milliwatt: 930*1000+i
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
    expect(json['power_milliwatt_summed']).to eq(930*1000 + 7)
  end


  it 'does aggregate slp present with forecast_kwh_pa as admin' do
    access_token = Fabricate(:admin_access_token)

    metering_point = Fabricate(:metering_point, forecast_kwh_pa: 3000)
    energy_a_milliwatt_hour = 0
    timestamp = Time.find_zone('Berlin').local(2016,2,1)
    (24*4).times do |i|
      Fabricate(:reading,
        source: 'slp',
        timestamp: timestamp,
        energy_a_milliwatt_hour: energy_a_milliwatt_hour,
        power_milliwatt: 900*1000
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
    expect(json['power_milliwatt_summed']).to eq(900*1000*3)
  end




  it 'does aggregate multiple slp presents with forecast_kwh_pa as admin' do
    access_token = Fabricate(:admin_access_token)

    metering_point1 = Fabricate(:metering_point, forecast_kwh_pa: 3000)
    metering_point2 = Fabricate(:metering_point, forecast_kwh_pa: 8000)

    energy_a_milliwatt_hour = 0
    timestamp = Time.find_zone('Berlin').local(2016,2,1)
    (24*4).times do |i|
      Fabricate(:reading,
        source: 'slp',
        timestamp: timestamp,
        energy_a_milliwatt_hour: energy_a_milliwatt_hour,
        power_milliwatt: 900*1000
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
    expect(json['power_milliwatt_summed']).to eq(900*1000*(3+8))
  end









  #   _                                    _____ _____
  #  | |                             /\   |  __ \_   _|
  #  | |__  _   _ _________ __      /  \  | |__) || |
  #  | '_ \| | | |_  /_  / '_ \    / /\ \ |  ___/ | |
  #  | |_) | |_| |/ / / /| | | |  / ____ \| |    _| |_
  #  |_.__/ \__,_/___/___|_| |_| /_/    \_\_|   |_____|


   it 'does aggregate buzzn energy past by year_to_months as admin in sommertime' do
     access_token = Fabricate(:admin_access_token)

     meter = Fabricate(:easy_meter_q3d_with_metering_point)

     energy_a_milliwatt_hour = 0
     timestamp = Time.find_zone('Moscow').local(2015,1,1)
     (400).times do |i|
       Fabricate(:reading,
         meter_id: meter.id,
         timestamp: timestamp,
         energy_a_milliwatt_hour: energy_a_milliwatt_hour,
         power_milliwatt: 930*1000
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
       expect(item['energy_a_milliwatt_hour']).to eq(1300*1000 * (Time.days_in_month(timestamp.month, timestamp.year)-1)) # -1 day becouse it is in the next day
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
        power_milliwatt: 930*1000
        )
        energy_a_milliwatt_hour += 1300*1000
        timestamp += 1.hour
      end

      access_token  = Fabricate(:access_token)

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
        expect(item['energy_a_milliwatt_hour']).to eq(23*1300*1000)
        expect(item['energy_b_milliwatt_hour']).to eq(nil)
        timestamp += 1.day
      end
    end



  it 'does aggregate buzzn energy past by month_to_days as admin in sommertime ' do
    access_token = Fabricate(:admin_access_token)

    meter = Fabricate(:easy_meter_q3d_with_metering_point)

    energy_a_milliwatt_hour = 0
    timestamp = Time.find_zone('Berlin').local(2016,6,1)
    (24*30).times do |i|
      Fabricate(:reading,
        meter_id: meter.id,
        timestamp: timestamp,
        energy_a_milliwatt_hour: energy_a_milliwatt_hour,
        power_milliwatt: 930*1000
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
      expect(item['energy_a_milliwatt_hour']).to eq(23*1300*1000)
      expect(item['energy_b_milliwatt_hour']).to eq(nil)
      timestamp += 1.day
    end
  end



  it 'does aggregate multiple buzzn power pasts by hour_to_minutes as admin' do
    access_token = Fabricate(:admin_access_token)

    meter1 = Fabricate(:easy_meter_q3d_with_metering_point)
    meter2 = Fabricate(:easy_meter_q3d_with_metering_point)

    energy_a_milliwatt_hour = 0
    timestamp = Time.find_zone('Fiji').local(2015,2,1)
    (60*60).times do |i|

      Fabricate(:reading,
        meter_id: meter1.id,
        timestamp: timestamp,
        energy_a_milliwatt_hour: energy_a_milliwatt_hour,
        power_milliwatt: 900*1000
      )

      Fabricate(:reading,
        meter_id: meter2.id,
        timestamp: timestamp,
        energy_a_milliwatt_hour: energy_a_milliwatt_hour,
        power_milliwatt: 900*1000
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
      expect(item['energy_a_milliwatt_hour']).to eq(nil)
      expect(item['energy_b_milliwatt_hour']).to eq(nil)
      timestamp += 1.minutes
    end
  end


  it 'does aggregate buzzn and slp power past by hour_to_minutes as admin' do
    access_token = Fabricate(:admin_access_token)

    metering_point  = Fabricate(:metering_point, forecast_kwh_pa: 3000)
    meter           = Fabricate(:easy_meter_q3d_with_metering_point)

    energy_a_milliwatt_hour = 0
    timestamp = Time.find_zone('Berlin').local(2015,2,1)
    (60*60).times do |i|

      Fabricate(:reading,
        source: 'slp',
        timestamp: timestamp,
        energy_a_milliwatt_hour: energy_a_milliwatt_hour,
        power_milliwatt: 1000*1000
      )

      Fabricate(:reading,
        meter_id: meter.id,
        timestamp: timestamp,
        energy_a_milliwatt_hour: energy_a_milliwatt_hour,
        power_milliwatt: 900*1000
      )

      energy_a_milliwatt_hour += 1300*1000
      timestamp += 1.seconds
    end

    request_params = {
      metering_point_ids: "#{meter.metering_points.first.id},#{metering_point.id}",
      resolution: 'hour_to_minutes',
      timestamp: Time.find_zone('Berlin').local(2015,2,1, 0,30)
    }

    get_with_token "/api/v1/aggregates/past", request_params, access_token.token

    expect(response).to have_http_status(200)
    expect(json.count).to eq(60)
    timestamp = Time.find_zone('Berlin').local(2015,2,1)
    json.each do |item|
      expect(Time.parse(item['timestamp']).utc).to eq(timestamp.utc)
      expect(item['power_milliwatt']).to eq((900*1000)+(3000*1000))
      expect(item['energy_a_milliwatt_hour']).to eq(nil)
      expect(item['energy_b_milliwatt_hour']).to eq(nil)
      timestamp += 1.minutes
    end
  end


  it 'does aggregate buzzn and slp past energy by year_to_months as admin in sommertime' do
    access_token = Fabricate(:admin_access_token)

    metering_point  = Fabricate(:metering_point, forecast_kwh_pa: 3000)
    meter           = Fabricate(:easy_meter_q3d_with_metering_point)

    slp_energy_a_milliwatt_hour = 0
    buzzn_energy_a_milliwatt_hour = 0
    timestamp = Time.find_zone('Berlin').local(2015,1,1)
    (400).times do |i|
      Fabricate(:reading,
        source: 'slp',
        timestamp: timestamp,
        energy_a_milliwatt_hour: slp_energy_a_milliwatt_hour
      )
      Fabricate(:reading,
        meter_id: meter.id,
        timestamp: timestamp,
        energy_a_milliwatt_hour: buzzn_energy_a_milliwatt_hour
      )
      slp_energy_a_milliwatt_hour += 1000*1000
      buzzn_energy_a_milliwatt_hour += 2100*1000
      timestamp += 1.day
    end

    request_params = {
      metering_point_ids: "#{meter.metering_points.first.id},#{metering_point.id}",
      resolution: 'year_to_months',
      timestamp: Time.find_zone('Berlin').local(2015,6).iso8601
    }

    get_with_token "/api/v1/aggregates/past", request_params, access_token.token

    expect(response).to have_http_status(200)
    expect(json.count).to eq(12) # 12 month

    timestamp = Time.find_zone('Berlin').local(2015,1,1)

    json.each do |item|
      days_in_month = Time.days_in_month(timestamp.month, timestamp.year) - 1 # -1 day becouse it is in the next day
      expect(Time.parse(item['timestamp']).utc).to eq(timestamp.utc)
      expect(item['power_milliwatt']).to eq(nil)
      expect(item['energy_a_milliwatt_hour']).to eq((2100*1000*days_in_month)+(3000*1000*days_in_month))
      expect(item['energy_b_milliwatt_hour']).to eq(nil)
      timestamp += 1.month
    end
  end



  it 'does aggregate buzzn and slp energy past by year_to_months as admin in sommertime' do
    access_token = Fabricate(:admin_access_token)

    metering_point  = Fabricate(:metering_point, forecast_kwh_pa: 3000)
    meter           = Fabricate(:easy_meter_q3d_with_metering_point)

    slp_energy_a_milliwatt_hour = 0
    buzzn_energy_a_milliwatt_hour = 0
    timestamp = Time.find_zone('Berlin').local(2015,1,1)
    (400).times do |i|
      Fabricate(:reading,
        source: 'slp',
        timestamp: timestamp,
        energy_a_milliwatt_hour: slp_energy_a_milliwatt_hour
      )
      Fabricate(:reading,
        meter_id: meter.id,
        timestamp: timestamp,
        energy_a_milliwatt_hour: buzzn_energy_a_milliwatt_hour
      )
      slp_energy_a_milliwatt_hour += 1000*1000
      buzzn_energy_a_milliwatt_hour += 2100*1000
      timestamp += 1.day
    end

    request_params = {
      metering_point_ids: "#{meter.metering_points.first.id},#{metering_point.id}",
      resolution: 'year_to_months',
      timestamp: Time.find_zone('Berlin').local(2015,6).iso8601
    }

    get_with_token "/api/v1/aggregates/past", request_params, access_token.token

    expect(response).to have_http_status(200)
    expect(json.count).to eq(12) # 12 month

    timestamp = Time.find_zone('Berlin').local(2015,1,1)

    json.each do |item|
      days_in_month = Time.days_in_month(timestamp.month, timestamp.year) - 1 # -1 day becouse it is in the next day
      expect(Time.parse(item['timestamp']).utc).to eq(timestamp.utc)
      expect(item['power_milliwatt']).to eq(nil)
      expect(item['energy_a_milliwatt_hour']).to eq((2100*1000*days_in_month)+(3000*1000*days_in_month))
      expect(item['energy_b_milliwatt_hour']).to eq(nil)
      timestamp += 1.month
    end
  end




  it 'does aggregate multiple buzzn present as admin' do
    access_token = Fabricate(:admin_access_token)

    meter1 = Fabricate(:easy_meter_q3d_with_metering_point)
    meter2 = Fabricate(:easy_meter_q3d_with_metering_point)

    energy_a_milliwatt_hour = 0
    timestamp = Time.new(2016,2,1)
    (60*60).times do |i|

      Fabricate(:reading,
        meter_id: meter1.id,
        timestamp: timestamp,
        energy_a_milliwatt_hour: energy_a_milliwatt_hour,
        power_milliwatt: 900*1000
      )

      Fabricate(:reading,
        meter_id: meter2.id,
        timestamp: timestamp,
        energy_a_milliwatt_hour: energy_a_milliwatt_hour,
        power_milliwatt: 800*1000
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
    expect(json['power_milliwatt_summed']).to eq((900*1000)+(800*1000))
  end




  it 'does aggregate buzzn and slp present as admin' do
    access_token = Fabricate(:admin_access_token)

    metering_point  = Fabricate(:metering_point, forecast_kwh_pa: 3000)
    meter           = Fabricate(:easy_meter_q3d_with_metering_point)


    slp_energy_a_milliwatt_hour = 0
    timestamp = Time.find_zone('Berlin').local(2015,1,1)
    (60*60).times do |i|
      Fabricate(:reading,
        source: 'slp',
        timestamp: timestamp,
        power_milliwatt: 1000*1000,
        energy_a_milliwatt_hour: slp_energy_a_milliwatt_hour
      )
      timestamp += 1.seconds
      slp_energy_a_milliwatt_hour += 1000*1000
    end

    buzzn_energy_a_milliwatt_hour = 0
    timestamp = Time.find_zone('Berlin').local(2015,1,1)
    (60*30).times do |i|
      Fabricate(:reading,
        meter_id: meter.id,
        timestamp: timestamp,
        power_milliwatt: 6000*1000,
        energy_a_milliwatt_hour: buzzn_energy_a_milliwatt_hour
      )
      timestamp += 1.seconds
      buzzn_energy_a_milliwatt_hour += 2100*1000
    end


    Timecop.freeze(Time.find_zone('Berlin').local(2015,1,1, 0,30)) # 6*15 minutes
    request_params = {
      metering_point_ids: "#{metering_point.id},#{meter.metering_points.first.id}"
    }

    get_with_token "/api/v1/aggregates/present", request_params, access_token.token

    expect(response).to have_http_status(200)

    expect(json['readings'].count).to eq(2)
    expect(json['power_milliwatt_summed']).to eq((1000*1000*3)+(6000*1000))
  end








   #  _____  _
   # |  __ \(_)
   # | |  | |_ ___  ___ _____   _____ _ __ __ _ _   _
   # | |  | | / __|/ __/ _ \ \ / / _ \ '__/ _` | | | |
   # | |__| | \__ \ (_| (_) \ V /  __/ | | (_| | |_| |
   # |_____/|_|___/\___\___/ \_/ \___|_|  \__, |\__, |
   #                                       __/ | __/ |
   #                                      |___/ |___/



  it 'does aggregate Discovergy past month_to_days for out metering_point as admin' do
    access_token = Fabricate(:admin_access_token)
    metering_point = Fabricate(:mp_z2) # PV
    metering_point.contracts << Fabricate(:mpoc_buzzn_metering)

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
    expect(json[15]['energy_b_milliwatt_hour']).to eq(2146232)

    timestamp = Time.find_zone('Berlin').local(2016,2,1)
    json.each do |item|
      expect(Time.parse(item['timestamp']).utc).to eq(timestamp.utc)
      timestamp += 1.day
    end
  end



    #
    # Virtuel
    #
    xit 'does aggregate Virtuel past month_to_days for out Discovergy metering_points as admin' do
    end




end
