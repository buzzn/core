describe "Metering Points API" do

  it 'get world-readable metering point with or without token' do
    access_token      = Fabricate(:access_token).token
    metering_point_id = Fabricate(:metering_point_readable_by_world).id

    get_without_token "/api/v1/metering-points/#{metering_point_id}"
    expect(response).to have_http_status(200)
    get_with_token "/api/v1/metering-points/#{metering_point_id}", access_token
    expect(response).to have_http_status(200)
  end


  it 'does not get a world-unreadable metering point without token' do
    metering_point_id1 = Fabricate(:metering_point_readable_by_friends).id
    metering_point_id2 = Fabricate(:metering_point_readable_by_community).id
    metering_point_id3 = Fabricate(:metering_point_readable_by_members).id

    get_without_token "/api/v1/metering-points/#{metering_point_id1}"
    expect(response).to have_http_status(401)
    get_without_token "/api/v1/metering-points/#{metering_point_id2}"
    expect(response).to have_http_status(401)
    get_without_token "/api/v1/metering-points/#{metering_point_id3}"
    expect(response).to have_http_status(401)
  end

  it 'get community-readable metering point with community token' do
    metering_point_id = Fabricate(:metering_point_readable_by_community).id
    access_token      = Fabricate(:access_token).token

    get_with_token "/api/v1/metering-points/#{metering_point_id}", access_token
    expect(response).to have_http_status(200)
  end

  it 'does not get friends or members readable metering point with community token' do
    metering_point_id1  = Fabricate(:metering_point_readable_by_friends).id
    metering_point_id2  = Fabricate(:metering_point_readable_by_members).id
    access_token        = Fabricate(:access_token).token

    get_with_token "/api/v1/metering-points/#{metering_point_id1}", access_token
    expect(response).to have_http_status(403)
    get_with_token "/api/v1/metering-points/#{metering_point_id2}", access_token
    expect(response).to have_http_status(403)
  end

  it 'get friends-readable metering point by manager friends or by members' do
    metering_point    = Fabricate(:metering_point_readable_by_friends)
    member_token      = Fabricate(:access_token)
    member_user       = User.find(member_token.resource_owner_id)
    access_token      = Fabricate(:access_token_with_friend)
    token_user        = User.find(access_token.resource_owner_id)
    token_user_friend = token_user.friends.first
    token_user_friend.add_role(:manager, metering_point)
    member_user.add_role(:member, metering_point)

    get_with_token "/api/v1/metering-points/#{metering_point.id}", access_token.token
    expect(response).to have_http_status(200)
    get_with_token "/api/v1/metering-points/#{metering_point.id}", member_token.token
    expect(response).to have_http_status(200)
  end

  it 'get members-readable metering point by members but not by manager friends' do
    metering_point    = Fabricate(:metering_point_readable_by_members)
    member_token      = Fabricate(:access_token)
    member_user       = User.find(member_token.resource_owner_id)
    access_token      = Fabricate(:access_token_with_friend)
    token_user        = User.find(access_token.resource_owner_id)
    token_user_friend = token_user.friends.first
    token_user_friend.add_role(:manager, metering_point)
    member_user.add_role(:member, metering_point)

    get_with_token "/api/v1/metering-points/#{metering_point.id}", access_token.token
    expect(response).to have_http_status(403)
    get_with_token "/api/v1/metering-points/#{metering_point.id}", member_token.token
    expect(response).to have_http_status(200)
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


  it 'gets the related comments for the metering point only with token' do
    access_token    = Fabricate(:access_token).token
    metering_point  = Fabricate(:metering_point_readable_by_world)
    user            = Fabricate(:user)
    comment         = Comment.build_from(metering_point, user.id, 'Hola!', '')
    comment.save
    comment2        = Comment.build_from(metering_point, user.id, '2nd comment', comment.id)
    comment2.save
    get_without_token "/api/v1/metering-points/#{metering_point.id}/comments"
    expect(response).to have_http_status(401)
    get_with_token "/api/v1/metering-points/#{metering_point.id}/comments", access_token
    expect(response).to have_http_status(200)
    expect(json.last['body']).to eq('Hola!')
    expect(json.first['body']).to eq('2nd comment')
  end


  it 'gets the related chart for the metering point' do
    metering_point = Fabricate(:metering_point_readable_by_world)
    get_without_token "/api/v1/metering-points/#{metering_point.id}/chart"
    expect(response).to have_http_status(400)
    expect(json['error']).to eq('resolution_format is missing')
    request_params = {
      resolution_format: 'month_to_days'
    }
    get_without_token "/api/v1/metering-points/#{metering_point.id}/chart", request_params
    expect(response).to have_http_status(200)
  end


  it 'gets the related managers for the metering point only with token' do
    access_token    = Fabricate(:access_token).token
    metering_point  = Fabricate(:metering_point_with_manager, readable: 'world')
    manager         = metering_point.managers.first
    get_without_token "/api/v1/metering-points/#{metering_point.id}/managers"
    expect(response).to have_http_status(401)
    get_with_token "/api/v1/metering-points/#{metering_point.id}/managers", access_token
    expect(json['data'].first['id']).to eq(manager.id)
    expect(response).to have_http_status(200)
  end


  it 'gets address of the metering point' do
    metering_point  = Fabricate(:mp_urbanstr88, readable: 'world')
    address         = metering_point.address
    get_without_token "/api/v1/metering-points/#{metering_point.id}/address"
    expect(json['id']).to eq(address.id)
    expect(response).to have_http_status(200)
  end





end
