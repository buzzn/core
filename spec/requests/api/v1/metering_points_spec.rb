describe "Metering Points API" do

  before(:all) do
    @page_overload = 11
  end

  it 'get world-readable metering point with or without token' do
    access_token      = Fabricate(:public_access_token)
    metering_point    = Fabricate(:metering_point_readable_by_world)

    get_without_token "/api/v1/metering-points/#{metering_point.id}"
    expect(response).to have_http_status(200)
    get_with_token "/api/v1/metering-points/#{metering_point.id}", access_token.token
    expect(response).to have_http_status(200)
  end

  it 'contains CRUD info' do
    metering_point  = Fabricate(:metering_point)
    access_token    = Fabricate(:full_access_token_as_admin)

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
    expect(response).to have_http_status(403)
    get_without_token "/api/v1/metering-points/#{metering_point_id2}"
    expect(response).to have_http_status(403)
    get_without_token "/api/v1/metering-points/#{metering_point_id3}"
    expect(response).to have_http_status(403)
  end

  it 'get community-readable metering point with community token' do
    metering_point_id = Fabricate(:metering_point_readable_by_community).id
    access_token      = Fabricate(:public_access_token)

    get_with_token "/api/v1/metering-points/#{metering_point_id}", access_token.token
    expect(response).to have_http_status(200)
  end

  it 'does not get friends or members readable metering point with community token' do
    metering_point_id1  = Fabricate(:metering_point_readable_by_friends).id
    metering_point_id2  = Fabricate(:metering_point_readable_by_members).id
    access_token        = Fabricate(:public_access_token)

    get_with_token "/api/v1/metering-points/#{metering_point_id1}", access_token.token
    expect(response).to have_http_status(403)
    get_with_token "/api/v1/metering-points/#{metering_point_id2}", access_token.token
    expect(response).to have_http_status(403)
  end

  it 'get friends-readable metering point by manager friends or by members' do
    metering_point    = Fabricate(:metering_point_readable_by_friends)
    member_token      = Fabricate(:public_access_token)
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
    member_token      = Fabricate(:public_access_token)
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


  it 'does gets a metering_point with full access token as admin' do
    access_token  = Fabricate(:full_access_token_as_admin)
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



  it 'does creates a metering_point with full access token as admin' do
    access_token = Fabricate(:full_access_token_as_admin)
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
    access_token = Fabricate(:public_access_token)
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
    access_token  = Fabricate(:public_access_token, resource_owner_id: manager.id)

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



  it 'does update a metering_point with full access token as admin' do
    metering_point = Fabricate(:metering_point_with_manager)
    access_token  = Fabricate(:full_access_token_as_admin)
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



  it 'does delete a metering_point with manager_token' do
    metering_point = Fabricate(:metering_point)
    access_token  = Fabricate(:full_access_token_as_admin)
    delete_with_token "/api/v1/metering-points/#{metering_point.id}", access_token.token
    expect(response).to have_http_status(204)
  end


  it 'gets the related comments for the metering point only with token' do
    access_token    = Fabricate(:public_access_token)
    metering_point  = Fabricate(:world_metering_point_with_two_comments)
    user            = Fabricate(:user)
    comments        = metering_point.comment_threads

    get_without_token "/api/v1/metering-points/#{metering_point.id}/comments"
    expect(response).to have_http_status(401)
    get_with_token "/api/v1/metering-points/#{metering_point.id}/comments", access_token.token
    expect(response).to have_http_status(200)
    comments.each do |comment|
      expect(json['data'].find{ |c| c['id'] == comment.id }['attributes']['body']).to eq(comment.body)
    end
  end

  it 'paginate comments' do
    access_token    = Fabricate(:public_access_token)
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
    get_with_token "/api/v1/metering-points/#{metering_point.id}/comments", access_token.token
    expect(response).to have_http_status(200)
    expect(json['meta']['total_pages']).to eq(2)
  end


  it 'gets the related managers for the metering point only with token' do
    access_token    = Fabricate(:public_access_token)
    metering_point  = Fabricate(:metering_point_with_manager, readable: 'world')
    manager         = metering_point.managers.first
    get_without_token "/api/v1/metering-points/#{metering_point.id}/managers"
    expect(response).to have_http_status(401)
    get_with_token "/api/v1/metering-points/#{metering_point.id}/managers", access_token.token
    expect(json['data'].first['id']).to eq(manager.id)
    expect(response).to have_http_status(200)
  end

  it 'paginate managers' do
    access_token    = Fabricate(:public_access_token)
    metering_point  = Fabricate(:metering_point_readable_by_world)
    @page_overload.times do
      user = Fabricate(:user)
      user.add_role(:manager, metering_point)
    end
    get_with_token "/api/v1/metering-points/#{metering_point.id}/managers", access_token.token
    expect(response).to have_http_status(200)
    expect(json['meta']['total_pages']).to eq(2)
  end

  it 'does not add/delete metering point manager or member without token' do
    metering_point  = Fabricate(:metering_point_readable_by_world)
    user            = Fabricate(:user)
    params = {
      user_id: user.id
    }

    post_without_token "/api/v1/metering-points/#{metering_point.id}/managers", params.to_json
    expect(response).to have_http_status(401)
    delete_without_token "/api/v1/metering-points/#{metering_point.id}/managers/#{user.id}"
    expect(response).to have_http_status(401)
    post_without_token "/api/v1/metering-points/#{metering_point.id}/members", params.to_json
    expect(response).to have_http_status(401)
    delete_without_token "/api/v1/metering-points/#{metering_point.id}/members/#{user.id}"
    expect(response).to have_http_status(401)
  end

  it 'adds metering point manager only with manager or admin with full access token' do
    metering_point  = Fabricate(:metering_point_readable_by_world)
    user1           = Fabricate(:user)
    user2           = Fabricate(:user)
    admin_token     = Fabricate(:full_access_token_as_admin)
    manager_token   = Fabricate(:public_access_token)
    manager         = User.find(manager_token.resource_owner_id)
    manager.add_role(:manager, metering_point)
    member_token    = Fabricate(:public_access_token)
    member          = User.find(member_token.resource_owner_id)
    member.add_role(:member, metering_point)
    params = {
      user_id: user1.id
    }

    post_with_token "/api/v1/metering-points/#{metering_point.id}/managers", params.to_json, member_token.token
    expect(response).to have_http_status(403)
    post_with_token "/api/v1/metering-points/#{metering_point.id}/managers", params.to_json, manager_token.token
    expect(response).to have_http_status(201)
    get_with_token "/api/v1/metering-points/#{metering_point.id}/managers", admin_token.token
    expect(json['data'].size).to eq(2)
    params[:user_id] = user2.id
    post_with_token "/api/v1/metering-points/#{metering_point.id}/managers", params.to_json, admin_token.token
    expect(response).to have_http_status(201)
    get_with_token "/api/v1/metering-points/#{metering_point.id}/managers", admin_token.token
    expect(json['data'].size).to eq(3)
  end

  it 'creates activity when adding metering point manager' do
    user            = Fabricate(:user)
    admin_token     = Fabricate(:full_access_token_as_admin)
    admin           = User.find(admin_token.resource_owner_id)
    metering_point  = Fabricate(:metering_point)
    params = {
      user_id: user.id
    }

    post_with_token "/api/v1/metering-points/#{metering_point.id}/managers", params.to_json, admin_token.token
    activities      = PublicActivity::Activity.where({ owner_type: 'User', owner_id: admin.id })
    expect(activities.first.key).to eq('user.appointed_metering_point_manager')
  end

  it 'removes metering point manager only for current user or with full token' do
    metering_point  = Fabricate(:metering_point_readable_by_world)
    user            = Fabricate(:user)
    user.add_role(:manager, metering_point)
    admin_token     = Fabricate(:full_access_token_as_admin)
    manager_token   = Fabricate(:public_access_token)
    manager         = User.find(manager_token.resource_owner_id)
    manager.add_role(:manager, metering_point)
    member_token    = Fabricate(:public_access_token)
    member          = User.find(member_token.resource_owner_id)
    member.add_role(:member, metering_point)

    get_with_token "/api/v1/metering-points/#{metering_point.id}/managers", admin_token.token
    expect(json['data'].size).to eq(2)
    delete_with_token "/api/v1/metering-points/#{metering_point.id}/managers/#{user.id}", member_token.token
    expect(response).to have_http_status(403)
    delete_with_token "/api/v1/metering-points/#{metering_point.id}/managers/#{user.id}", manager_token.token
    expect(response).to have_http_status(403)
    delete_with_token "/api/v1/metering-points/#{metering_point.id}/managers/#{user.id}", admin_token.token
    expect(response).to have_http_status(200)
    get_with_token "/api/v1/metering-points/#{metering_point.id}/managers", admin_token.token
    expect(json['data'].size).to eq(1)
    delete_with_token "/api/v1/metering-points/#{metering_point.id}/managers/#{manager.id}", manager_token.token
    expect(response).to have_http_status(200)
    get_with_token "/api/v1/metering-points/#{metering_point.id}/managers", admin_token.token
    expect(json['data'].size).to eq(0)
  end

  it 'adds metering point member with member, manager or manager token' do
    metering_point  = Fabricate(:metering_point_readable_by_world)
    user1           = Fabricate(:user)
    user2           = Fabricate(:user)
    user3           = Fabricate(:user)
    admin_token     = Fabricate(:full_access_token_as_admin)
    manager_token   = Fabricate(:public_access_token)
    manager         = User.find(manager_token.resource_owner_id)
    manager.add_role(:manager, metering_point)
    member_token    = Fabricate(:public_access_token)
    member          = User.find(member_token.resource_owner_id)
    member.add_role(:member, metering_point)
    params = {
      user_id: user1.id
    }

    post_with_token "/api/v1/metering-points/#{metering_point.id}/members", params.to_json, member_token.token
    expect(response).to have_http_status(201)
    get_with_token "/api/v1/metering-points/#{metering_point.id}/members", admin_token.token
    expect(json['data'].size).to eq(2)
    params[:user_id] = user2.id
    post_with_token "/api/v1/metering-points/#{metering_point.id}/members", params.to_json, manager_token.token
    expect(response).to have_http_status(201)
    get_with_token "/api/v1/metering-points/#{metering_point.id}/members", admin_token.token
    expect(json['data'].size).to eq(3)
    params[:user_id] = user3.id
    post_with_token "/api/v1/metering-points/#{metering_point.id}/members", params.to_json, admin_token.token
    expect(response).to have_http_status(201)
    get_with_token "/api/v1/metering-points/#{metering_point.id}/members", admin_token.token
    expect(json['data'].size).to eq(4)
  end

  it 'creates activity when adding metering point member' do
    user            = Fabricate(:user)
    admin_token     = Fabricate(:full_access_token_as_admin)
    metering_point  = Fabricate(:metering_point)
    params = {
      user_id: user.id
    }

    post_with_token "/api/v1/metering-points/#{metering_point.id}/members", params.to_json, admin_token.token
    activities      = PublicActivity::Activity.where({ owner_type: 'User', owner_id: user.id })
    expect(activities.first.key).to eq('metering_point_user_membership.create')
  end

  it 'removes metering point member only for current user, manager or with full token' do
    metering_point  = Fabricate(:metering_point_readable_by_world)
    user1           = Fabricate(:user)
    user1.add_role(:member, metering_point)
    user2           = Fabricate(:user)
    user2.add_role(:member, metering_point)
    admin_token     = Fabricate(:full_access_token_as_admin)
    manager_token   = Fabricate(:public_access_token)
    manager         = User.find(manager_token.resource_owner_id)
    manager.add_role(:manager, metering_point)
    member_token    = Fabricate(:public_access_token)
    member          = User.find(member_token.resource_owner_id)
    member.add_role(:member, metering_point)

    get_with_token "/api/v1/metering-points/#{metering_point.id}/members", admin_token.token
    expect(json['data'].size).to eq(3)
    delete_with_token "/api/v1/metering-points/#{metering_point.id}/members/#{user1.id}", member_token.token
    expect(response).to have_http_status(403)
    delete_with_token "/api/v1/metering-points/#{metering_point.id}/members/#{member.id}", member_token.token
    expect(response).to have_http_status(200)
    get_with_token "/api/v1/metering-points/#{metering_point.id}/members", admin_token.token
    expect(json['data'].size).to eq(2)
    delete_with_token "/api/v1/metering-points/#{metering_point.id}/members/#{user1.id}", manager_token.token
    expect(response).to have_http_status(200)
    get_with_token "/api/v1/metering-points/#{metering_point.id}/members", admin_token.token
    expect(json['data'].size).to eq(1)
    delete_with_token "/api/v1/metering-points/#{metering_point.id}/members/#{user2.id}", admin_token.token
    expect(response).to have_http_status(200)
    get_with_token "/api/v1/metering-points/#{metering_point.id}/members", admin_token.token
    expect(json['data'].size).to eq(0)
  end

  it 'creates activity when removing metering point member' do
    user            = Fabricate(:user)
    admin_token     = Fabricate(:full_access_token_as_admin)
    metering_point  = Fabricate(:metering_point)

    delete_with_token "/api/v1/metering-points/#{metering_point.id}/members/#{user.id}", admin_token.token
    activities      = PublicActivity::Activity.where({ owner_type: 'User', owner_id: user.id })
    expect(activities.first.key).to eq('metering_point_user_membership.cancel')
  end


  it 'gets address of the metering point only with token' do
    access_token    = Fabricate(:public_access_token)
    metering_point  = Fabricate(:mp_urbanstr88, readable: 'world')
    address         = metering_point.address
    get_without_token "/api/v1/metering-points/#{metering_point.id}/address"
    expect(response).to have_http_status(401)
    get_with_token "/api/v1/metering-points/#{metering_point.id}/address", access_token.token
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
    community_token   = Fabricate(:public_access_token)
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
    access_token    = Fabricate(:public_access_token)
    token_user      = User.find(access_token.resource_owner_id)
    wrong_token     = Fabricate(:public_access_token)
    token_user.add_role(:manager, metering_point)

    get_with_token "/api/v1/metering-points/#{metering_point.id}/meter", access_token.token
    expect(response).to have_http_status(200)
    expect(json['data']['id']).to eq(metering_point.meter.id)
    get_with_token "/api/v1/metering-points/#{metering_point.id}/meter", wrong_token.token
    expect(response).to have_http_status(403)
  end



  xit 'adds a metering_point to meter with full access token' do
  end



end
