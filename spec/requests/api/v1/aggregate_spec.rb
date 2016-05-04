describe "Aggregate API" do

  before(:all) do
    Fabricate(:metering_point_operator, name: 'buzzn Metering')
    Fabricate(:metering_point_operator, name: 'buzzn Reader')
    Fabricate(:metering_point_operator, name: 'Discovergy')
    Fabricate(:metering_point_operator, name: 'MySmartGrid')
  end



  it 'does aggregate day_to_minutes Discovergy chart as admin' do
    access_token = Fabricate(:admin_access_token)
    metering_point = Fabricate(:mp_pv_karin)
    metering_point.contracts << Fabricate(:mpoc_karin)

    request_params = {
      metering_point_ids: metering_point.id,
      resolution: 'day_to_minutes',
      timestamp: DateTime.new(2016,2,1)
    }

    get_with_token "/api/v1/aggregate/chart", request_params, access_token.token

    expect(response).to have_http_status(200)
    expect(json.count).to eq(1425) # not 1440 because last reading is at 23:45, 15 minutes are missing and day_to_minutes uses Discovergy getDayEveryFifteenMinutes Api
  end



  it 'does aggregate day_to_minutes slp chart as admin' do
    access_token = Fabricate(:admin_access_token)
    metering_point = Fabricate(:metering_point)

    watt_hour = 0
    timestamp = Time.new(2016,2,1)
    (24*4).times do |i|
      Fabricate(:reading,
        source: 'slp',
        timestamp: timestamp,
        watt_hour: watt_hour,
        power: 930*1000
      )
      watt_hour += 1300*1000
      timestamp += 15.minutes
    end

    request_params = {
      metering_point_ids: metering_point.id,
      resolution: 'day_to_minutes',
      timestamp: Time.new(2016,2,1)
    }

    get_with_token "/api/v1/aggregate/chart", request_params, access_token.token

    expect(response).to have_http_status(200)
    expect(json.count).to eq(1425) # not 1440 because last slp is at 23:45. 15 minutes are missing
    json.each do |item|
      expect(item[1]).to eq(930)
    end
  end



  it 'does aggregate hour_to_minutes slp chart as admin' do
    access_token = Fabricate(:admin_access_token)
    metering_point = Fabricate(:metering_point)

    watt_hour = 0
    timestamp = Time.new(2016,2,1)
    (24*4).times do |i|
      Fabricate(:reading,
        source: 'slp',
        timestamp: timestamp,
        watt_hour: watt_hour,
        power: 930*1000
      )
      watt_hour += 1300*1000
      timestamp += 15.minutes
    end

    request_params = {
      metering_point_ids: metering_point.id,
      resolution: 'hour_to_minutes',
      timestamp: Time.new(2016,2,1)
    }

    get_with_token "/api/v1/aggregate/chart", request_params, access_token.token

    expect(response).to have_http_status(200)
    expect(json.count).to eq(45)
    json.each do |item|
      expect(item[1]).to eq(930)
    end
  end


  # it 'does aggregate SLP chart as admin' do
  #   access_token = Fabricate(:admin_access_token)
  #
  #   watt_hour = 0
  #   timestamp = DateTime.new(2016,2,1)
  #   168.times do |i|
  #     Fabricate(:reading,
  #       source: 'slp',
  #       timestamp: timestamp,
  #       watt_hour: watt_hour
  #     )
  #     watt_hour += 1300
  #     timestamp += 1.hour
  #   end
  #
  #   request_params = {
  #     timestamp: DateTime.new(2016,2,1)
  #   }
  #
  #
  #   get_with_token "/api/v1/aggregate/chart", request_params, access_token.token
  #
  #   binding.pry
  #
  #   expect(response).to have_http_status(200)
  # end



  # it 'does aggregate slp metering_point as stranger' do
  #   metering_point = Fabricate(:metering_point, readable: 'world')
  #   watt_hour_a = 0
  #   timestamp = DateTime.new(2016,2,1)
  #   168.times do |i|
  #     Fabricate(:reading,
  #       source: 'slp',
  #       timestamp: timestamp,
  #       watt_hour_a: watt_hour_a
  #     )
  #     watt_hour_a += 1300
  #     timestamp += 1.hour
  #   end
  #
  #   metering_point_with_manager = Fabricate(:metering_point_with_manager)
  #   manager       = metering_point_with_manager.managers.first
  #   access_token  = Fabricate(:access_token, resource_owner_id: manager.id)
  #
  #   request_params = {
  #     metering_point_ids: metering_point.id,
  #     timestamp: DateTime.new(2016,2,3),
  #     resolution: 'month_to_days'
  #   }
  #
  #
  #   get_with_token "/api/v1/aggregate/chart", request_params, access_token.token
  #   expect(response).to have_http_status(403)
  # end


  #
  #
  #
  #
  # it 'does aggregate readings as stranger if metering_points is readable_by_world' do
  #   metering_point = Fabricate(:metering_point, readable: 'world')
  #   watt_hour = 0
  #   timestamp = DateTime.new(2016,2,1)
  #   168.times do |i|
  #     Fabricate(:reading,
  #       metering_point_id: metering_point.id,
  #       timestamp: timestamp,
  #       watt_hour: watt_hour
  #     )
  #     watt_hour += 1300
  #     timestamp += 1.hour
  #   end
  #
  #   metering_point_with_manager = Fabricate(:metering_point_with_manager)
  #   manager       = metering_point_with_manager.managers.first
  #   access_token  = Fabricate(:access_token, resource_owner_id: manager.id)
  #
  #   request_params = {
  #     metering_point_ids: metering_point.id,
  #     timestamp: DateTime.new(2016,2,3),
  #     resolution: 'month_to_days'
  #   }
  #
  #   get_with_token "/api/v1/aggregate", request_params, access_token.token
  #
  #   expect(response).to have_http_status(200)
  #   json.each do |item|
  #     expect(item[1]).to eq(1300*23) # = 1300 watt_hour * 23stunden
  #     expect(item[2]).to eq(900.0)
  #   end
  #   expect(json.size).to eq(7) # 7 dayes for a created week in a month
  # end
  #
  #
  #
  #
  #
  #
  # it 'does aggregate readings with month_to_days as manager' do
  #   metering_point = Fabricate(:metering_point_with_manager)
  #   watt_hour = 0
  #   timestamp = DateTime.new(2016,2,1)
  #   168.times do |i|
  #     Fabricate(:reading,
  #       metering_point_id: metering_point.id,
  #       timestamp: timestamp,
  #       watt_hour: watt_hour
  #     )
  #     watt_hour += 1300
  #     timestamp += 1.hour
  #   end
  #
  #   manager       = metering_point.managers.first
  #   access_token  = Fabricate(:access_token, resource_owner_id: manager.id)
  #
  #   request_params = {
  #     metering_point_ids: metering_point.id,
  #     timestamp: DateTime.new(2016,2,3),
  #     resolution: 'month_to_days'
  #   }
  #
  #   get_with_token "/api/v1/aggregate", request_params, access_token.token
  #
  #   expect(response).to have_http_status(200)
  #   json.each do |item|
  #     expect(item[1]).to eq(1300*23) # = 1300 watt_hour * 23stunden
  #     expect(item[2]).to eq(900.0)
  #   end
  #   expect(json.size).to eq(7) # 7 dayes for a created week in a month
  # end
  #
  #
  #
  #
  # it 'does aggregate readings with multiple metering_points as admin' do
  #   access_token = Fabricate(:admin_access_token)
  #
  #   metering_point1 = Fabricate(:metering_point)
  #   metering_point2 = Fabricate(:metering_point)
  #
  #   watt_hour = 0
  #   timestamp = DateTime.new(2016,2,1)
  #   168.times do |i|
  #     Fabricate(:reading,
  #       metering_point_id: metering_point1.id,
  #       timestamp: timestamp,
  #       watt_hour: watt_hour
  #     )
  #     Fabricate(:reading,
  #       metering_point_id: metering_point2.id,
  #       timestamp: timestamp,
  #       watt_hour: watt_hour
  #     )
  #     watt_hour += 1300
  #     timestamp += 1.hour
  #   end
  #
  #   request_params = {
  #     metering_point_ids: "#{metering_point1.id},#{metering_point2.id}",
  #     timestamp: DateTime.new(2016,2,3),
  #     resolution: 'month_to_days'
  #   }
  #
  #   get_with_token "/api/v1/aggregate", request_params, access_token.token
  #
  #   expect(response).to have_http_status(200)
  #   json.each do |item|
  #     expect(item[1]).to eq(2*1300*23) # = 1300 watt_hour * 23stunden
  #     expect(item[2]).to eq(2*900.0)
  #   end
  #   expect(json.size).to eq(7) # 7 dayes for a created week in a month
  # end
  #




end
