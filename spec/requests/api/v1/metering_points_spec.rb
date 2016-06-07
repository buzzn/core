describe "Metering Points API" do


  it 'does not gets a metering_point without token' do
    metering_point = Fabricate(:metering_point)
    get_without_token "/api/v1/metering-points/#{metering_point.id}"
    expect(response).to have_http_status(401)
  end



  it 'does gets a metering_point with admin token' do
    access_token  = Fabricate(:admin_access_token)
    metering_point = Fabricate(:metering_point)
    get_with_token "/api/v1/metering-points/#{metering_point.id}", access_token.token
    expect(response).to have_http_status(200)
  end



  it 'does gets a metering_point as friend' do
    access_token = Fabricate(:access_token_with_friend_and_metering_point)

    metering_point1 = MeteringPoint.first
    metering_point2 = MeteringPoint.last

    get_with_token "/api/v1/metering-points/#{metering_point2.id}", access_token.token
    expect(response).to have_http_status(200)

    get_with_token "/api/v1/metering-points/#{metering_point1.id}", access_token.token
    expect(response).to have_http_status(200)

    metering_point3 = Fabricate(:metering_point) # metering_point from unknown user
    get_with_token "/api/v1/metering-points/#{metering_point3.id}", access_token.token
    expect(response).to have_http_status(403)
  end



  it 'does creates a metering_point with admin token' do
    access_token = Fabricate(:admin_access_token)
    meter        = Fabricate(:meter)
    metering_point = Fabricate.build(:metering_point)

    request_params = {
      uid:  metering_point.uid,
      mode: metering_point.mode,
      readable: metering_point.readable,
      name: metering_point.name,
      meter_id: meter.id
    }.to_json

    post_with_token "/api/v1/metering-points", request_params, access_token.token

    expect(response).to have_http_status(201)
    expect(json['data']['attributes']['uid']).to eq(metering_point.uid)
    expect(json['data']['attributes']['mode']).to eq(metering_point.mode)
    expect(json['data']['attributes']['readable']).to eq(metering_point.readable)
    expect(json['data']['attributes']['meter-id']).to eq(meter.id)
    expect(json['data']['attributes']['name']).to eq(metering_point.name)
  end


  it 'does not creates a metering_point without token' do
    meter        = Fabricate.build(:meter)
    metering_point = Fabricate.build(:metering_point)

    request_params = {
      uid:  metering_point.uid,
      mode: metering_point.mode,
      readable: metering_point.readable,
      name: metering_point.name,
      meter_id: meter.id
    }.to_json

    post_without_token "/api/v1/metering-points", request_params

    expect(response).to have_http_status(401)
  end


  it 'does creates a metering_point with token' do
    access_token = Fabricate(:access_token)
    meter        = Fabricate(:meter)
    metering_point = Fabricate.build(:metering_point)

    request_params = {
      uid:  metering_point.uid,
      mode: metering_point.mode,
      readable: metering_point.readable,
      name: metering_point.name,
      meter_id: meter.id
    }.to_json

    post_with_token "/api/v1/metering-points", request_params, access_token.token

    expect(response).to have_http_status(201)
    expect(json['data']['attributes']['uid']).to eq(metering_point.uid)
    expect(json['data']['attributes']['mode']).to eq(metering_point.mode)
    expect(json['data']['attributes']['readable']).to eq(metering_point.readable)
    expect(json['data']['attributes']['meter-id']).to eq(meter.id)
    expect(json['data']['attributes']['name']).to eq(metering_point.name)
  end



  it 'does update a metering_point with token' do
    metering_point = Fabricate(:metering_point_with_manager)
    meter        = Fabricate(:meter)
    manager       = metering_point.managers.first
    access_token  = Fabricate(:access_token, resource_owner_id: manager.id)

    request_params = {
      id: metering_point.id,
      uid: metering_point.uid,
      mode: metering_point.mode,
      readable: metering_point.readable,
      name: "#{metering_point.name} updated",
      meter_id: meter.id
    }.to_json

    put_with_token "/api/v1/metering-points", request_params, access_token.token

    expect(response).to have_http_status(200)
    expect(json['data']['attributes']['uid']).to eq(metering_point.uid)
    expect(json['data']['attributes']['mode']).to eq(metering_point.mode)
    expect(json['data']['attributes']['readable']).to eq(metering_point.readable)
    expect(json['data']['attributes']['meter-id']).to eq(meter.id)
    expect(json['data']['attributes']['name']).to eq("#{metering_point.name} updated")
  end

  

  it 'does update a metering_point with admin_token' do
    metering_point = Fabricate(:metering_point_with_manager)
    access_token  = Fabricate(:admin_access_token)
    meter        = Fabricate(:meter)

    request_params = {
      id: metering_point.id,
      uid: metering_point.uid,
      mode: metering_point.mode,
      readable: metering_point.readable,
      name: "#{metering_point.name} updated",
      meter_id: meter.id
    }.to_json
    put_with_token "/api/v1/metering-points", request_params, access_token.token

    expect(response).to have_http_status(200)
    expect(json['data']['attributes']['uid']).to eq(metering_point.uid)
    expect(json['data']['attributes']['mode']).to eq(metering_point.mode)
    expect(json['data']['attributes']['readable']).to eq(metering_point.readable)
    expect(json['data']['attributes']['meter-id']).to eq(meter.id)
    expect(json['data']['attributes']['name']).to eq("#{metering_point.name} updated")
  end



  it 'does not update a metering_point without token' do
    metering_point = Fabricate(:metering_point_with_manager)
    meter          = Fabricate(:meter)

    request_params = {
      id: metering_point.id,
      uid: metering_point.uid,
      mode: metering_point.mode,
      readable: metering_point.readable,
      name: "#{metering_point.name} updated",
      meter_id: meter.id

    }.to_json
    put_without_token "/api/v1/metering-points", request_params

    expect(response).to have_http_status(401)
  end



  it 'does delete a metering_point with admin_token' do
    metering_point = Fabricate(:metering_point)
    access_token  = Fabricate(:admin_access_token)
    delete_with_token "/api/v1/metering-points/#{metering_point.id}", access_token.token
    expect(response).to have_http_status(204)
  end




end
