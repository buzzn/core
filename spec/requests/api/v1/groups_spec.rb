describe "/groups" do

  let(:page_overload) { 33 }

  let(:output_register_with_manager) do
    register = Fabricate(:output_meter).output_register
    Fabricate(:user).add_role(:manager, register)
    register
  end

  it 'search groups without token' do
    group = Fabricate(:tribe)
    Fabricate(:tribe_readable_by_community)
    regular_token         = Fabricate(:simple_access_token)
    token_with_friend     = Fabricate(:access_token_with_friend)
    token_user            = User.find(token_with_friend.resource_owner_id)
    friend                = token_user.friends.first
    member_token          = Fabricate(:simple_access_token)
    member                = User.find(member_token.resource_owner_id)
    friend_group          = Fabricate(:tribe_readable_by_friends)
    friend.add_role(:manager, friend_group)
    member_group          = Fabricate(:tribe_readable_by_members)
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
    group = Fabricate(:tribe)
    Fabricate(:tribe_readable_by_community)
    regular_token         = Fabricate(:simple_access_token)
    token_with_friend     = Fabricate(:access_token_with_friend)
    token_user            = User.find(token_with_friend.resource_owner_id)
    friend                = token_user.friends.first
    member_token          = Fabricate(:simple_access_token)
    member                = User.find(member_token.resource_owner_id)
    friend_group          = Fabricate(:tribe_readable_by_friends)
    friend.add_role(:manager, friend_group)
    member_group          = Fabricate(:tribe_readable_by_members)
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
    group = Fabricate(:tribe)
    Fabricate(:tribe_readable_by_community)
    regular_token         = Fabricate(:simple_access_token)
    token_with_friend     = Fabricate(:access_token_with_friend)
    token_user            = User.find(token_with_friend.resource_owner_id)
    friend                = token_user.friends.first
    member_token          = Fabricate(:simple_access_token)
    member                = User.find(member_token.resource_owner_id)
    friend_group          = Fabricate(:tribe_readable_by_friends)
    friend.add_role(:manager, friend_group)
    member_group          = Fabricate(:tribe_readable_by_members)
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
    group = Fabricate(:tribe)
    Fabricate(:tribe_readable_by_community)
    regular_token         = Fabricate(:simple_access_token)
    token_with_friend     = Fabricate(:access_token_with_friend)
    token_user            = User.find(token_with_friend.resource_owner_id)
    friend                = token_user.friends.first
    member_token          = Fabricate(:simple_access_token)
    member                = User.find(member_token.resource_owner_id)
    friend_group          = Fabricate(:tribe_readable_by_friends)
    friend.add_role(:manager, friend_group)
    member_group          = Fabricate(:tribe_readable_by_members)
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
      Fabricate(:tribe)
    end
    get_without_token '/api/v1/groups'
    expect(response).to have_http_status(200)
    expect(json['meta']['total_pages']).to eq(4)

    get_without_token '/api/v1/groups', {per_page: 200}
    expect(response).to have_http_status(422)
  end



  it 'paginate groups with full access token' do
    page_overload.times do
      Fabricate(:tribe)
    end
    access_token = Fabricate(:full_access_token_as_admin)

    get_with_token "/api/v1/profiles", {per_page: 200}, access_token.token
    expect(response).to have_http_status(422)

    pages_profile_ids = []

    1.upto(4) do |i|
      get_with_token '/api/v1/groups', {page: i, order_direction: 'DESC', order_by: 'created_at'}, access_token.token
      expect(response).to have_http_status(200)
      expect(json['meta']['total_pages']).to eq(4)
      json['data'].each do |data|
        pages_profile_ids << data['id']
      end
    end

    expect(pages_profile_ids.uniq.length).to eq(pages_profile_ids.length)
  end




  it 'does gets a group readable by world with or without token' do
    access_token  = Fabricate(:simple_access_token).token
    group = Fabricate(:tribe)
    get_without_token "/api/v1/groups/#{group.id}"
    expect(response).to have_http_status(200)
    get_with_token "/api/v1/groups/#{group.id}", access_token
    expect(response).to have_http_status(200)
  end

  it 'does not gets a group readable by community without token' do
    group = Fabricate(:tribe_readable_by_community)
    get_without_token "/api/v1/groups/#{group.id}"
    expect(response).to have_http_status(403)
  end




  it "does not update a group with validation errors" do
    group = Fabricate(:tribe)

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
    register      = output_register_with_manager
    manager       = register.managers.first
    access_token  = Fabricate(:full_access_token, resource_owner_id: manager.id)
    group = Fabricate(:tribe)
    manager.add_role(:manager, group)
    request_params = {
      name: "#{group.name} updated"
    }.to_json

    patch_with_token "/api/v1/groups/#{group.id}", request_params, access_token.token

    expect(response).to have_http_status(200)
    expect(json['data']['attributes']['name']).to eq("#{group.name} updated")
  end


  it 'does delete a group' do
    register      = output_register_with_manager
    manager       = register.managers.first
    access_token  = Fabricate(:simple_access_token, resource_owner_id: manager.id)
    access_token.update_attribute :scopes, 'full'
    group = Fabricate(:tribe)
    manager.add_role(:manager, group)

    get_with_token "/api/v1/groups/#{group.id}", access_token.token
    expect(response).to have_http_status(200)
    expect(json['meta']['updatable']).to be_truthy
    expect(json['meta']['deletable']).to be_truthy

    delete_with_token "/api/v1/groups/#{group.id}", access_token.token
    expect(response).to have_http_status(204)
  end


  it 'does gets a group readable by community' do
    access_token  = Fabricate(:simple_access_token)
    group         = Fabricate(:tribe_readable_by_community)
    get_with_token "/api/v1/groups/#{group.id}", access_token.token
    expect(response).to have_http_status(200)
    expect(json['meta']['updatable']).to be_falsey
    expect(json['meta']['deletable']).to be_falsey
  end

  it 'get a friend-readable group by managers friend' do
    access_token      = Fabricate(:access_token_with_friend)
    token_user        = User.find(access_token.resource_owner_id)
    token_user_friend = token_user.friends.first
    group             = Fabricate(:tribe_readable_by_friends)
    token_user_friend.add_role(:manager, group)
    get_with_token "/api/v1/groups/#{group.id}", access_token.token
    expect(response).to have_http_status(200)
    expect(json['meta']['updatable']).to be_falsey
    expect(json['meta']['deletable']).to be_falsey
  end

  it 'get a friend-readable group by member' do
    access_token      = Fabricate(:simple_access_token)
    token_user        = User.find(access_token.resource_owner_id)
    member            = Fabricate(:user)
    group             = Fabricate(:tribe_readable_by_friends)
    register    = Fabricate(:output_meter).output_register
    member.add_role(:member, register)
    token_user.add_role(:member, register)
    group.registers << register

    get_with_token "/api/v1/groups/#{group.id}", access_token.token
    expect(response).to have_http_status(200)
    expect(json['meta']['updatable']).to be_falsey
    expect(json['meta']['deletable']).to be_falsey
  end

  it 'get a member-readable group by member' do
    access_token      = Fabricate(:simple_access_token)
    token_user        = User.find(access_token.resource_owner_id)
    group             = Fabricate(:tribe_readable_by_members)
    register    = Fabricate(:input_meter).input_register
    token_user.add_role(:member, register)
    group.registers << register
    get_with_token "/api/v1/groups/#{group.id}", access_token.token
    expect(response).to have_http_status(200)
    expect(json['meta']['updatable']).to be_falsey
    expect(json['meta']['deletable']).to be_falsey
  end

  it 'does not gets a group readable by members or friends if user is not member or friend' do
    access_token  = Fabricate(:simple_access_token)
    members_group         = Fabricate(:tribe_readable_by_members)
    friends_group         = Fabricate(:tribe_readable_by_friends)
    get_with_token "/api/v1/groups/#{members_group.id}", access_token.token
    expect(response).to have_http_status(403)
    get_with_token "/api/v1/groups/#{friends_group.id}", access_token.token
    expect(response).to have_http_status(403)
  end


  it 'gets the related registers for Group' do
    group = Fabricate(:tribe)
    r = Fabricate(:input_meter).input_register
    r.update(readable: :world)
    group.registers << r
    r = Fabricate(:output_meter).output_register
    r.update(readable: :community)
    group.registers << r
    r = Fabricate(:input_meter).input_register
    r.update(readable: :friends)
    group.registers << r
    r = Fabricate(:input_meter).input_register
    r.update(readable: :members)
    group.registers << r
    r = Fabricate(:output_meter).output_register
    r.update(readable: :world)
    group.registers << r

    get_without_token "/api/v1/groups/#{group.id}/registers"
    expect(response).to have_http_status(200)
    expect(json['data'].size).to eq(5)
  end



  [nil, :sufficiency, :closeness, :autarchy, :fitting].each do |mode|

    it "fails the related scores without interval using mode #{mode}" do
      group                 = Fabricate(:tribe)
      now                   = Time.current
      params = { mode: mode, timestamp: now }
      get_without_token "/api/v1/groups/#{group.id}/scores", params
      expect(response).to have_http_status(422)
      expect(json['errors'].first['source']['pointer']).to eq '/data/attributes/interval'
    end

    [:day, :month, :year].each do |interval|
      it "fails the related #{interval}ly scores without timestamp using mode #{mode}" do
        group                 = Fabricate(:tribe)
        params = { mode: mode, interval: interval }
        get_without_token "/api/v1/groups/#{group.id}/scores", params
        expect(response).to have_http_status(422)
        expect(json['errors'].first['source']['pointer']).to eq '/data/attributes/timestamp'
      end

      it "gets the related #{interval}ly scores with mode '#{mode}'" do
        group                 = Fabricate(:tribe)
        now                   = Time.current
        interval_information  = Group::Base.score_interval(interval.to_s, now.to_i)
        5.times do
          Score.create(mode: mode || 'autarchy', interval: interval_information[0], interval_beginning: interval_information[1], interval_end: interval_information[2], value: (rand * 10).to_i, scoreable_type: 'Group::Base', scoreable_id: group.id)
        end
        interval_information  = Group::Base.score_interval(interval.to_s, 123123)
        Score.create(mode: mode || 'autarchy', interval: interval_information[0], interval_beginning: interval_information[1], interval_end: interval_information[2], value: (rand * 10).to_i, scoreable_type: 'Group::Base', scoreable_id: group.id)

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
    group                 = Fabricate(:tribe)
    now                   = Time.current
    interval_information  = group.set_score_interval('day', now.to_i)
    page_overload.times do
      Score.create(mode: 'autarchy', interval: interval_information[0], interval_beginning: interval_information[1], interval_end: interval_information[2], value: (rand * 10).to_i, scoreable_type: 'Group::Base', scoreable_id: group.id)
    end
    params = { interval: 'day', timestamp: now }
    get_without_token "/api/v1/groups/#{group.id}/scores", params
    expect(response).to have_http_status(200)
    expect(json['meta']['total_pages']).to eq(4)

    get_without_token "/api/v1/groups/#{group.id}/scores", {per_page: 200}
    expect(response).to have_http_status(422)
  end

  it 'gets scores for the current day' do
    group                 = Fabricate(:tribe)
    now                   = Time.current
    yesterday             = Time.current - 1.day
    interval_information  = group.set_score_interval('day', yesterday.to_i)
    page_overload.times do
      Score.create(mode: 'autarchy', interval: interval_information[0], interval_beginning: interval_information[1], interval_end: interval_information[2], value: (rand * 10).to_i, scoreable_type: 'Group::Base', scoreable_id: group.id)
    end
    params = { interval: 'day', timestamp: now }
    get_without_token "/api/v1/groups/#{group.id}/scores", params
    expect(response).to have_http_status(200)
    expect(json['meta']['total_pages']).to eq(4)

    get_without_token "/api/v1/groups/#{group.id}/scores", {per_page: 200}
    expect(response).to have_http_status(422)
  end


  it 'gets the related managers for group only with token' do
    access_token  = Fabricate(:simple_access_token)
    group         = Fabricate(:tribe)
    group.registers << Fabricate(:input_meter).input_register
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
    group         = Fabricate(:tribe)
    page_overload.times do
      user = Fabricate(:user)
      user.profile.update(readable: 'world')
      user.add_role(:manager, group)
    end
    page_overload.times do
      user = Fabricate(:user)
      user.add_role(:manager, group)
    end
    get_with_token "/api/v1/groups/#{group.id}/managers", access_token.token
    expect(response).to have_http_status(200)
    expect(json['meta']['total_pages']).to eq(4)

    access_token  = Fabricate(:full_access_token_as_admin)
    get_with_token "/api/v1/groups/#{group.id}/managers", access_token.token
    expect(response).to have_http_status(200)
    expect(json['meta']['total_pages']).to eq(7)

    get_with_token "/api/v1/groups/#{group.id}/managers", {per_page: 200}, access_token.token
    expect(response).to have_http_status(422)
  end

  it 'paginates members' do
    access_token  = Fabricate(:simple_access_token)
    group         = Fabricate(:tribe_with_members_readable_by_world, members: page_overload * 2)

    group.members[0..page_overload].each do |u|
      u.profile.update(readable: 'world')
    end

    get_with_token "/api/v1/groups/#{group.id}/members", access_token.token
    expect(response).to have_http_status(200)
    expect(json['meta']['total_pages']).to eq(4)

    access_token  = Fabricate(:full_access_token_as_admin)
    get_with_token "/api/v1/groups/#{group.id}/members", access_token.token
    expect(response).to have_http_status(200)
    expect(json['meta']['total_pages']).to eq(7)

    get_with_token "/api/v1/groups/#{group.id}/members", {per_page: 200}, access_token.token
    expect(response).to have_http_status(422)
  end

  it 'gets the related members for group only with token' do
    access_token  = Fabricate(:simple_access_token)
    group         = Fabricate(:tribe_with_members_readable_by_world)

    get_with_token "/api/v1/groups/#{group.id}/members", access_token.token
    expect(response).to have_http_status(200)
    get_without_token "/api/v1/groups/#{group.id}/members"
    expect(response).to have_http_status(401)
  end

  it 'does not add/replace/delete group manager without token' do
    group  = Fabricate(:tribe)
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
    register  = Fabricate(:output_meter).output_register
    register.update(readable: :world)
    group           = Fabricate(:tribe)
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
    member.add_role(:member, register)
    group.registers << register
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
    group           = Fabricate(:tribe)
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
    register  = Fabricate(:input_meter).input_register
    register.update(readable: :world)
    group           = Fabricate(:tribe)
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
    member.add_role(:member, register)
    group.registers << register
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
    group         = Fabricate(:tribe)
    user          = Fabricate(:user)
    consumer      = Fabricate(:user)
    producer      = Fabricate(:user)
    register_in         = Fabricate(:input_meter).input_register
    register_out        = Fabricate(:output_meter).output_register
    user.add_role(:member, register_in)
    user.add_role(:manager, register_in)
    user.add_role(:member, register_out)
    user.add_role(:manager, register_out)
    producer.add_role(:manager, register_in)
    consumer.add_role(:member, register_in)
    producer.add_role(:member, register_out)
    consumer.add_role(:manager, register_out)
    group.registers += [register_in, register_out]

    get_with_token "/api/v1/groups/#{group.id}/energy-producers", access_token.token
    expect(response).to have_http_status(200)
    expect(json['data'].size).to eq(0)

    get_with_token "/api/v1/groups/#{group.id}/energy-consumers", access_token.token
    expect(response).to have_http_status(200)
    expect(json['data'].size).to eq(0)

    manager = User.find(access_token.resource_owner_id)
    manager.add_role(:manager, register_in)
    manager.add_role(:member, register_out)

    get_with_token "/api/v1/groups/#{group.id}/energy-producers", access_token.token
    expect(response).to have_http_status(200)
    expect(json['data'].size).to eq(1)

    get_with_token "/api/v1/groups/#{group.id}/energy-consumers", access_token.token
    expect(response).to have_http_status(200)
    expect(json['data'].size).to eq(1)
  end

  it 'gets the related comments for the group only with token' do
    access_token    = Fabricate(:simple_access_token)
    group           = Fabricate(:tribe_with_two_comments_readable_by_world)
    comments        = group.comment_threads

    get_without_token "/api/v1/groups/#{group.id}/comments"
    expect(response).to have_http_status(401)
    get_with_token "/api/v1/groups/#{group.id}/comments", access_token.token
    expect(response).to have_http_status(200)
    comments.each do |comment|
      expect(json['data'].find{ |c| c['id'] == comment.id }['attributes']['body']).to eq(comment.body)
    end
  end



  it 'gets the related metering_point_operator_contract for the localpool only with full token' do
    group  = Fabricate(:localpool_forstenried)

    full_access_token = Fabricate(:full_access_token)
    get_with_token "/api/v1/groups/localpools/#{group.id}/metering-point-operator-contract", full_access_token.token
    expect(response).to have_http_status(403)

    manager_access_token = Fabricate(:full_access_token)
    manager_user          = User.find(manager_access_token.resource_owner_id)
    manager_user.add_role(:manager, group)
    get_with_token "/api/v1/groups/localpools/#{group.id}/metering-point-operator-contract", manager_access_token.token
    expect(response).to have_http_status(200)
    expect(json['data']['id']).to eq(group.metering_point_operator_contract.id)
  end


  it 'gets the related localpool-processing-contract for the localpool only with full token' do
    group  = Fabricate(:localpool_forstenried)

    full_access_token = Fabricate(:full_access_token)
    get_with_token "/api/v1/groups/localpools/#{group.id}/localpool-processing-contract", full_access_token.token
    expect(response).to have_http_status(403)

    manager_access_token = Fabricate(:full_access_token)
    manager_user          = User.find(manager_access_token.resource_owner_id)
    manager_user.add_role(:manager, group)
    get_with_token "/api/v1/groups/localpools/#{group.id}/localpool-processing-contract", manager_access_token.token
    expect(response).to have_http_status(200)
    expect(json['data']['id']).to eq(group.localpool_processing_contract.id)
  end



  it 'paginates comments' do
    access_token    = Fabricate(:simple_access_token).token
    group           = Fabricate(:tribe)
    user            = Fabricate(:user)
    comment_params  = {
      commentable_id:     group.id,
      commentable_type:   'Group::Base',
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
    expect(json['meta']['total_pages']).to eq(4)

    get_with_token "/api/v1/groups/#{group.id}/comments", {per_page: 200}, access_token
    expect(response).to have_http_status(422)
  end




end
