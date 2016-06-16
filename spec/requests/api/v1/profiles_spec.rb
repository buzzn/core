describe "Profiles API" do


  it 'does not get all profiles with regular token or without token' do
    Fabricate(:profile)
    Fabricate(:profile)
    access_token = Fabricate(:access_token).token
    get_with_token '/api/v1/profiles', {}, access_token
    expect(response).to have_http_status(403)
    get_without_token '/api/v1/profiles'
    expect(response).to have_http_status(401)
  end

  it 'get all profiles with admin token' do
    Fabricate(:profile)
    Fabricate(:profile)
    access_token = Fabricate(:admin_access_token).token
    get_with_token '/api/v1/profiles', {}, access_token
    expect(response).to have_http_status(200)
  end


  it 'does not gets a profile without token' do
    profile = Fabricate(:profile)
    get_without_token "/api/v1/profiles/#{profile.id}"
    expect(response).to have_http_status(403)
  end


  it 'does not gets a profile as foreigner' do
    access_token = Fabricate(:access_token)
    profile = Fabricate(:profile)
    get_with_token "/api/v1/profiles/#{profile.id}", access_token.token
    expect(response).to have_http_status(403)
  end

  it 'get a world-readable profile as foreigner' do
    access_token = Fabricate(:access_token)
    profile = Fabricate(:world_readable_profile)
    get_with_token "/api/v1/profiles/#{profile.id}", access_token.token
    expect(response).to have_http_status(200)
    get_without_token "/api/v1/profiles/#{profile.id}"
    expect(response).to have_http_status(200)
  end

  it 'does not get a community-readable profile as foreigner' do
    profile = Fabricate(:community_readable_profile)
    get_without_token "/api/v1/profiles/#{profile.id}"
    expect(response).to have_http_status(403)
  end


  it 'does gets a profile as admin' do
    access_token  = Fabricate(:admin_access_token)
    profile       = Fabricate(:profile)
    get_with_token "/api/v1/profiles/#{profile.id}", access_token.token
    expect(response).to have_http_status(200)
  end


  it 'does gets a profile as friend' do
    access_token      = Fabricate(:access_token_with_friend)
    token_user        = User.find(access_token.resource_owner_id)
    token_user_friend = token_user.friends.first
    get_with_token "/api/v1/profiles/#{token_user_friend.profile.id}", access_token.token
    expect(response).to have_http_status(200)
  end

  it 'does not get friend-readable profile as foreigner' do
    access_token      = Fabricate(:access_token_with_friend)
    wrong_token       = Fabricate(:access_token).token
    token_user        = User.find(access_token.resource_owner_id)
    token_user_friend = token_user.friends.first
    get_with_token "/api/v1/profiles/#{token_user_friend.profile.id}", wrong_token
    expect(response).to have_http_status(403)
    get_without_token "/api/v1/profiles/#{token_user_friend.profile.id}"
    expect(response).to have_http_status(403)
  end


  it 'does not creates a profile as simple user' do
    access_token = Fabricate(:access_token)
    profile = Fabricate.build(:profile)

    request_params = {
      user_name:  profile.user_name,
      first_name: profile.first_name,
      last_name:  profile.last_name
    }.to_json

    post_with_token "/api/v1/profiles", request_params, access_token.token
    expect(response).to have_http_status(403)
  end


  it 'creates a profile as admin' do
    access_token = Fabricate(:admin_access_token)
    profile = Fabricate.build(:profile)

    request_params = {
      user_name:  profile.user_name,
      first_name: profile.first_name,
      last_name:  profile.last_name
    }.to_json
    post_with_token "/api/v1/profiles", request_params, access_token.token

    expect(response).to have_http_status(201)
    expect(json['data']['attributes']['first-name']).to eq(profile.first_name)
    expect(json['data']['attributes']['last-name']).to eq(profile.last_name)
  end

  it 'get profile groups readable by world with or without token' do
    access_token      = Fabricate(:access_token)
    token_user        = User.find(access_token.resource_owner_id)
    profile           = token_user.profile
    profile.readable  = 'world'
    profile.save
    group             = Fabricate(:group)
    metering_point    = Fabricate(:metering_point_readable_by_world)
    token_user.add_role(:member, metering_point)
    group.metering_points << metering_point

    get_with_token "/api/v1/profiles/#{profile.id}/groups", access_token.token
    expect(response).to have_http_status(200)
    expect(json['data'].first['id']).to eq(group.id)
    get_without_token "/api/v1/profiles/#{profile.id}/groups"
    expect(response).to have_http_status(200)
    expect(json['data'].first['id']).to eq(group.id)
  end

  it 'does not get community-readable groups for world-readable profile without token' do
    access_token      = Fabricate(:access_token)
    token_user        = User.find(access_token.resource_owner_id)
    profile           = token_user.profile
    profile.readable  = 'world'
    profile.save
    group             = Fabricate(:group_readable_by_community)
    metering_point    = Fabricate(:metering_point_readable_by_world)
    token_user.add_role(:member, metering_point)
    group.metering_points << metering_point

    get_without_token "/api/v1/profiles/#{profile.id}/groups"
    expect(response).to have_http_status(200)
    expect(json['data']).to eq([])
  end

  it 'get community-readable groups for world-readable profile with token' do
    access_token      = Fabricate(:access_token)
    token_user        = User.find(access_token.resource_owner_id)
    profile           = token_user.profile
    profile.readable  = 'world'
    profile.save
    group             = Fabricate(:group_readable_by_community)
    metering_point    = Fabricate(:metering_point_readable_by_world)
    token_user.add_role(:member, metering_point)
    group.metering_points << metering_point

    get_with_token "/api/v1/profiles/#{profile.id}/groups", access_token.token
    expect(response).to have_http_status(200)
    expect(json['data'].first['id']).to eq(group.id)
  end

  it 'get friends-readable groups for world-readable profile with friend token' do
    access_token      = Fabricate(:access_token_with_friend)
    token_user        = User.find(access_token.resource_owner_id)
    token_user_friend = token_user.friends.first
    profile           = token_user_friend.profile
    profile.readable  = 'world'
    profile.save
    group             = Fabricate(:group_readable_by_friends)
    metering_point    = Fabricate(:metering_point_readable_by_world)
    token_user_friend.add_role(:member, metering_point)
    group.metering_points << metering_point

    get_with_token "/api/v1/profiles/#{profile.id}/groups", access_token.token
    expect(response).to have_http_status(200)
    expect(json['data'].first['id']).to eq(group.id)
  end

  it 'does not get friends-readable groups for world-readable profile with or without token' do
    access_token      = Fabricate(:access_token)
    wrong_token       = Fabricate(:access_token).token
    token_user        = User.find(access_token.resource_owner_id)
    profile           = token_user.profile
    profile.readable  = 'world'
    profile.save
    group             = Fabricate(:group_readable_by_friends)
    metering_point    = Fabricate(:metering_point_readable_by_world)
    token_user.add_role(:member, metering_point)
    group.metering_points << metering_point

    get_without_token "/api/v1/profiles/#{profile.id}/groups"
    expect(response).to have_http_status(200)
    expect(json['data']).to eq([])
    get_with_token "/api/v1/profiles/#{profile.id}/groups", wrong_token
    expect(response).to have_http_status(200)
    expect(json['data']).to eq([])
  end


end
