describe "Metering Points API" do

  before(:all) do
    @page_overload = 11
  end

  it 'get world-readable metering point with or without token' do
    access_token      = Fabricate(:access_token)
    metering_point    = Fabricate(:metering_point_readable_by_world)

    get_without_token "/api/v1/metering-points/#{metering_point.id}"
    expect(response).to have_http_status(200)
    get_with_token "/api/v1/metering-points/#{metering_point.id}", access_token.token
    expect(response).to have_http_status(200)
  end

  it 'contains CRUD info' do
    metering_point  = Fabricate(:metering_point)
    access_token    = Fabricate(:admin_access_token)

    get_with_token "/api/v1/metering-points/#{metering_point.id}", access_token.token
    ['readable', 'updateable', 'deletable'].each do |attr|
      expect(json['data']['attributes']).to include(attr)
    end
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


  it 'gets the related comments for the metering point only with token' do
    access_token    = Fabricate(:access_token).token
    metering_point  = Fabricate(:metering_point_readable_by_world)
    user            = Fabricate(:user)
    comment_params  = {
      commentable_id:     metering_point.id,
      commentable_type:   'MeteringPoint',
      user_id:            user.id,
      parent_id:          '',
    }
    comment         = Fabricate(:comment, comment_params)
    comment_params[:parent_id] = comment.id
    comment2        = Fabricate(:comment, comment_params)
    get_without_token "/api/v1/metering-points/#{metering_point.id}/comments"
    expect(response).to have_http_status(401)
    get_with_token "/api/v1/metering-points/#{metering_point.id}/comments", access_token
    expect(response).to have_http_status(200)
    expect(json['data'].last['attributes']['body']).to eq(comment.body)
    expect(json['data'].first['attributes']['body']).to eq(comment2.body)
  end

  it 'paginate comments' do
    access_token    = Fabricate(:access_token).token
    metering_point  = Fabricate(:metering_point_readable_by_world)
    user            = Fabricate(:user)
    comment_params  = {
      commentable_id:     metering_point.id,
      commentable_type:   'MeteringPoint',
      user_id:            user.id,
      parent_id:          '',
    }
    comment         = Fabricate(:comment, comment_params)
    @page_overload.times do
      comment_params[:parent_id] = comment.id
      comment = Fabricate(:comment, comment_params)
    end
    get_with_token "/api/v1/metering-points/#{metering_point.id}/comments", access_token
    expect(response).to have_http_status(200)
    expect(json['meta']['total_pages']).to eq(2)
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

  it 'paginate managers' do
    access_token    = Fabricate(:access_token).token
    metering_point  = Fabricate(:metering_point_readable_by_world)
    @page_overload.times do
      user = Fabricate(:user)
      user.add_role(:manager, metering_point)
    end
    get_with_token "/api/v1/metering-points/#{metering_point.id}/managers", access_token
    expect(response).to have_http_status(200)
    expect(json['meta']['total_pages']).to eq(2)
  end


  it 'gets address of the metering point only with token' do
    access_token    = Fabricate(:access_token).token
    metering_point  = Fabricate(:mp_urbanstr88, readable: 'world')
    address         = metering_point.address
    get_without_token "/api/v1/metering-points/#{metering_point.id}/address"
    expect(response).to have_http_status(401)
    get_with_token "/api/v1/metering-points/#{metering_point.id}/address", access_token
    expect(json['data']['id']).to eq(address.id)
    expect(response).to have_http_status(200)
  end



  it 'gets only accessible profiles for the metering point' do
    metering_point    = Fabricate(:metering_point_readable_by_world)
    access_token      = Fabricate(:access_token_with_friend)
    token_user        = User.find(access_token.resource_owner_id)
    token_user_friend = token_user.friends.first
    token_user_friend.profile.readable = 'friends'
    token_user_friend.profile.save
    community_token   = Fabricate(:access_token)
    community_user    = Fabricate(:user)
    community_user.profile.readable = 'community'
    community_user.profile.save
    world_user        = Fabricate(:user)
    world_user.profile.readable = 'world'
    world_user.profile.save
    token_user_friend.add_role(:member, metering_point)
    community_user.add_role(:member, metering_point)
    world_user.add_role(:member, metering_point)

    get_without_token "/api/v1/metering-points/#{metering_point.id}/members"
    expect(response).to have_http_status(200)
    expect(json['data'].size).to eq(1)
    get_with_token "/api/v1/metering-points/#{metering_point.id}/members", access_token.token
    expect(response).to have_http_status(200)
    expect(json['data'].size).to eq(3)
    get_with_token "/api/v1/metering-points/#{metering_point.id}/members", community_token.token
    expect(response).to have_http_status(200)
    expect(json['data'].size).to eq(2)
  end


  it 'gets meter for the metering point only by managers' do
    metering_point  = Fabricate(:mp_z3)
    access_token    = Fabricate(:access_token)
    token_user      = User.find(access_token.resource_owner_id)
    wrong_token     = Fabricate(:access_token)
    token_user.add_role(:manager, metering_point)

    get_with_token "/api/v1/metering-points/#{metering_point.id}/meter", access_token.token
    expect(response).to have_http_status(200)
    expect(json['data']['id']).to eq(metering_point.meter.id)
    get_with_token "/api/v1/metering-points/#{metering_point.id}/meter", wrong_token.token
    expect(response).to have_http_status(403)
  end



  xit 'does add a metering_point to meter with admin_token' do
  end



end
