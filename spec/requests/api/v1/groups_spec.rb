describe "Groups API" do

  it 'does gets a group readable by world with or without token' do
    access_token  = Fabricate(:access_token).token
    group = Fabricate(:group)
    get_without_token "/api/v1/groups/#{group.id}"
    expect(response).to have_http_status(200)
    get_with_token "/api/v1/groups/#{group.id}", access_token
    expect(response).to have_http_status(200)
  end

  it 'does not gets a group readable by community without token' do
    group = Fabricate(:group_readable_by_community)
    get_without_token "/api/v1/groups/#{group.id}"
    expect(response).to have_http_status(401)
  end


  it 'does not create a group without token' do
    group = Fabricate.build(:group)
    request_params = {
      name:  group.name,
      readable: group.readable,
      description: group.description
    }.to_json
    post_without_token "/api/v1/groups", request_params
    expect(response).to have_http_status(401)
  end

  it 'does not create a group with missing name' do
    access_token  = Fabricate(:access_token)
    group = Fabricate.build(:group)
    request_params = {
      # name:  group.name,
      readable: group.readable,
      description: group.description
    }.to_json
    post_with_token "/api/v1/groups", request_params, access_token.token
    expect(response).to have_http_status(400)
  end


  it 'does create a group' do
    metering_point = Fabricate(:out_metering_point_with_manager)
    manager       = metering_point.managers.first
    access_token  = Fabricate(:access_token, resource_owner_id: manager.id)
    access_token.update_attribute :scopes, 'write'
    group = Fabricate.build(:group)
    request_params = {
      name: group.name,
      readable: group.readable,
      description: group.description
    }.to_json
    post_with_token "/api/v1/groups", request_params, access_token.token
    expect(response).to have_http_status(201)
  end


  it 'does update a group' do
    metering_point = Fabricate(:out_metering_point_with_manager)
    manager       = metering_point.managers.first
    access_token  = Fabricate(:access_token, resource_owner_id: manager.id)
    access_token.update_attribute :scopes, 'write'
    group = Fabricate(:group)
    manager.add_role(:manager, group)
    request_params = {
      id: group.id,
      name: "#{group.name} updated",
      readable: group.readable,
      description: group.description
    }.to_json
    put_with_token "/api/v1/groups", request_params, access_token.token
    expect(response).to have_http_status(200)
    expect(json['data']['attributes']['name']).to eq("#{group.name} updated")
  end


  it 'does delete a group' do
    metering_point = Fabricate(:out_metering_point_with_manager)
    manager       = metering_point.managers.first
    access_token  = Fabricate(:access_token, resource_owner_id: manager.id)
    access_token.update_attribute :scopes, 'write'
    group = Fabricate(:group)
    manager.add_role(:manager, group)
    delete_with_token "/api/v1/groups/#{group.id}", access_token.token
    expect(response).to have_http_status(204)
  end


  it 'does gets a group readable by community' do
    access_token  = Fabricate(:access_token)
    group         = Fabricate(:group_readable_by_community)
    get_with_token "/api/v1/groups/#{group.id}", access_token.token
    expect(response).to have_http_status(200)
  end

  it 'get a friend-readable group by managers friend' do
    access_token      = Fabricate(:access_token_with_friend)
    token_user        = User.find(access_token.resource_owner_id)
    token_user_friend = token_user.friends.first
    group             = Fabricate(:group_readable_by_friends)
    token_user_friend.add_role(:manager, group)
    get_with_token "/api/v1/groups/#{group.id}", access_token.token
    expect(response).to have_http_status(200)
  end

  it 'get a friend-readable group by member' do
    access_token      = Fabricate(:access_token)
    token_user        = User.find(access_token.resource_owner_id)
    member            = Fabricate(:user)
    group             = Fabricate(:group_readable_by_friends)
    metering_point    = Fabricate(:metering_point)
    member.add_role(:member, metering_point)
    token_user.add_role(:member, metering_point)
    group.metering_points << metering_point
    get_with_token "/api/v1/groups/#{group.id}", access_token.token
    expect(response).to have_http_status(200)
  end

  it 'get a member-readable group by member' do
    access_token      = Fabricate(:access_token)
    token_user        = User.find(access_token.resource_owner_id)
    member            = Fabricate(:user)
    group             = Fabricate(:group_readable_by_members)
    metering_point    = Fabricate(:metering_point)
    member.add_role(:member, metering_point)
    token_user.add_role(:member, metering_point)
    group.metering_points << metering_point
    get_with_token "/api/v1/groups/#{group.id}", access_token.token
    expect(response).to have_http_status(200)
  end

  it 'does not gets a group readable by members or friends if user is not member or friend' do
    access_token  = Fabricate(:access_token)
    members_group         = Fabricate(:group_readable_by_members)
    friends_group         = Fabricate(:group_readable_by_friends)
    get_with_token "/api/v1/groups/#{members_group.id}", access_token.token
    expect(response).to have_http_status(403)
    get_with_token "/api/v1/groups/#{friends_group.id}", access_token.token
    expect(response).to have_http_status(403)
  end


  it 'gets the related metering-points for Group' do
    access_token  = Fabricate(:access_token)
    group         = Fabricate(:group_readable_by_members)
    get_with_token "/api/v1/groups/#{group.id}/metering-points", access_token.token
    expect(response).to have_http_status(200)
  end

  it 'gets the related devices for Group' do
    access_token  = Fabricate(:access_token)
    group         = Fabricate(:group_readable_by_members)
    group.metering_points << Fabricate(:metering_point_with_device)
    get_with_token "/api/v1/groups/#{group.id}/devices", access_token.token
    expect(response).to have_http_status(200)
  end

  it 'gets the related managers for Group' do
    access_token  = Fabricate(:access_token)
    group         = Fabricate(:group_readable_by_members)
    group.metering_points << Fabricate(:metering_point)
    get_with_token "/api/v1/groups/#{group.id}/managers", access_token.token
    expect(response).to have_http_status(200)
  end

  it 'gets the related energy-producers for Group' do
    access_token  = Fabricate(:access_token)
    group         = Fabricate(:group_readable_by_members)
    group.metering_points << Fabricate(:metering_point)
    get_with_token "/api/v1/groups/#{group.id}/energy-producers", access_token.token
    expect(response).to have_http_status(200)
  end

  # because comments don't have their own read access control, here the only one test
  # for getting them
  it 'gets the related comments for the group' do
    group   = Fabricate(:group)
    user    = Fabricate(:user)
    comment = Comment.build_from(group, user.id, 'Hola!', '')
    comment.save
    get_without_token "/api/v1/groups/#{group.id}/comments"
    expect(response).to have_http_status(200)
    expect(json.first['body']).to eq('Hola!')
  end




end
