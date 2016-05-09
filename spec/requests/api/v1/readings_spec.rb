describe "Readings API" do

  it 'does not gets a reading without token' do
    reading = Fabricate(:reading)
    get_without_token "/api/v1/readings/#{reading.id}"
    expect(response).to have_http_status(401)
  end

  it 'does gets a reading as admin' do
    access_token  = Fabricate(:admin_access_token)
    reading       = Fabricate(:reading_with_metering_point)
    get_with_token "/api/v1/readings/#{reading.id.to_s}", access_token.token
    expect(response).to have_http_status(200)
  end

  it 'does get a reading as manager' do
    reading       = Fabricate(:reading_with_metering_point_and_manager)
    manager       = reading.metering_point.managers.first
    access_token  = Fabricate(:access_token, resource_owner_id: manager.id)
    get_with_token "/api/v1/readings/#{reading.id.to_s}", access_token.token
    expect(response).to have_http_status(200)
  end

  it 'does not get a reading as stranger' do
    reading       = Fabricate(:reading_with_metering_point)
    access_token  = Fabricate(:access_token)
    get_with_token "/api/v1/readings/#{reading.id.to_s}", access_token.token
    expect(response).to have_http_status(403)
  end


  it 'does creates a reading with token' do
    metering_point = Fabricate(:metering_point_with_manager)
    manager       = metering_point.managers.first
    access_token  = Fabricate(:access_token, resource_owner_id: manager.id)
    reading       = Fabricate.build(:reading)
    request_params = {
      metering_point_id: metering_point.id,
      timestamp: reading.timestamp,
      watt_hour: reading.watt_hour,
      power: reading.power
    }.to_json
    post_with_token "/api/v1/readings", request_params, access_token.token
    expect(response).to have_http_status(201)
    expect(DateTime.parse(json['data']['attributes']['timestamp'])).to eq(reading.timestamp)
    expect(json['data']['attributes']['watt-hour']).to eq(reading.watt_hour)
    expect(json['data']['attributes']['power']).to eq(reading.power)
  end



  it 'does create a correct reading with token' do
    metering_point = Fabricate(:metering_point_with_manager)
    manager       = metering_point.managers.first
    access_token  = Fabricate(:access_token, resource_owner_id: manager.id)

    timestamp = "Wed Apr 13 2016 14:07:35 GMT+0200 (CEST)"
    watt_hour = 80616
    power = 90

    request_params = {
      metering_point_id: metering_point.id,
      timestamp: timestamp,
      watt_hour: watt_hour,
      power: power
    }.to_json

    post_with_token "/api/v1/readings", request_params, access_token.token
    expect(response).to have_http_status(201)

    expect(DateTime.parse(json['data']['attributes']['timestamp'])).to eq("Wed Apr 13 2016 14:07:35 GMT+0200 (CEST)")
    expect(json['data']['attributes']['watt-hour']).to eq(watt_hour)
    expect(json['data']['attributes']['power']).to eq(power)
  end




  it 'does not creates a reading without metering_point_id' do
    metering_point = Fabricate(:metering_point_with_manager)
    manager       = metering_point.managers.first
    access_token  = Fabricate(:access_token, resource_owner_id: manager.id)
    reading       = Fabricate.build(:reading)
    request_params = {
      # metering_point_id: metering_point.id,
      timestamp: reading.timestamp,
      watt_hour: reading.watt_hour,
      power: reading.power
    }.to_json

    post_with_token "/api/v1/readings", request_params, access_token.token
    expect(response).to have_http_status(400)
    expect(json['error']).to eq("metering_point_id is missing")
  end



  it 'does not creates a reading without timestamp' do
    metering_point = Fabricate(:metering_point_with_manager)
    manager       = metering_point.managers.first
    access_token  = Fabricate(:access_token, resource_owner_id: manager.id)
    reading       = Fabricate.build(:reading)
    request_params = {
      metering_point_id: metering_point.id,
      # timestamp: reading.timestamp,
      watt_hour: reading.watt_hour,
      power: reading.power
    }.to_json

    post_with_token "/api/v1/readings", request_params, access_token.token
    expect(response).to have_http_status(400)
    expect(json['error']).to eq("timestamp is missing")
  end


  it 'does not creates a reading without watt_hour' do
    metering_point = Fabricate(:metering_point_with_manager)
    manager       = metering_point.managers.first
    access_token  = Fabricate(:access_token, resource_owner_id: manager.id)
    reading       = Fabricate.build(:reading)
    request_params = {
      metering_point_id: metering_point.id,
      timestamp: reading.timestamp,
      #watt_hour: reading.watt_hour,
      power: reading.power
    }.to_json

    post_with_token "/api/v1/readings", request_params, access_token.token
    expect(response).to have_http_status(400)
    expect(json['error']).to eq("watt_hour is missing")
  end



  it 'does not creates a reading without power' do
    metering_point = Fabricate(:metering_point_with_manager)
    manager       = metering_point.managers.first
    access_token  = Fabricate(:access_token, resource_owner_id: manager.id)
    reading       = Fabricate.build(:reading)
    request_params = {
      metering_point_id: metering_point.id,
      timestamp: reading.timestamp,
      watt_hour: reading.watt_hour,
      #power: reading.power
    }.to_json

    post_with_token "/api/v1/readings", request_params, access_token.token
    expect(response).to have_http_status(400)
    expect(json['error']).to eq("power is missing")
  end


end
