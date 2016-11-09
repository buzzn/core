describe "Groups API" do

  let(:page_overload) { 11 }


  it 'search groups without token' do
    group = Fabricate(:group)
    Fabricate(:group_readable_by_community)
    regular_token         = Fabricate(:simple_access_token)
    token_with_friend     = Fabricate(:access_token_with_friend)
    token_user            = User.find(token_with_friend.resource_owner_id)
    friend                = token_user.friends.first
    member_token          = Fabricate(:simple_access_token)
    member                = User.find(member_token.resource_owner_id)
    friend_group          = Fabricate(:group_readable_by_friends)
    friend.add_role(:manager, friend_group)
    member_group          = Fabricate(:group_readable_by_members)
    member.add_role(:manager, member_group)


    get_without_token '/api/v1/groups'
    expect(response).to have_http_status(200)
    expect(json['data'].size).to eq(1)

    request_params = { filter: group.name }
    get_without_token '/api/v1/groups', request_params
    expect(response).to have_http_status(200)
    expect(json['data'].size).to eq(1)

    request_params = { filter: 'hello world' }
    get_without_token '/api/v1/groups', request_params
    expect(response).to have_http_status(200)
    expect(json['data'].size).to eq(0)
  end


  it 'search groups with simple token' do
    group = Fabricate(:group)
    Fabricate(:group_readable_by_community)
    regular_token         = Fabricate(:simple_access_token)
    token_with_friend     = Fabricate(:access_token_with_friend)
    token_user            = User.find(token_with_friend.resource_owner_id)
    friend                = token_user.friends.first
    member_token          = Fabricate(:simple_access_token)
    member                = User.find(member_token.resource_owner_id)
    friend_group          = Fabricate(:group_readable_by_friends)
    friend.add_role(:manager, friend_group)
    member_group          = Fabricate(:group_readable_by_members)
    member.add_role(:manager, member_group)


    get_with_token '/api/v1/groups', regular_token.token
    expect(response).to have_http_status(200)
    expect(json['data'].size).to eq(2)

    request_params = { filter: group.name }
    get_with_token '/api/v1/groups', request_params, regular_token.token
    expect(response).to have_http_status(200)
    expect(json['data'].size).to eq(1)

    request_params = { filter: 'hello world' }
    get_with_token '/api/v1/groups', request_params, regular_token.token
    expect(response).to have_http_status(200)
    expect(json['data'].size).to eq(0)
  end


  it 'search groups with simple token as friend' do
    group = Fabricate(:group)
    Fabricate(:group_readable_by_community)
    regular_token         = Fabricate(:simple_access_token)
    token_with_friend     = Fabricate(:access_token_with_friend)
    token_user            = User.find(token_with_friend.resource_owner_id)
    friend                = token_user.friends.first
    member_token          = Fabricate(:simple_access_token)
    member                = User.find(member_token.resource_owner_id)
    friend_group          = Fabricate(:group_readable_by_friends)
    friend.add_role(:manager, friend_group)
    member_group          = Fabricate(:group_readable_by_members)
    member.add_role(:manager, member_group)


    get_with_token '/api/v1/groups', token_with_friend.token
    expect(response).to have_http_status(200)
    expect(json['data'].size).to eq(3)

    request_params = { filter: friend_group.name }
    get_with_token '/api/v1/groups', request_params, token_with_friend.token
    expect(response).to have_http_status(200)
    expect(json['data'].size).to eq(1)

    request_params = { filter: 'hello world' }
    get_with_token '/api/v1/groups', request_params, token_with_friend.token
    expect(response).to have_http_status(200)
    expect(json['data'].size).to eq(0)
  end


  it 'search groups with simple token as member' do
    group = Fabricate(:group)
    Fabricate(:group_readable_by_community)
    regular_token         = Fabricate(:simple_access_token)
    token_with_friend     = Fabricate(:access_token_with_friend)
    token_user            = User.find(token_with_friend.resource_owner_id)
    friend                = token_user.friends.first
    member_token          = Fabricate(:simple_access_token)
    member                = User.find(member_token.resource_owner_id)
    friend_group          = Fabricate(:group_readable_by_friends)
    friend.add_role(:manager, friend_group)
    member_group          = Fabricate(:group_readable_by_members)
    member.add_role(:manager, member_group)


    get_with_token '/api/v1/groups', member_token.token
    expect(response).to have_http_status(200)
    expect(json['data'].size).to eq(3)

    request_params = { filter: member_group.name }
    get_with_token '/api/v1/groups', request_params, member_token.token
    expect(response).to have_http_status(200)
    expect(json['data'].size).to eq(1)

    request_params = { filter: 'hello world' }
    get_with_token '/api/v1/groups', request_params, member_token.token
    expect(response).to have_http_status(200)
    expect(json['data'].size).to eq(0)
  end


  it 'paginates groups' do
    page_overload.times do
      Fabricate(:group)
    end
    get_without_token '/api/v1/groups'
    expect(response).to have_http_status(200)
    expect(json['meta']['total_pages']).to eq(2)

    get_without_token '/api/v1/groups', {per_page: 200}
    expect(response).to have_http_status(422)
  end

  it 'does gets a group readable by world with or without token' do
    access_token  = Fabricate(:simple_access_token).token
    group = Fabricate(:group)
    get_without_token "/api/v1/groups/#{group.id}"
    expect(response).to have_http_status(200)
    get_with_token "/api/v1/groups/#{group.id}", access_token
    expect(response).to have_http_status(200)
  end

  it 'does not gets a group readable by community without token' do
    group = Fabricate(:group_readable_by_community)
    get_without_token "/api/v1/groups/#{group.id}"
    expect(response).to have_http_status(403)
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

  it 'does not create a group with missing parameter' do
    access_token  = Fabricate(:full_access_token)
    group = Fabricate.build(:group)
    request_params = {
      name:  group.name,
      readable: group.readable,
      description: group.description
    }

    [:name, :description].each do |name|
      params = request_params.reject {|k,v| k == name}

      post_with_token "/api/v1/groups", params.to_json, access_token.token

      expect(response).to have_http_status(422)
      json['errors'].each do |error|
        expect(error['source']['pointer']).to eq "/data/attributes/#{name}"
        expect(error['title']).to eq 'Invalid Attribute'
        expect(error['detail']).to eq "#{name} is missing"
      end
    end
  end

  it 'does not create a group with invalid parameter' do
    metering_point = Fabricate(:out_metering_point_with_manager)
    manager       = metering_point.managers.first
    access_token  = Fabricate(:simple_access_token, resource_owner_id: manager.id)
    access_token.update_attribute :scopes, 'full'
    group = Fabricate.build(:group)

    request_params = {
      name:  group.name,
      description: group.description
    }

    [:name].each do |name|
      params = request_params.dup
      params[name] = 'a' * 2000

      post_with_token "/api/v1/groups", params.to_json, access_token.token

      expect(response).to have_http_status(422)
      json['errors'].each do |error|
        expect(error['source']['pointer']).to eq "/data/attributes/#{name}"
        expect(error['title']).to eq 'Invalid Attribute'
        expect(error['detail']).to eq "#{name} ist zu lang (mehr als 40 Zeichen)"
      end
    end
  end


  it 'creates a group' do
    metering_point = Fabricate(:out_metering_point_with_manager)
    manager       = metering_point.managers.first
    access_token  = Fabricate(:simple_access_token, resource_owner_id: manager.id)
    access_token.update_attribute :scopes, 'full'
    group = Fabricate.build(:group)

    request_params = {
      name: group.name,
      description: group.description
    }.to_json

    post_with_token "/api/v1/groups", request_params, access_token.token

    expect(response).to have_http_status(201)
    expect(response.headers['Location']).to eq json['data']['id']
  end

  it "does not update a group with validation errors" do
    group = Fabricate(:group)

    access_token = Fabricate(:full_access_token_as_admin)

    [:name].each do |k|
      params = { "#{k}": 'a' * 2000 }

      patch_with_token "/api/v1/groups/#{group.id}", params.to_json, access_token.token

      expect(response).to have_http_status(422)
      json['errors'].each do |error|
        expect(error['source']['pointer']).to eq "/data/attributes/#{k}"
        expect(error['title']).to eq 'Invalid Attribute'
        expect(error['detail']).to eq "#{k} ist zu lang (mehr als 40 Zeichen)"
      end
    end
  end

  it 'updates a group' do
    metering_point = Fabricate(:out_metering_point_with_manager)
    manager       = metering_point.managers.first
    access_token  = Fabricate(:full_access_token, resource_owner_id: manager.id)
    group = Fabricate(:group)
    manager.add_role(:manager, group)
    request_params = {
      name: "#{group.name} updated"
    }.to_json

    patch_with_token "/api/v1/groups/#{group.id}", request_params, access_token.token

    expect(response).to have_http_status(200)
    expect(json['data']['attributes']['name']).to eq("#{group.name} updated")
  end


  it 'does delete a group' do
    metering_point = Fabricate(:out_metering_point_with_manager)
    manager       = metering_point.managers.first
    access_token  = Fabricate(:simple_access_token, resource_owner_id: manager.id)
    access_token.update_attribute :scopes, 'full'
    group = Fabricate(:group)
    manager.add_role(:manager, group)
    delete_with_token "/api/v1/groups/#{group.id}", access_token.token
    expect(response).to have_http_status(204)
  end


  it 'does gets a group readable by community' do
    access_token  = Fabricate(:simple_access_token)
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
    access_token      = Fabricate(:simple_access_token)
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
    access_token      = Fabricate(:simple_access_token)
    token_user        = User.find(access_token.resource_owner_id)
    group             = Fabricate(:group_readable_by_members)
    metering_point    = Fabricate(:metering_point)
    token_user.add_role(:member, metering_point)
    group.metering_points << metering_point
    get_with_token "/api/v1/groups/#{group.id}", access_token.token
    expect(response).to have_http_status(200)
  end

  it 'does not gets a group readable by members or friends if user is not member or friend' do
    access_token  = Fabricate(:simple_access_token)
    members_group         = Fabricate(:group_readable_by_members)
    friends_group         = Fabricate(:group_readable_by_friends)
    get_with_token "/api/v1/groups/#{members_group.id}", access_token.token
    expect(response).to have_http_status(403)
    get_with_token "/api/v1/groups/#{friends_group.id}", access_token.token
    expect(response).to have_http_status(403)
  end


  it 'gets the related metering-points for Group' do
    group                 = Fabricate(:group)
    group.metering_points = [
      Fabricate(:metering_point_readable_by_world),
      Fabricate(:metering_point_readable_by_community),
      Fabricate(:metering_point_readable_by_friends),
      Fabricate(:metering_point_readable_by_members),
      Fabricate(:out_metering_point_readable_by_world),
    ]

    get_without_token "/api/v1/groups/#{group.id}/metering-points"
    expect(response).to have_http_status(200)
    expect(json['data'].size).to eq(5)
  end


  it 'paginates metering points' do
    group = Fabricate(:group)
    page_overload.times do
      group.metering_points << Fabricate(:metering_point_readable_by_world)
    end
    get_without_token "/api/v1/groups/#{group.id}/metering-points"
    expect(response).to have_http_status(200)
    expect(json['meta']['total_pages']).to eq(2)

    get_without_token "/api/v1/groups/#{group.id}/metering-points", {per_page: 200}
    expect(response).to have_http_status(422)
  end


  [nil, :sufficiency, :closeness, :autarchy, :fitting].each do |mode|

    it "fails the related scores without interval using mode #{mode}" do
      group                 = Fabricate(:group)
      now                   = Time.current
      params = { mode: mode, timestamp: now }
      get_without_token "/api/v1/groups/#{group.id}/scores", params
      expect(response).to have_http_status(422)
      expect(json['errors'].first['source']['pointer']).to eq '/data/attributes/interval'
    end

    [:day, :month, :year].each do |interval|
      it "fails the related #{interval}ly scores without timestamp using mode #{mode}" do
        group                 = Fabricate(:group)
        params = { mode: mode, interval: interval }
        get_without_token "/api/v1/groups/#{group.id}/scores", params
        expect(response).to have_http_status(422)
        expect(json['errors'].first['source']['pointer']).to eq '/data/attributes/timestamp'
      end

      it "gets the related #{interval}ly scores with mode '#{mode}'" do
        group                 = Fabricate(:group)
        now                   = Time.current
        interval_information  = Group.score_interval(interval.to_s, now.to_i)
        5.times do
          Score.create(mode: mode || 'autarchy', interval: interval_information[0], interval_beginning: interval_information[1], interval_end: interval_information[2], value: (rand * 10).to_i, scoreable_type: 'Group', scoreable_id: group.id)
        end

        params = { mode: mode, interval: interval, timestamp: now }
        get_without_token "/api/v1/groups/#{group.id}/scores", params
        expect(response).to have_http_status(200)
        expect(json['data'].size).to eq(5)
        sample = json['data'].first['attributes']
        expect(sample['mode']).to eq((mode || 'autarchy').to_s)
        expect(sample['interval']).to eq(interval.to_s)
        expect(sample['interval-beginning'] < now.as_json && now.as_json < sample['interval-end']).to eq true
      end
    end
  end


  it 'paginates scores' do
    group                 = Fabricate(:group)
    now                   = Time.current
    interval_information  = group.set_score_interval('day', now.to_i)
    page_overload.times do
      Score.create(mode: 'autarchy', interval: interval_information[0], interval_beginning: interval_information[1], interval_end: interval_information[2], value: (rand * 10).to_i, scoreable_type: 'Group', scoreable_id: group.id)
    end
    params = { interval: 'day', timestamp: now }
    get_without_token "/api/v1/groups/#{group.id}/scores", params
    expect(response).to have_http_status(200)
    expect(json['meta']['total_pages']).to eq(2)

    get_without_token "/api/v1/groups/#{group.id}/scores", {per_page: 200}
    expect(response).to have_http_status(422)
  end


  it 'gets the related managers for group only with token' do
    access_token  = Fabricate(:simple_access_token)
    group         = Fabricate(:group)
    group.metering_points << Fabricate(:metering_point)
    get_with_token "/api/v1/groups/#{group.id}/managers", access_token.token
    expect(response).to have_http_status(200)
    get_with_token "/api/v1/groups/#{group.id}/relationships/managers", access_token.token
    expect(response).to have_http_status(200)
    get_without_token "/api/v1/groups/#{group.id}/managers"
    expect(response).to have_http_status(401)
    get_without_token "/api/v1/groups/#{group.id}/relationships/managers"
    expect(response).to have_http_status(401)
  end

  it 'paginates managers' do
    access_token  = Fabricate(:simple_access_token)
    group         = Fabricate(:group)
    page_overload.times do
      user = Fabricate(:user)
      user.profile.update!(readable: 'world')
      user.add_role(:manager, group)
    end
    page_overload.times do
      user = Fabricate(:user)
      user.add_role(:manager, group)
    end
    get_with_token "/api/v1/groups/#{group.id}/managers", access_token.token
    expect(response).to have_http_status(200)
    expect(json['meta']['total_pages']).to eq(2)
    
    access_token  = Fabricate(:full_access_token_as_admin)
    get_with_token "/api/v1/groups/#{group.id}/managers", access_token.token
    expect(response).to have_http_status(200)
    expect(json['meta']['total_pages']).to eq(3)

    get_with_token "/api/v1/groups/#{group.id}/managers", {per_page: 200}, access_token.token
    expect(response).to have_http_status(422)
  end

  it 'paginates members' do
    access_token  = Fabricate(:simple_access_token)
    group         = Fabricate(:group_with_members_readable_by_world, members: page_overload * 2)

    group.members[0..page_overload].each do |u|
      u.profile.update! readable: 'world'
    end

    get_with_token "/api/v1/groups/#{group.id}/members", access_token.token
    expect(response).to have_http_status(200)
    expect(json['meta']['total_pages']).to eq(2)

    access_token  = Fabricate(:full_access_token_as_admin)
    get_with_token "/api/v1/groups/#{group.id}/members", access_token.token
    expect(response).to have_http_status(200)
    expect(json['meta']['total_pages']).to eq(3)

    get_with_token "/api/v1/groups/#{group.id}/members", {per_page: 200}, access_token.token
    expect(response).to have_http_status(422)
  end

  it 'gets the related members for group only with token' do
    access_token  = Fabricate(:simple_access_token)
    group         = Fabricate(:group_with_members_readable_by_world)

    get_with_token "/api/v1/groups/#{group.id}/members", access_token.token
    expect(response).to have_http_status(200)
    get_without_token "/api/v1/groups/#{group.id}/members"
    expect(response).to have_http_status(401)
  end

  it 'does not add/replace/delete group manager without token' do
    group  = Fabricate(:group)
    user   = Fabricate(:user)
    params = {
      data: { id: user.id }
    }

    post_without_token "/api/v1/groups/#{group.id}/relationships/managers", params.to_json
    expect(response).to have_http_status(401)
    patch_without_token "/api/v1/groups/#{group.id}/relationships/managers", params.to_json
    expect(response).to have_http_status(401)
    delete_without_token "/api/v1/groups/#{group.id}/relationships/managers", params.to_json
    expect(response).to have_http_status(401)
  end

  it 'adds manager only with manager token or admin token' do
    metering_point  = Fabricate(:metering_point_readable_by_world)
    group           = Fabricate(:group)
    user1           = Fabricate(:user)
    user2           = Fabricate(:user)
    admin_token     = Fabricate(:full_access_token_as_admin)
    simple_token    = Fabricate(:simple_access_token)
    simple_manager  = User.find(simple_token.resource_owner_id)
    simple_manager.add_role(:manager, group)
    manager_token   = Fabricate(:full_access_token)
    manager         = User.find(manager_token.resource_owner_id)
    manager.add_role(:manager, group)
    member_token    = Fabricate(:full_access_token)
    member          = User.find(member_token.resource_owner_id)
    member.add_role(:member, metering_point)
    group.metering_points << metering_point
    params = {
      data: { id: user1.id }
    }

    post_with_token "/api/v1/groups/#{group.id}/relationships/managers", params.to_json, member_token.token
    expect(response).to have_http_status(403)
    post_with_token "/api/v1/groups/#{group.id}/relationships/managers", params.to_json, simple_token.token
    expect(response).to have_http_status(403)
    post_with_token "/api/v1/groups/#{group.id}/relationships/managers", params.to_json, manager_token.token
    expect(response).to have_http_status(204)

    get_with_token "/api/v1/groups/#{group.id}/relationships/managers", admin_token.token
    expect(json['data'].size).to eq(3)
    params[:data][:id] = user2.id
    post_with_token "/api/v1/groups/#{group.id}/relationships/managers", params.to_json, admin_token.token
    expect(response).to have_http_status(204)

    get_with_token "/api/v1/groups/#{group.id}/relationships/managers", admin_token.token
    expect(json['data'].size).to eq(4)
  end

  it 'replaces group managers' do
    group           = Fabricate(:group)
    user            = Fabricate(:user)
    user1           = Fabricate(:user)
    user2           = Fabricate(:user)
    user1.add_role(:manager, group)
    user2.add_role(:manager, group)
    simple_token    = Fabricate(:simple_access_token)
    admin_token     = Fabricate(:full_access_token_as_admin)
    manager_token   = Fabricate(:full_access_token)
    manager         = User.find(manager_token.resource_owner_id)
    manager.add_role(:manager, group)
    params = {
      data: [{ id: user.id }]
    }
    patch_with_token "/api/v1/groups/#{group.id}/relationships/managers", params.to_json, simple_token.token
    expect(response).to have_http_status(403)
    patch_with_token "/api/v1/groups/#{group.id}/relationships/managers", params.to_json, manager_token.token
    expect(response).to have_http_status(200)

    get_with_token "/api/v1/groups/#{group.id}/relationships/managers", params.to_json, manager_token.token
    # we patched the managers, 'manager' is no more manager
    expect(json['data'].size).to eq 0
    get_with_token "/api/v1/groups/#{group.id}/relationships/managers", params.to_json, admin_token.token
    expect(json['data'].size).to eq 1
    expect(json['data'].first['id']).to eq user.id
  end

  it 'removes group manager only for current user or with manager token' do
    metering_point  = Fabricate(:metering_point_readable_by_world)
    group           = Fabricate(:group)
    user            = Fabricate(:user)
    user.add_role(:manager, group)
    admin_token     = Fabricate(:full_access_token_as_admin)
    simple_token    = Fabricate(:simple_access_token)
    simple_manager  = User.find(simple_token.resource_owner_id)
    simple_manager.add_role(:manager, group)
    manager_token   = Fabricate(:full_access_token)
    manager         = User.find(manager_token.resource_owner_id)
    manager.add_role(:manager, group)
    member_token    = Fabricate(:full_access_token)
    member          = User.find(member_token.resource_owner_id)
    member.add_role(:member, metering_point)
    group.metering_points << metering_point
    params = {
      data: { id: user.id }
    }

    get_with_token "/api/v1/groups/#{group.id}/relationships/managers", admin_token.token
    expect(json['data'].size).to eq(3)
    delete_with_token "/api/v1/groups/#{group.id}/relationships/managers", params.to_json, member_token.token
    expect(response).to have_http_status(403)
    delete_with_token "/api/v1/groups/#{group.id}/relationships/managers", params.to_json, simple_token.token
    expect(response).to have_http_status(403)
    delete_with_token "/api/v1/groups/#{group.id}/relationships/managers", params.to_json, manager_token.token
    expect(response).to have_http_status(403)
    delete_with_token "/api/v1/groups/#{group.id}/relationships/managers", params.to_json, admin_token.token
    expect(response).to have_http_status(204)
    get_with_token "/api/v1/groups/#{group.id}/relationships/managers", admin_token.token
    expect(json['data'].size).to eq(2)

    params = {
      data: { id: manager.id }
    }
    delete_with_token "/api/v1/groups/#{group.id}/relationships/managers", params.to_json, manager_token.token
    expect(response).to have_http_status(204)
    get_with_token "/api/v1/groups/#{group.id}/relationships/managers", admin_token.token
    expect(json['data'].size).to eq(1)
  end

  it 'gets the related energy-producers/energy-consumers for group' do
    access_token  = Fabricate(:simple_access_token)
    group         = Fabricate(:group)
    user          = Fabricate(:user)
    consumer      = Fabricate(:user)
    producer      = Fabricate(:user)
    mp_in         = Fabricate(:metering_point, mode: 'in')
    mp_out        = Fabricate(:metering_point, mode: 'out')
    user.add_role(:member, mp_in)
    user.add_role(:manager, mp_in)
    user.add_role(:member, mp_out)
    user.add_role(:manager, mp_out)
    producer.add_role(:manager, mp_in)
    consumer.add_role(:member, mp_in)
    producer.add_role(:member, mp_out)
    consumer.add_role(:manager, mp_out)
    group.metering_points += [mp_in, mp_out]

    get_with_token "/api/v1/groups/#{group.id}/energy-producers", access_token.token
    expect(response).to have_http_status(200)
    expect(json['data'].size).to eq(0)

    get_with_token "/api/v1/groups/#{group.id}/energy-consumers", access_token.token
    expect(response).to have_http_status(200)
    expect(json['data'].size).to eq(0)

    manager = User.find(access_token.resource_owner_id)
    manager.add_role(:manager, mp_in)
    manager.add_role(:member, mp_out)

    get_with_token "/api/v1/groups/#{group.id}/energy-producers", access_token.token
    expect(response).to have_http_status(200)
    expect(json['data'].size).to eq(1)

    get_with_token "/api/v1/groups/#{group.id}/energy-consumers", access_token.token
    expect(response).to have_http_status(200)
    expect(json['data'].size).to eq(1)
  end

  it 'gets the related comments for the group only with token' do
    access_token    = Fabricate(:simple_access_token)
    group           = Fabricate(:group_with_two_comments_readable_by_world)
    comments        = group.comment_threads

    get_without_token "/api/v1/groups/#{group.id}/comments"
    expect(response).to have_http_status(401)
    get_with_token "/api/v1/groups/#{group.id}/comments", access_token.token
    expect(response).to have_http_status(200)
    comments.each do |comment|
      expect(json['data'].find{ |c| c['id'] == comment.id }['attributes']['body']).to eq(comment.body)
    end
  end

  it 'paginates comments' do
    access_token    = Fabricate(:simple_access_token).token
    group           = Fabricate(:group)
    user            = Fabricate(:user)
    comment_params  = {
      commentable_id:     group.id,
      commentable_type:   'Group',
      user_id:            user.id,
      parent_id:          '',
    }
    comment         = Fabricate(:comment, comment_params)
    page_overload.times do
      comment_params[:parent_id] = comment.id
      comment = Fabricate(:comment, comment_params)
    end
    get_with_token "/api/v1/groups/#{group.id}/comments", access_token
    expect(response).to have_http_status(200)
    expect(json['meta']['total_pages']).to eq(2)

    get_with_token "/api/v1/groups/#{group.id}/comments", {per_page: 200}, access_token
    expect(response).to have_http_status(422)
  end




end
