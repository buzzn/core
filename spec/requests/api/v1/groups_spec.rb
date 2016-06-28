describe "Groups API" do

  before(:all) do
    @page_overload = 11
  end

  it 'gets groups filtered by user access level' do
    Fabricate(:group)
    Fabricate(:group_readable_by_community)
    regular_token         = Fabricate(:access_token)
    token_with_friend     = Fabricate(:access_token_with_friend)
    token_user            = User.find(token_with_friend.resource_owner_id)
    friend                = token_user.friends.first
    member_token          = Fabricate(:access_token)
    member                = User.find(member_token.resource_owner_id)
    friend_group          = Fabricate(:group_readable_by_friends)
    friend.add_role(:manager, friend_group)
    member_group          = Fabricate(:group_readable_by_members)
    member.add_role(:manager, member_group)

    get_without_token '/api/v1/groups'
    expect(response).to have_http_status(200)
    expect(json['data'].size).to eq(1)
    get_with_token '/api/v1/groups', regular_token.token
    expect(response).to have_http_status(200)
    expect(json['data'].size).to eq(2)
    get_with_token '/api/v1/groups', token_with_friend.token
    expect(response).to have_http_status(200)
    expect(json['data'].size).to eq(3)
    get_with_token '/api/v1/groups', member_token.token
    expect(response).to have_http_status(200)
    expect(json['data'].size).to eq(3)
  end

  it 'paginate groups' do
    @page_overload.times do
      Fabricate(:group)
    end
    get_without_token '/api/v1/groups'
    expect(response).to have_http_status(200)
    expect(json['meta']['total_pages']).to eq(2)
  end

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
    group             = Fabricate(:group_readable_by_members)
    metering_point    = Fabricate(:metering_point)
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


  it 'gets the related metering-points for Group restricted by metering points' do
    regular_token         = Fabricate(:access_token)
    token_with_friend     = Fabricate(:access_token_with_friend)
    token_user            = User.find(token_with_friend.resource_owner_id)
    friend                = token_user.friends.first
    member_token          = Fabricate(:access_token)
    member                = User.find(member_token.resource_owner_id)
    metering_point1       = Fabricate(:metering_point_readable_by_world)
    metering_point2       = Fabricate(:metering_point_readable_by_community)
    metering_point3       = Fabricate(:metering_point_readable_by_friends)
    metering_point4       = Fabricate(:metering_point_readable_by_members)
    friend.add_role(:manager, metering_point3)
    member.add_role(:member, metering_point4)
    group                 = Fabricate(:group)
    group.metering_points = [
      metering_point1,
      metering_point2,
      metering_point3,
      metering_point4,
    ]

    get_without_token "/api/v1/groups/#{group.id}/metering-points"
    expect(response).to have_http_status(200)
    expect(json['data'].size).to eq(1)
    get_with_token "/api/v1/groups/#{group.id}/metering-points", regular_token.token
    expect(response).to have_http_status(200)
    expect(json['data'].size).to eq(2)
    get_with_token "/api/v1/groups/#{group.id}/metering-points", token_with_friend.token
    expect(response).to have_http_status(200)
    expect(json['data'].size).to eq(3)
    get_with_token "/api/v1/groups/#{group.id}/metering-points", member_token.token
    expect(response).to have_http_status(200)
    expect(json['data'].size).to eq(3)
  end

  it 'paginate metering points' do
    group = Fabricate(:group)
    @page_overload.times do
      group.metering_points << Fabricate(:metering_point_readable_by_world)
    end
    get_without_token "/api/v1/groups/#{group.id}/metering-points"
    expect(response).to have_http_status(200)
    expect(json['meta']['total_pages']).to eq(2)
  end

  it 'gets the related managers for Group only with token' do
    access_token  = Fabricate(:access_token)
    group         = Fabricate(:group)
    group.metering_points << Fabricate(:metering_point)
    get_with_token "/api/v1/groups/#{group.id}/managers", access_token.token
    expect(response).to have_http_status(200)
    get_without_token "/api/v1/groups/#{group.id}/managers"
    expect(response).to have_http_status(401)
  end

  it 'paginate managers' do
    access_token  = Fabricate(:access_token)
    group         = Fabricate(:group)
    @page_overload.times do
      user = Fabricate(:user)
      user.add_role(:manager, group)
    end
    get_with_token "/api/v1/groups/#{group.id}/managers", access_token.token
    expect(response).to have_http_status(200)
    expect(json['meta']['total_pages']).to eq(2)
  end

  it 'gets the related energy-producers for Group' do
    access_token  = Fabricate(:access_token)
    group         = Fabricate(:group)
    group.metering_points << Fabricate(:metering_point)
    get_with_token "/api/v1/groups/#{group.id}/energy-producers", access_token.token
    expect(response).to have_http_status(200)
  end

  it 'gets the related comments for the group only with token' do
    access_token    = Fabricate(:access_token).token
    group           = Fabricate(:world_group_with_two_comments)
    comments        = group.comment_threads

    get_without_token "/api/v1/groups/#{group.id}/comments"
    expect(response).to have_http_status(401)
    get_with_token "/api/v1/groups/#{group.id}/comments", access_token
    expect(response).to have_http_status(200)
    expect(json['data'].first['attributes']['body']).to eq(comments.first.body)
    expect(json['data'].last['attributes']['body']).to eq(comments.last.body)
  end

  it 'paginate comments' do
    access_token    = Fabricate(:access_token).token
    group           = Fabricate(:group)
    user            = Fabricate(:user)
    comment_params  = {
      commentable_id:     group.id,
      commentable_type:   'Group',
      user_id:            user.id,
      parent_id:          '',
    }
    comment         = Fabricate(:comment, comment_params)
    @page_overload.times do
      comment_params[:parent_id] = comment.id
      comment = Fabricate(:comment, comment_params)
    end
    get_with_token "/api/v1/groups/#{group.id}/comments", access_token
    expect(response).to have_http_status(200)
    expect(json['meta']['total_pages']).to eq(2)
  end




end
