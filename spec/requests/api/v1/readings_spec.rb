describe "Readings API" do

  # READ

  it 'does not gets a reading without token' do
    reading = Fabricate(:reading)
    get_without_token "/api/v1/readings/#{reading.id}"
    expect(response).to have_http_status(401)
  end

  it 'does gets a reading as admin' do
    access_token  = Fabricate(:admin_access_token)
    reading       = Fabricate(:reading_with_easy_meter_q3d_and_metering_point)
    get_with_token "/api/v1/readings/#{reading.id}", access_token.token
    expect(response).to have_http_status(200)
  end

  it 'does get a reading as manager' do
    reading       = Fabricate(:reading_with_easy_meter_q3d_and_manager)
    manager       = reading.meter.managers.first
    access_token  = Fabricate(:access_token, resource_owner_id: manager.id)
    get_with_token "/api/v1/readings/#{reading.id}", access_token.token
    expect(response).to have_http_status(200)
  end

  it 'does not get a reading as stranger' do
    reading       = Fabricate(:reading_with_easy_meter_q3d_and_metering_point)
    access_token  = Fabricate(:access_token)
    get_with_token "/api/v1/readings/#{reading.id}", access_token.token
    expect(response).to have_http_status(403)
  end

  # CREATE

  it 'does creates a reading with token' do
    meter         = Fabricate(:easy_meter_q3d_with_manager)
    manager       = meter.managers.first
    access_token  = Fabricate(:access_token, resource_owner_id: manager.id)
    reading       = Fabricate.build(:reading)
    request_params = {
      meter_id: meter.id,
      timestamp: reading.timestamp,
      energy_a_milliwatt_hour: reading.energy_a_milliwatt_hour,
      energy_b_milliwatt_hour: reading.energy_b_milliwatt_hour,
      power_a_milliwatt: reading.power_a_milliwatt
    }.to_json
    post_with_token "/api/v1/readings", request_params, access_token.token
    expect(response).to have_http_status(201)
    expect(DateTime.parse(json['data']['attributes']['timestamp'])).to eq(reading.timestamp)
    expect(json['data']['attributes']['energy-a-milliwatt-hour']).to eq(reading.energy_a_milliwatt_hour)
    expect(json['data']['attributes']['energy-b-milliwatt-hour']).to eq(reading.energy_b_milliwatt_hour)
    expect(json['data']['attributes']['power-a-milliwatt']).to eq(reading.power_a_milliwatt )
  end



  it 'does create a correct reading with token' do
    meter         = Fabricate(:easy_meter_q3d_with_manager)
    manager       = meter.managers.first
    access_token  = Fabricate(:access_token, resource_owner_id: manager.id)

    timestamp = "Wed Apr 13 2016 14:07:35 GMT+0200 (CEST)"
    energy_a_milliwatt_hour = 80616
    power_a_milliwatt = 90

    request_params = {
      meter_id: meter.id,
      timestamp: timestamp,
      energy_a_milliwatt_hour: energy_a_milliwatt_hour,
      power_a_milliwatt: power_a_milliwatt
    }.to_json

    post_with_token "/api/v1/readings", request_params, access_token.token
    expect(response).to have_http_status(201)

    expect(DateTime.parse(json['data']['attributes']['timestamp'])).to eq("Wed Apr 13 2016 14:07:35 GMT+0200 (CEST)")
    expect(json['data']['attributes']['energy-a-milliwatt-hour']).to eq(energy_a_milliwatt_hour)
    expect(json['data']['attributes']['power-a-milliwatt']).to eq(power_a_milliwatt)
  end




  it 'does not creates a reading without metering_point_id' do
    meter         = Fabricate(:easy_meter_q3d_with_manager)
    manager       = meter.managers.first
    access_token  = Fabricate(:access_token, resource_owner_id: manager.id)
    reading       = Fabricate.build(:reading)
    request_params = {
      # metering_point_id: metering_point.id,
      timestamp: reading.timestamp,
      energy_a_milliwatt_hour: reading.energy_a_milliwatt_hour,
      power_a_milliwatt: reading.power_a_milliwatt
    }.to_json

    post_with_token "/api/v1/readings", request_params, access_token.token
    expect(response).to have_http_status(400)
    expect(json['error']).to eq("meter_id is missing")
  end



  it 'does not creates a reading without timestamp' do
    meter         = Fabricate(:easy_meter_q3d_with_manager)
    manager       = meter.managers.first
    access_token  = Fabricate(:access_token, resource_owner_id: manager.id)
    reading       = Fabricate.build(:reading)
    request_params = {
      meter_id: meter.id,
      # timestamp: reading.timestamp,
      energy_a_milliwatt_hour: reading.energy_a_milliwatt_hour,
      power_a_milliwatt: reading.power_a_milliwatt
    }.to_json

    post_with_token "/api/v1/readings", request_params, access_token.token
    expect(response).to have_http_status(400)
    expect(json['error']).to eq("timestamp is missing")
  end


  it 'does not creates a reading without energy_a_milliwatt_hour' do
    meter         = Fabricate(:easy_meter_q3d_with_manager)
    manager       = meter.managers.first
    access_token  = Fabricate(:access_token, resource_owner_id: manager.id)
    reading       = Fabricate.build(:reading)
    request_params = {
      meter_id: meter.id,
      timestamp: reading.timestamp,
      #energy_a_milliwatt_hour: reading.energy_a_milliwatt_hour,
      power_a_milliwatt: reading.power_a_milliwatt
    }.to_json

    post_with_token "/api/v1/readings", request_params, access_token.token
    expect(response).to have_http_status(400)
    expect(json['error']).to eq("energy_a_milliwatt_hour is missing")
  end



  it 'does not creates a reading without milliwatt' do
    meter         = Fabricate(:easy_meter_q3d_with_manager)
    manager       = meter.managers.first
    access_token  = Fabricate(:access_token, resource_owner_id: manager.id)
    reading       = Fabricate.build(:reading)
    request_params = {
      meter_id: meter.id,
      timestamp: reading.timestamp,
      energy_a_milliwatt_hour: reading.energy_a_milliwatt_hour,
      #power_a_milliwatt: reading.power_a_milliwatt
    }.to_json

    post_with_token "/api/v1/readings", request_params, access_token.token
    expect(response).to have_http_status(400)
    expect(json['error']).to eq("power_a_milliwatt is missing")
  end


  xit 'does not update a reading' do
  end

  xit 'does not delete a reading' do
  end




end
