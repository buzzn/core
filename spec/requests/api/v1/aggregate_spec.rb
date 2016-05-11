describe "Aggregate API" do

  before(:all) do
    Time.zone = 'Berlin'

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



  it 'does aggregate month_to_days slp as stranger in wintertime' do
    metering_point = Fabricate(:metering_point, readable: 'world')

    watt_hour = 0
    timestamp = Time.new(2016,1,1)
    (24*30).times do |i|
      Fabricate(:reading,
        source: 'slp',
        timestamp: timestamp,
        watt_hour: watt_hour,
        power: 930*1000
      )
      watt_hour += 1300*1000
      timestamp += 1.hour
    end

    access_token  = Fabricate(:access_token)

    request_params = {
      metering_point_ids: metering_point.id,
      timestamp: Time.new(2016,1,17),
      resolution: 'month_to_days'
    }

    get_with_token "/api/v1/aggregate/chart", request_params, access_token.token

    expect(response).to have_http_status(200)
    expect(json.count).to eq(30)
    timestamp = Time.new(2016,1,1)
    json.each do |item|
      expect(Time.at(item[0]/1000)).to eq(timestamp)
      expect(item[1]).to eq(23*1300*1000)
      timestamp += 1.day
    end
  end



  it 'does aggregate month_to_days slp chart as admin in sommertime ' do
    access_token = Fabricate(:admin_access_token)
    metering_point = Fabricate(:metering_point)

    watt_hour = 0
    timestamp = Time.new(2016,6,1)
    (24*30).times do |i|
      Fabricate(:reading,
        source: 'slp',
        timestamp: timestamp,
        watt_hour: watt_hour,
        power: 930*1000
      )
      watt_hour += 1300*1000
      timestamp += 1.hour
    end


    request_params = {
      metering_point_ids: metering_point.id,
      resolution: 'month_to_days',
      timestamp: Time.new(2016,6,2)
    }

    get_with_token "/api/v1/aggregate/chart", request_params, access_token.token

    expect(response).to have_http_status(200)
    expect(json.count).to eq(30)
    timestamp = Time.new(2016,6,1)
    json.each do |item|
      expect(Time.at(item[0]/1000)).to eq(timestamp)
      expect(item[1]).to eq(23*1300*1000)
      timestamp += 1.day
    end
  end





  it 'does aggregate day_to_minutes slp chart as admin' do
    access_token = Fabricate(:admin_access_token)
    metering_point = Fabricate(:metering_point)

    watt_hour = 0
    timestamp = Time.new(2016,2,1)
    # 3 hours * 60 minutes * 60/2 seconds
    (3*60*30).times do |i|
      Fabricate(:reading,
        source: 'slp',
        timestamp: timestamp,
        watt_hour: watt_hour,
        power: 930*1000
      )
      watt_hour += 1300*1000
      timestamp += 2.second
    end

    request_params = {
      metering_point_ids: metering_point.id,
      resolution: 'day_to_minutes',
      timestamp: Time.new(2016,2,1)
    }

    get_with_token "/api/v1/aggregate/chart", request_params, access_token.token

    expect(response).to have_http_status(200)
    expect(json.count).to eq(3*60-1)
    timestamp = Time.new(2016,2,1)
    json.each do |item|
      expect(Time.at(item[0]/1000)).to eq(timestamp)
      expect(item[1]).to eq(930*1000)
      timestamp += 1.minutes
    end
  end




  it 'does aggregate hour_to_minutes slp chart as admin' do
    access_token = Fabricate(:admin_access_token)
    metering_point = Fabricate(:metering_point)

    watt_hour = 0
    timestamp = Time.new(2016,2,1)
    4.times do |i|
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
      timestamp: Time.new(2016,2,1, 0,30)
    }

    get_with_token "/api/v1/aggregate/chart", request_params, access_token.token

    expect(response).to have_http_status(200)
    expect(json.count).to eq(45)
    expect(Time.at(json[0][0]/1000)).to eq(Time.new(2016,2,1))
    json.each do |item|
      expect(item[1]).to eq(930*1000)
    end
  end



end
