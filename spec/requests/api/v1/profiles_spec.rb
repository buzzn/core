describe "Profiles API" do

  before(:all) do
    @page_overload = 11
  end


  it 'does not get all profiles with regular token or without token' do
    Fabricate(:profile)
    Fabricate(:profile)
    access_token = Fabricate(:public_access_token)
    get_with_token '/api/v1/profiles', {}, access_token.token
    expect(response).to have_http_status(403)
    get_without_token '/api/v1/profiles'
    expect(response).to have_http_status(401)
  end

  it 'get all profiles with manager token' do
    Fabricate(:profile)
    Fabricate(:profile)
    access_token = Fabricate(:full_access_token_as_admin)
    get_with_token '/api/v1/profiles', {}, access_token.token
    expect(response).to have_http_status(200)
  end

  it 'contains CRUD info' do
    Fabricate(:profile)
    access_token = Fabricate(:full_access_token_as_admin)

    get_with_token '/api/v1/profiles', access_token.token
    ['readable', 'updateable', 'deletable'].each do |attr|
      expect(json['data'].first['attributes']).to include(attr)
    end
  end

  it 'paginate profiles with manager token' do
    @page_overload.times do
      Fabricate(:profile)
    end
    access_token = Fabricate(:full_access_token_as_admin)
    get_with_token '/api/v1/profiles', {}, access_token.token
    expect(response).to have_http_status(200)
    expect(json['meta']['total_pages']).to eq(2)
  end


  it 'gets even friend-readable profile without token' do
    profile = Fabricate(:friends_readable_profile)
    get_without_token "/api/v1/profiles/#{profile.id}"
    expect(response).to have_http_status(200)
  end


  it 'does not creates a profile as simple user' do
    access_token = Fabricate(:public_access_token)
    profile = Fabricate.build(:profile)

    request_params = {
      user_name:  profile.user_name,
      first_name: profile.first_name,
      last_name:  profile.last_name
    }.to_json

    post_with_token "/api/v1/profiles", request_params, access_token.token
    expect(response).to have_http_status(403)
  end


  it 'creates a profile as manager' do
    access_token = Fabricate(:full_access_token_as_admin)
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
    access_token      = Fabricate(:public_access_token).token
    user              = Fabricate(:user)
    profile           = user.profile
    profile.readable  = 'world'
    profile.save
    group             = Fabricate(:group)
    metering_point    = Fabricate(:metering_point_readable_by_world)
    user.add_role(:member, metering_point)
    group.metering_points << metering_point

    get_with_token "/api/v1/profiles/#{profile.id}/groups", access_token
    expect(response).to have_http_status(200)
    expect(json['data'].first['id']).to eq(group.id)
    get_without_token "/api/v1/profiles/#{profile.id}/groups"
    expect(response).to have_http_status(200)
    expect(json['data'].first['id']).to eq(group.id)
  end

  it 'get community-readable groups for world-readable profile only with token' do
    access_token      = Fabricate(:public_access_token)
    user              = Fabricate(:user)
    profile           = user.profile
    profile.readable  = 'world'
    profile.save
    group             = Fabricate(:group_readable_by_community)
    metering_point    = Fabricate(:metering_point_readable_by_community)
    user.add_role(:member, metering_point)
    group.metering_points << metering_point

    get_without_token "/api/v1/profiles/#{profile.id}/groups"
    expect(response).to have_http_status(200)
    expect(json['data']).to eq([])
    get_with_token "/api/v1/profiles/#{profile.id}/groups", access_token.token
    expect(response).to have_http_status(200)
    expect(json['data'].first['id']).to eq(group.id)
  end

  it 'get friends-readable groups for world-readable profile only with friend token' do
    access_token      = Fabricate(:access_token_with_friend)
    wrong_token       = Fabricate(:public_access_token).token
    token_user        = User.find(access_token.resource_owner_id)
    token_user_friend = token_user.friends.first
    profile           = token_user_friend.profile
    profile.readable  = 'world'
    profile.save
    group             = Fabricate(:group_readable_by_friends)
    metering_point    = Fabricate(:metering_point_readable_by_friends)
    token_user_friend.add_role(:member, metering_point)
    group.metering_points << metering_point

    get_with_token "/api/v1/profiles/#{profile.id}/groups", access_token.token
    expect(response).to have_http_status(200)
    expect(json['data'].first['id']).to eq(group.id)
    get_with_token "/api/v1/profiles/#{profile.id}/groups", wrong_token
    expect(response).to have_http_status(200)
    expect(json['data']).to eq([])
  end

  it 'does not get members-readable groups for world-readable profile even with friend token' do
    access_token      = Fabricate(:access_token_with_friend)
    token_user        = User.find(access_token.resource_owner_id)
    token_user_friend = token_user.friends.first
    profile           = token_user_friend.profile
    profile.readable  = 'world'
    profile.save
    group             = Fabricate(:group_readable_by_members)
    metering_point    = Fabricate(:metering_point_readable_by_friends)
    token_user_friend.add_role(:member, metering_point)
    group.metering_points << metering_point

    get_with_token "/api/v1/profiles/#{profile.id}/groups", access_token.token
    expect(response).to have_http_status(200)
    expect(json['data']).to eq([])
  end

  it 'does not get friends-readable groups for world-readable profile with or without token' do
    access_token      = Fabricate(:public_access_token)
    wrong_token       = Fabricate(:public_access_token).token
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

  it 'paginate groups' do
    user              = Fabricate(:user)
    profile           = user.profile
    profile.readable  = 'world'
    profile.save
    @page_overload.times do
      group             = Fabricate(:group)
      metering_point    = Fabricate(:metering_point_readable_by_world)
      user.add_role(:member, metering_point)
      group.metering_points << metering_point
    end

    get_without_token "/api/v1/profiles/#{profile.id}/groups"
    expect(response).to have_http_status(200)
    expect(json['meta']['total_pages']).to eq(2)
  end

  it 'get friends for world-readable profile with or without token' do
    user              = Fabricate(:user_with_friend)
    profile           = user.profile
    profile.readable  = 'world'
    profile.save
    friend            = user.friends.first
    access_token      = Fabricate(:public_access_token).token

    get_with_token "/api/v1/profiles/#{profile.id}/friends", access_token
    expect(response).to have_http_status(200)
    expect(json['data'].first['id']).to eq(friend.id)
    get_without_token "/api/v1/profiles/#{profile.id}/friends"
    expect(response).to have_http_status(200)
    expect(json['data'].first['id']).to eq(friend.id)
  end

  it 'get friends for community-readable profile only with token' do
  user              = Fabricate(:user_with_friend)
  profile           = user.profile
  profile.readable  = 'community'
  profile.save
  friend            = user.friends.first
  access_token      = Fabricate(:public_access_token).token

  get_with_token "/api/v1/profiles/#{profile.id}/friends", access_token
  expect(response).to have_http_status(200)
  expect(json['data'].first['id']).to eq(friend.id)
  get_without_token "/api/v1/profiles/#{profile.id}/friends"
  expect(response).to have_http_status(403)
  end

  it 'paginate friends' do
    user              = Fabricate(:user)
    profile           = user.profile
    profile.readable  = 'world'
    profile.save
    @page_overload.times do
      user.friends << Fabricate(:user)
    end
    get_without_token "/api/v1/profiles/#{profile.id}/friends"
    expect(response).to have_http_status(200)
    expect(json['meta']['total_pages']).to eq(2)
  end

  it 'get profile metering points readable by world with or without token' do
    access_token      = Fabricate(:public_access_token).token
    user              = Fabricate(:user)
    profile           = user.profile
    profile.readable  = 'world'
    profile.save
    metering_point    = Fabricate(:metering_point_readable_by_world)
    user.add_role(:member, metering_point)

    get_with_token "/api/v1/profiles/#{profile.id}/metering-points", access_token
    expect(response).to have_http_status(200)
    expect(json['data'].first['id']).to eq(metering_point.id)
    get_without_token "/api/v1/profiles/#{profile.id}/metering-points"
    expect(response).to have_http_status(200)
    expect(json['data'].first['id']).to eq(metering_point.id)
  end

  it 'get community-readable metering points for world-readable profile only with token' do
    access_token      = Fabricate(:public_access_token)
    user              = Fabricate(:user)
    profile           = user.profile
    profile.readable  = 'world'
    profile.save
    metering_point    = Fabricate(:metering_point_readable_by_community)
    user.add_role(:member, metering_point)

    get_without_token "/api/v1/profiles/#{profile.id}/metering-points"
    expect(response).to have_http_status(200)
    expect(json['data']).to eq([])
    get_with_token "/api/v1/profiles/#{profile.id}/metering-points", access_token.token
    expect(response).to have_http_status(200)
    expect(json['data'].first['id']).to eq(metering_point.id)
  end

  it 'get friends-readable metering points for world-readable profile only with friend token' do
    access_token      = Fabricate(:access_token_with_friend)
    wrong_token       = Fabricate(:public_access_token).token
    token_user        = User.find(access_token.resource_owner_id)
    token_user_friend = token_user.friends.first
    profile           = token_user_friend.profile
    profile.readable  = 'world'
    profile.save
    metering_point    = Fabricate(:metering_point_readable_by_friends)
    token_user_friend.add_role(:member, metering_point)

    get_with_token "/api/v1/profiles/#{profile.id}/metering-points", access_token.token
    expect(response).to have_http_status(200)
    expect(json['data'].first['id']).to eq(metering_point.id)
    get_with_token "/api/v1/profiles/#{profile.id}/metering-points", wrong_token
    expect(response).to have_http_status(200)
    expect(json['data']).to eq([])
  end

  it 'does not get members-readable metering points for world-readable profile even with friend token' do
    access_token      = Fabricate(:access_token_with_friend)
    token_user        = User.find(access_token.resource_owner_id)
    token_user_friend = token_user.friends.first
    profile           = token_user_friend.profile
    profile.readable  = 'world'
    profile.save
    metering_point    = Fabricate(:metering_point_readable_by_members)
    token_user_friend.add_role(:member, metering_point)

    get_with_token "/api/v1/profiles/#{profile.id}/metering-points", access_token.token
    expect(response).to have_http_status(200)
    expect(json['data']).to eq([])
  end

  it 'does not get friends-readable metering points for world-readable profile with or without token' do
    access_token      = Fabricate(:public_access_token)
    wrong_token       = Fabricate(:public_access_token).token
    token_user        = User.find(access_token.resource_owner_id)
    profile           = token_user.profile
    profile.readable  = 'world'
    profile.save
    metering_point    = Fabricate(:metering_point_readable_by_friends)
    token_user.add_role(:member, metering_point)

    get_without_token "/api/v1/profiles/#{profile.id}/metering-points"
    expect(response).to have_http_status(200)
    expect(json['data']).to eq([])
    get_with_token "/api/v1/profiles/#{profile.id}/metering-points", wrong_token
    expect(response).to have_http_status(200)
    expect(json['data']).to eq([])
  end

  it 'paginate metereing points' do
    user              = Fabricate(:user)
    profile           = user.profile
    profile.readable  = 'world'
    profile.save
    @page_overload.times do
      metering_point  = Fabricate(:metering_point_readable_by_world)
      user.add_role(:member, metering_point)
    end
    get_without_token "/api/v1/profiles/#{profile.id}/metering-points"
    expect(response).to have_http_status(200)
    expect(json['meta']['total_pages']).to eq(2)
  end



end
