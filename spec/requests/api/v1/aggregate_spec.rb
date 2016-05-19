describe "Aggregate API" do

  before(:all) do
    Fabricate(:metering_point_operator, name: 'buzzn Metering')
    Fabricate(:metering_point_operator, name: 'Discovergy')
    Fabricate(:metering_point_operator, name: 'MySmartGrid')
  end

  it 'does have the Berlin timezone' do
    Timecop.freeze(Time.local(2016,2,1, 1,30,1))
    expect(Time.now.in_time_zone.utc_offset).to eq(3600)
    expect(Time.zone.name).to eq("Berlin")
  end

  # ##
  # ## SLP
  # ##
  # it 'does aggregate month_to_days slp chart as stranger in wintertime' do
  #   metering_point = Fabricate(:metering_point, readable: 'world')
  #
  #   energy_a_milliwatt_hour = 0
  #   timestamp = Time.new(2016,1,1)
  #   (24*30).times do |i|
  #     Fabricate(:reading,
  #       source: 'slp',
  #       timestamp: timestamp,
  #       energy_a_milliwatt_hour: energy_a_milliwatt_hour,
  #       power_milliwatt: 930*1000
  #     )
  #     energy_a_milliwatt_hour += 1300*1000
  #     timestamp += 1.hour
  #   end
  #
  #   access_token  = Fabricate(:access_token)
  #
  #   request_params = {
  #     metering_point_ids: metering_point.id,
  #     timestamp: Time.new(2016,1,17),
  #     resolution: 'month_to_days'
  #   }
  #
  #   get_with_token "/api/v1/aggregate/chart", request_params, access_token.token
  #
  #   expect(response).to have_http_status(200)
  #   expect(json.count).to eq(30)
  #   timestamp = Time.new(2016,1,1)
  #   json.each do |item|
  #     expect(Time.at(item[0]/1000)).to eq(timestamp)
  #     expect(item[1]).to eq(23*1300*1000)
  #     expect(item[2]).to eq(nil)
  #     timestamp += 1.day
  #   end
  # end
  #
  #
  #
  # it 'does aggregate month_to_days slp chart as admin in sommertime ' do
  #   access_token = Fabricate(:admin_access_token)
  #   metering_point = Fabricate(:metering_point)
  #
  #   energy_a_milliwatt_hour = 0
  #   timestamp = Time.new(2016,6,1)
  #   (24*30).times do |i|
  #     Fabricate(:reading,
  #       source: 'slp',
  #       timestamp: timestamp,
  #       energy_a_milliwatt_hour: energy_a_milliwatt_hour,
  #       power_milliwatt: 930*1000
  #     )
  #     energy_a_milliwatt_hour += 1300*1000
  #     timestamp += 1.hour
  #   end
  #
  #   request_params = {
  #     metering_point_ids: metering_point.id,
  #     resolution: 'month_to_days',
  #     timestamp: Time.new(2016,6,2)
  #   }
  #
  #   get_with_token "/api/v1/aggregate/chart", request_params, access_token.token
  #
  #   expect(response).to have_http_status(200)
  #   expect(json.count).to eq(30)
  #   timestamp = Time.new(2016,6,1)
  #   json.each do |item|
  #     expect(Time.at(item[0]/1000)).to eq(timestamp)
  #     expect(item[1]).to eq(23*1300*1000)
  #     timestamp += 1.day
  #   end
  # end
  #
  #

  it 'does aggregate year_to_months slp chart as admin in sommertime ' do
    access_token = Fabricate(:admin_access_token)
    metering_point = Fabricate(:metering_point)

    energy_a_milliwatt_hour = 0
    timestamp = Time.new(2016,1,1).in_time_zone
    (366).times do |i|
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
      timestamp: Time.new(2016,6,2).in_time_zone
    }

    get_with_token "/api/v1/aggregate/chart", request_params, access_token.token

    expect(response).to have_http_status(200)
    expect(json.count).to eq(12) # 12 month

    timestamp = Time.new(2016,1,1).in_time_zone
    json.each do |item|
      expect(Time.at(item[0]/1000).in_time_zone).to eq(timestamp)
      expect(item[1]).to eq(1300*1000 * (Time.days_in_month(timestamp.month, timestamp.year)-1))
      timestamp += 1.month
    end
  end



  #
  # it 'does aggregate day_to_minutes slp chart as admin' do
  #   access_token = Fabricate(:admin_access_token)
  #   metering_point = Fabricate(:metering_point)
  #
  #   energy_a_milliwatt_hour = 0
  #   timestamp = Time.new(2016,2,1)
  #   # 3 hours * 60 minutes * 60/2 seconds
  #   (3*60*30).times do |i|
  #     Fabricate(:reading,
  #       source: 'slp',
  #       timestamp: timestamp,
  #       energy_a_milliwatt_hour: energy_a_milliwatt_hour,
  #       power_milliwatt: 930*1000
  #     )
  #     energy_a_milliwatt_hour += 1300*1000
  #     timestamp += 2.second
  #   end
  #
  #   request_params = {
  #     metering_point_ids: metering_point.id,
  #     resolution: 'day_to_minutes',
  #     timestamp: Time.new(2016,2,1)
  #   }
  #
  #   get_with_token "/api/v1/aggregate/chart", request_params, access_token.token
  #
  #   expect(response).to have_http_status(200)
  #   expect(json.count).to eq(3*60-1)
  #   timestamp = Time.new(2016,2,1)
  #   json.each do |item|
  #     expect(Time.at(item[0]/1000)).to eq(timestamp)
  #     expect(item[1]).to eq(930*1000)
  #     timestamp += 1.minutes
  #   end
  # end
  #
  #
  #
  #
  # it 'does aggregate hour_to_minutes slp chart as admin' do
  #   access_token = Fabricate(:admin_access_token)
  #   metering_point = Fabricate(:metering_point)
  #
  #   energy_a_milliwatt_hour = 0
  #   timestamp = Time.new(2016,2,1)
  #   4.times do |i|
  #     Fabricate(:reading,
  #       source: 'slp',
  #       timestamp: timestamp,
  #       energy_a_milliwatt_hour: energy_a_milliwatt_hour,
  #       power_milliwatt: 930*1000
  #     )
  #     energy_a_milliwatt_hour += 1300*1000
  #     timestamp += 15.minutes
  #   end
  #
  #   request_params = {
  #     metering_point_ids: metering_point.id,
  #     resolution: 'hour_to_minutes',
  #     timestamp: Time.new(2016,2,1, 0,30)
  #   }
  #
  #   get_with_token "/api/v1/aggregate/chart", request_params, access_token.token
  #
  #   expect(response).to have_http_status(200)
  #   expect(json.count).to eq(45)
  #   expect(Time.at(json[0][0]/1000)).to eq(Time.new(2016,2,1))
  #   json.each do |item|
  #     expect(item[1]).to eq(930*1000)
  #   end
  # end
  #
  #
  # it 'does aggregate multiple metering_points slp chart by hour_to_minutes as admin' do
  #   access_token = Fabricate(:admin_access_token)
  #   metering_point1 = Fabricate(:metering_point)
  #   metering_point2 = Fabricate(:metering_point)
  #
  #   energy_a_milliwatt_hour = 0
  #   timestamp = Time.new(2016,2,1)
  #   4.times do |i|
  #     Fabricate(:reading,
  #       source: 'slp',
  #       timestamp: timestamp,
  #       energy_a_milliwatt_hour: energy_a_milliwatt_hour,
  #       power_milliwatt: 930*1000
  #     )
  #     energy_a_milliwatt_hour += 1300*1000
  #     timestamp += 15.minutes
  #   end
  #
  #   request_params = {
  #     metering_point_ids: "#{metering_point1.id},#{metering_point2.id}",
  #     resolution: 'hour_to_minutes',
  #     timestamp: Time.new(2016,2,1, 0,30)
  #   }
  #
  #   get_with_token "/api/v1/aggregate/chart", request_params, access_token.token
  #
  #   expect(response).to have_http_status(200)
  #   expect(json.count).to eq(45)
  #   expect(Time.at(json[0][0]/1000)).to eq(Time.new(2016,2,1))
  #   json.each do |item|
  #     expect(item[1]).to eq(2*930*1000)
  #   end
  #
  # end
  #
  #
  #
  #
  # it 'does aggregate multiple metering_points slp with forecast_kwh_pa chart by hour_to_minutes as admin' do
  #   access_token = Fabricate(:admin_access_token)
  #   metering_point1 = Fabricate(:metering_point, forecast_kwh_pa: 3000)
  #   metering_point2 = Fabricate(:metering_point, forecast_kwh_pa: 8000)
  #
  #   energy_a_milliwatt_hour = 0
  #   timestamp = Time.new(2016,2,1)
  #   4.times do |i|
  #     Fabricate(:reading,
  #       source: 'slp',
  #       timestamp: timestamp,
  #       energy_a_milliwatt_hour: energy_a_milliwatt_hour,
  #       power_milliwatt: 930*1000
  #     )
  #     energy_a_milliwatt_hour += 1300*1000
  #     timestamp += 15.minutes
  #   end
  #
  #   request_params = {
  #     metering_point_ids: "#{metering_point1.id},#{metering_point2.id}",
  #     resolution: 'hour_to_minutes',
  #     timestamp: Time.new(2016,2,1, 0,30)
  #   }
  #
  #   get_with_token "/api/v1/aggregate/chart", request_params, access_token.token
  #
  #   expect(response).to have_http_status(200)
  #   expect(json.count).to eq(45)
  #   expect(Time.at(json[0][0]/1000)).to eq(Time.new(2016,2,1))
  #   json.each do |item|
  #     expect(item[1]).to eq(11366666)
  #   end
  #
  # end
  #
  #
  #
  #
  #
  #
  #
  # it 'does aggregate slp metering_point power without forecast_kwh_pa as admin' do
  #   access_token = Fabricate(:admin_access_token)
  #   metering_point = Fabricate(:metering_point)
  #
  #   energy_a_milliwatt_hour = 0
  #   timestamp = Time.new(2016,2,1)
  #   (24*4).times do |i|
  #     Fabricate(:reading,
  #       source: 'slp',
  #       timestamp: timestamp,
  #       energy_a_milliwatt_hour: energy_a_milliwatt_hour,
  #       power_milliwatt: 930*1000+i
  #     )
  #     energy_a_milliwatt_hour += 1300*1000
  #     timestamp += 15.minutes
  #   end
  #
  #   Timecop.freeze(Time.local(2016,2,1, 1,30,1)) # 6*15 minutes and 1 seconds
  #   request_params = {
  #     metering_point_ids: metering_point.id
  #   }
  #
  #   get_with_token "/api/v1/aggregate/power", request_params, access_token.token
  #
  #   expect(response).to have_http_status(200)
  #   expect(response.body.to_i).to eq(930*1000 + 6) # 6*15 minutes
  # end
  #
  #
  #
  #
  # it 'does aggregate slp metering_point power with forecast_kwh_pa as admin' do
  #   access_token = Fabricate(:admin_access_token)
  #
  #   metering_point = Fabricate(:metering_point, forecast_kwh_pa: 3000)
  #   energy_a_milliwatt_hour = 0
  #   timestamp = Time.new(2016,2,1)
  #   (24*4).times do |i|
  #     Fabricate(:reading,
  #       source: 'slp',
  #       timestamp: timestamp,
  #       energy_a_milliwatt_hour: energy_a_milliwatt_hour,
  #       power_milliwatt: 900*1000+i
  #     )
  #     energy_a_milliwatt_hour += 1300*1000
  #     timestamp += 15.minutes
  #   end
  #
  #   Timecop.freeze(Time.local(2016,2,1, 1,30,1)) # 6*15 minutes and 1 seconds
  #   request_params = {
  #     metering_point_ids: metering_point.id
  #   }
  #
  #   get_with_token "/api/v1/aggregate/power", request_params, access_token.token
  #
  #   expect(response).to have_http_status(200)
  #   expect(response.body.to_i).to eq((900*1000 + 6)*3000/900.0) # forcast_formel = forecast / slp_power
  # end
  #
  #
  # it 'does aggregate multiple metering_point slp power with forecast_kwh_pa as admin' do
  #   access_token = Fabricate(:admin_access_token)
  #
  #   metering_point1 = Fabricate(:metering_point, forecast_kwh_pa: 3000)
  #   metering_point2 = Fabricate(:metering_point, forecast_kwh_pa: 3000)
  #
  #   energy_a_milliwatt_hour = 0
  #   timestamp = Time.new(2016,2,1)
  #   (24*4).times do |i|
  #     Fabricate(:reading,
  #       source: 'slp',
  #       timestamp: timestamp,
  #       energy_a_milliwatt_hour: energy_a_milliwatt_hour,
  #       power_milliwatt: 900*1000+i
  #     )
  #     energy_a_milliwatt_hour += 1300*1000
  #     timestamp += 15.minutes
  #   end
  #
  #   Timecop.freeze(Time.local(2016,2,1, 1,30,1)) # 6*15 minutes and 1 seconds
  #   request_params = {
  #     metering_point_ids: "#{metering_point1.id},#{metering_point2.id}"
  #   }
  #
  #   get_with_token "/api/v1/aggregate/power", request_params, access_token.token
  #
  #   expect(response).to have_http_status(200)
  #   expect(response.body.to_i).to eq(2*((900*1000 + 6)*3000/900.0)) # forcast_formel = forecast / slp_power
  # end
  #
  #
  #
  # it 'does aggregate multiple buzzn metering_points power as admin' do
  #   access_token = Fabricate(:admin_access_token)
  #
  #   meter1 = Fabricate(:meter_smart_with_metering_point)
  #   meter2 = Fabricate(:meter_smart_with_metering_point)
  #
  #   energy_a_milliwatt_hour = 0
  #   timestamp = Time.new(2016,2,1)
  #   (3*60*30).times do |i|
  #
  #     Fabricate(:reading,
  #       metering_point_id: meter1.metering_points.first.id,
  #       timestamp: timestamp,
  #       energy_a_milliwatt_hour: energy_a_milliwatt_hour,
  #       power_milliwatt: 900*1000+i
  #     )
  #
  #     Fabricate(:reading,
  #       metering_point_id: meter2.metering_points.first.id,
  #       timestamp: timestamp,
  #       energy_a_milliwatt_hour: energy_a_milliwatt_hour,
  #       power_milliwatt: 800*1000+i
  #     )
  #
  #     energy_a_milliwatt_hour += 1300*1000
  #     timestamp += 2.seconds
  #   end
  #
  #   Timecop.freeze(Time.local(2016,2,1, 1,30)) # 6*15 minutes
  #   request_params = {
  #     metering_point_ids: "#{meter1.metering_points.first.id},#{meter2.metering_points.first.id}"
  #   }
  #
  #   get_with_token "/api/v1/aggregate/power", request_params, access_token.token
  #
  #   expect(response).to have_http_status(200)
  #   expect(response.body.to_i).to eq((900*1000 + 2700)+((800*1000 + 2700))) # 1 hour and 30 minutes every 2 seconds = (3600+1800)/2 = 2700
  # end
  #
  #
  #
  # xit 'does aggregate buzzn-api metering_point power as admin' do
  # end
  #
  #
  #
  #
  #
  # ##
  # ## Discovergy
  # ##
  # it 'does aggregate day_to_minutes Discovergy chart as admin' do
  #   access_token = Fabricate(:admin_access_token)
  #   metering_point = Fabricate(:mp_pv_karin)
  #   metering_point.contracts << Fabricate(:mpoc_karin)
  #
  #   request_params = {
  #     metering_point_ids: metering_point.id,
  #     resolution: 'day_to_minutes',
  #     timestamp: DateTime.new(2016,2,1)
  #   }
  #
  #   get_with_token "/api/v1/aggregate/chart", request_params, access_token.token
  #
  #   expect(response).to have_http_status(200)
  #   expect(json.count).to eq(1425) # not 1440 because last reading is at 23:45, 15 minutes are missing and day_to_minutes uses Discovergy getDayEveryFifteenMinutes Api
  # end
  #
  # xit 'does aggregate discovergy metering_point power as admin' do
  # end




end
