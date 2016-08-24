describe "Users API" do

  let(:page_overload) { 11 }


  # RETRIEVE me

  it 'does not get me without token' do
    get_without_token "/api/v1/users/me"
    expect(response).to have_http_status(401)
  end


  it "does not get me with smartmeter_access_token" do
    access_token = Fabricate(:smartmeter_access_token)
    get_with_token "/api/v1/users/me", access_token.token
    expect(response).to have_http_status(403)
  end


  [:public_access_token, :full_access_token].each do |token|
    it "gets me with #{token}" do
      access_token = Fabricate(token)
      get_with_token "/api/v1/users/me", access_token.token
      expect(response).to have_http_status(200)
    end
  end


  # RETRIEVE users

  it 'does not get users without token' do
    get_without_token "/api/v1/users"
    expect(response).to have_http_status(401)
  end

  [:public_access_token, :smartmeter_access_token].each do |token|
    it "does not get users with #{token}" do
      access_token = Fabricate(token)
      get_with_token "/api/v1/users", {}, access_token.token
      expect(response).to have_http_status(403)
    end
  end
  

  it 'get all users with full access token as admin' do
    Fabricate(:user)
    Fabricate(:user)
    access_token = Fabricate(:full_access_token_as_admin).token
    get_with_token '/api/v1/users', {}, access_token
    expect(response).to have_http_status(200)
    expect(json['data'].size).to eq User.all.size
  end


  it 'search users with full access token as admin' do
    user = Fabricate(:user)
    Fabricate(:user)
    Fabricate(:user)
    access_token = Fabricate(:full_access_token_as_admin).token

    request_params = { filter: user.email }
    get_with_token '/api/v1/users', request_params, access_token

    expect(response).to have_http_status(200)
    expect(json['data'].size).to eq 1
    expect(json['data'].first['id']).to eq user.id
  end


  it 'paginate users' do
    page_overload.times do
      Fabricate(:user)
    end
    access_token = Fabricate(:full_access_token_as_admin).token
    get_with_token '/api/v1/users', {}, access_token
    expect(response).to have_http_status(200)
    expect(json['meta']['total_pages']).to eq(2)

    get_with_token "/api/v1/users", {per_page: 200}, access_token
    expect(response).to have_http_status(422)
  end


  it 'does not gets an user without token' do
    user = Fabricate(:user)
    get_without_token "/api/v1/users/#{user.id}"
    expect(response).to have_http_status(401)
  end

 [:public_access_token, :smartmeter_access_token].each do |token|
    it "does not get an user with #{token}" do
      access_token = Fabricate(token)
      user         = Fabricate(:user)
      get_with_token "/api/v1/users/#{user.id}", access_token.token
      expect(response).to have_http_status(403)
    end
  end

 # RETRIEVE users/friend

  it 'gets an user as friend' do
    access_token      = Fabricate(:access_token_with_friend)
    token_user        = User.find(access_token.resource_owner_id)
    token_user_friend = token_user.friends.first
    get_with_token "/api/v1/users/#{token_user_friend.id}", access_token.token
    expect(response).to have_http_status(200)
  end

  # everything else . . .

  it 'does not create an user with missing parameters' do
    access_token  = Fabricate(:full_access_token_as_admin)

    user = Fabricate.build(:user)
    request_params = {
      email:      user.email,
      password:   user.password,
      profile:  { user_name:  user.profile.user_name,
                  first_name: user.profile.first_name,
                  last_name:  user.profile.last_name }
    }

    (request_params.keys + request_params[:profile].keys).each do |name|
      next if name == :profile
      params = request_params.reject { |k,v| k == name }
      unless request_params.key? name
        params[:profile] = request_params[:profile].reject { |k,v| k == name }
        name = "profile[#{name}]"
      end

      post_with_token "/api/v1/users", params.to_json, access_token.token

      expect(response).to have_http_status(422)

      json['errors'].each do |error|
        expect(error['source']['pointer']).to eq "/data/attributes/#{name}"
        expect(error['title']).to eq 'Invalid Attribute'
        expect(error['detail']).to eq "#{name} is missing"
      end
    end
  end

  it 'does not create an user with invalid parameters' do
    access_token  = Fabricate(:full_access_token_as_admin)

    user = Fabricate.build(:user)
    request_params = {
      email:      user.email,
      password:   user.password,
      profile:  { user_name:  user.profile.user_name,
                  first_name: user.profile.first_name,
                  last_name:  user.profile.last_name }
    }

    (request_params.keys + request_params[:profile].keys).each do |name|
      next if name == :profile
      params = request_params.dup
      if params.key? name
        params[name] = 'a' * 2000
      else
        profile = params[:profile] = params[:profile].dup
        profile[name] = 'a' * 2000
        name = "profile[#{name}]"
      end

      post_with_token "/api/v1/users", params.to_json, access_token.token

      expect(response).to have_http_status(422)

      json['errors'].each do |error|
        expect(error['source']['pointer']).to eq "/data/attributes/#{name}"
        expect(error['title']).to eq 'Invalid Attribute'
        expect(error['detail']).to match Regexp.new(Regexp.quote(name))
      end
    end
  end

  xit 'does not update an user with invalid parameters' do
    access_token  = Fabricate(:full_access_token_as_admin)
    user = Fabricate(:user)

    [:email, :password, :user_name, :first_name, :last_name].each do |name|
      if name.to_s.end_with? 'name'
        params = { profile: { "#{name}": 'a' * 2000 } }
        name = "profile[#{name}]"
      else
        params = { "#{name}": 'a' * 2000 }
      end

      patch_with_token "/api/v1/users/#{user.id}", params.to_json, access_token.token

      expect(response).to have_http_status(422)
      json['errors'].each do |error|
        expect(error['source']['pointer']).to eq "/data/attributes/#{name}"
        expect(error['title']).to eq 'Invalid Attribute'
        expect(error['detail']).to match Regexp.new(Regexp.quote(name))
      end
    end
  end

  it 'creates an user as admin' do
    access_token  = Fabricate(:full_access_token_as_admin)

    user = Fabricate.build(:user)
    request_params = {
      email:      user.email,
      password:   user.password,
      profile:  { user_name:  user.profile.user_name,
                  first_name: user.profile.first_name,
                  last_name:  user.profile.last_name }
    }.to_json
    post_with_token "/api/v1/users", request_params, access_token.token
    expect(response).to have_http_status(201)
    expect(json['data']['attributes']['email']).to eq(user.email)
  end


  it 'gets the related groups for User' do
    access_token  = Fabricate(:public_access_token)
    group         = Fabricate(:group_readable_by_members)
    user          = User.find(access_token.resource_owner_id)
    metering_point    = Fabricate(:metering_point_readable_by_world)
    user.add_role(:member, metering_point)
    group.metering_points << metering_point
    get_with_token "/api/v1/users/#{user.id}/groups", access_token.token
    expect(response).to have_http_status(200)
  end

  it 'paginate groups' do
    access_token  = Fabricate(:public_access_token)
    user          = User.find(access_token.resource_owner_id)
    page_overload.times do
      group             = Fabricate(:group)
      metering_point    = Fabricate(:metering_point_readable_by_world)
      user.add_role(:member, metering_point)
      group.metering_points << metering_point
    end
    get_with_token "/api/v1/users/#{user.id}/groups", access_token.token
    expect(response).to have_http_status(200)
    expect(json['meta']['total_pages']).to eq(2)

    get_with_token "/api/v1/users/#{user.id}/groups", {per_page: 200}, access_token.token
    expect(response).to have_http_status(422)
  end

  it 'gets related metering points for User' do
    access_token    = Fabricate(:public_access_token)
    user            = User.find(access_token.resource_owner_id)
    metering_point  = Fabricate(:metering_point)
    user.add_role(:member, metering_point)
    get_with_token "/api/v1/users/#{user.id}/metering-points", access_token.token
    expect(response).to have_http_status(200)
  end

  [:full_access_token, :smartmeter_access_token].each do |token|
    it "gets all related meters with #{token}" do
      meter1 = Fabricate(:meter)
      meter2 = Fabricate(:meter)
      meter3 = Fabricate(:meter)

      access_token  = Fabricate(token)
      user = User.find(access_token.resource_owner_id)
      user.add_role(:manager, meter1)
      user.add_role(:manager, meter2)

      get_with_token "/api/v1/users/#{user.id}/meters", access_token.token
      expect(response).to have_http_status(200)
      expect(json['data'].size).to eq(2)
    end
  end

  it 'paginate meters' do
    manager_token = Fabricate(:full_access_token_as_admin).token
    user          = Fabricate(:user)
    page_overload.times do
      meter = Fabricate(:meter)
      user.add_role(:manager, meter)
    end
    get_with_token "/api/v1/users/#{user.id}/meters", manager_token
    expect(response).to have_http_status(200)
    expect(json['meta']['total_pages']).to eq(2)

    get_with_token "/api/v1/users/#{user.id}/meters", {per_page: 200}, manager_token
    expect(response).to have_http_status(422)
  end

  it 'paginate metering_points' do
    access_token = Fabricate(:full_access_token_as_admin).token
    user         = Fabricate(:user)
    page_overload.times do
      metering_point  = Fabricate(:metering_point)
      user.add_role(:member, metering_point)
    end
    get_with_token "/api/v1/users/#{user.id}/metering-points", access_token
    expect(response).to have_http_status(200)
    expect(json['meta']['total_pages']).to eq(2)

    get_with_token "/api/v1/users/#{user.id}/metering-points", {per_page: 200}, access_token
    expect(response).to have_http_status(422)
  end


  it 'gets the related meters for User but filtert by manufacturer_product_serialnumber' do
    meter1 = Fabricate(:meter)
    meter2 = Fabricate(:meter)
    meter3 = Fabricate(:meter)

    access_token  = Fabricate(:full_access_token)
    user          = User.find(access_token.resource_owner_id)
    user.add_role(:manager, meter1)
    user.add_role(:manager, meter2)

    request_params = {
      manufacturer_product_serialnumber: meter1.manufacturer_product_serialnumber
    }

    get_with_token "/api/v1/users/#{user.id}/meters", request_params, access_token.token
    expect(response).to have_http_status(200)
    expect(json['data'].size).to eq(1)
    expect(json['data'].first['attributes']['manufacturer-product-serialnumber']).to eq(meter1.manufacturer_product_serialnumber)
  end

  it 'gets related friends for user' do
    access_token  = Fabricate(:public_access_token)
    user          = User.find(access_token.resource_owner_id)
    user.friends << Fabricate(:user)

    get_with_token "/api/v1/users/#{user.id}/friends", access_token.token
    expect(response).to have_http_status(200)
    expect(json['data'].size).to eq(1)
  end


  it 'paginate friends' do
    access_token  = Fabricate(:public_access_token)
    user          = User.find(access_token.resource_owner_id)
    page_overload.times do
      user.friends << Fabricate(:user)
    end

    get_with_token "/api/v1/users/#{user.id}/friends", access_token.token
    puts response.body
    expect(response).to have_http_status(200)
    expect(json['meta']['total_pages']).to eq(2)

    get_with_token "/api/v1/users/#{user.id}/friends", {per_page: 200}, access_token.token
    expect(response).to have_http_status(422)
  end

  it 'gets specific friend for user' do
    access_token  = Fabricate(:public_access_token)
    user          = User.find(access_token.resource_owner_id)
    friend        = Fabricate(:user)
    user.friends << friend

    get_with_token "/api/v1/users/#{user.id}/friends/#{friend.id}", access_token.token
    puts response.body
    expect(response).to have_http_status(200)
    expect(json['data']['id']).to eq(friend.id)
  end

  it 'deletes specific friend for user' do
    access_token  = Fabricate(:public_access_token)
    user          = User.find(access_token.resource_owner_id)
    friend        = Fabricate(:user)
    user.friends << friend

    delete_with_token "/api/v1/users/#{user.id}/friends/#{friend.id}", access_token.token
    expect(response).to have_http_status(204)
    get_with_token "/api/v1/users/#{user.id}/friends/#{friend.id}", access_token.token
    expect(response).to have_http_status(404)
  end


  it 'lists received friendship requests' do
    access_token  = Fabricate(:access_token_received_friendship_request)
    user          = User.find(access_token.resource_owner_id)

    get_with_token "/api/v1/users/#{user.id}/friendship-requests", access_token.token
    expect(response).to have_http_status(200)
    expect(json['data'].size).to eq(1)
  end

  it 'creates a new friendship request' do
    access_token  = Fabricate(:public_access_token)
    user          = User.find(access_token.resource_owner_id)
    target_user   = Fabricate(:user)
    params = {
      receiver_id: target_user.id
    }

    post_with_token "/api/v1/users/#{user.id}/friendship-requests", params.to_json, access_token.token
    expect(response).to have_http_status(201)
  end

  it 'creates activity with a new friendship request' do
    access_token  = Fabricate(:public_access_token)
    user          = User.find(access_token.resource_owner_id)
    target_user   = Fabricate(:user)
    params = {
      receiver_id: target_user.id
    }

    post_with_token "/api/v1/users/#{user.id}/friendship-requests", params.to_json, access_token.token
    activities = PublicActivity::Activity.where({ owner_type: 'User', owner_id: user.id })
    expect(activities.first.key).to eq('friendship_request.create')
  end

  it 'accepts friendship request' do
    access_token  = Fabricate(:access_token_received_friendship_request)
    user          = User.find(access_token.resource_owner_id)
    request       = user.received_friendship_requests.first

    patch_with_token "/api/v1/users/#{user.id}/friendship-requests/#{request.id}", {}, access_token.token
    expect(response).to have_http_status(204)
    modified_user = User.find(access_token.resource_owner_id)
    expect(modified_user.friends.size).to eq(1)
    expect(modified_user.received_friendship_requests.size).to eq(0)
  end


  it 'creates activity when accepts friendship request' do
    access_token  = Fabricate(:access_token_received_friendship_request)
    user          = User.find(access_token.resource_owner_id)
    request       = user.received_friendship_requests.first

    patch_with_token "/api/v1/users/#{user.id}/friendship-requests/#{request.id}", {}, access_token.token
    activities = PublicActivity::Activity.where({ owner_type: 'User', owner_id: user.id })
    expect(activities.first.key).to eq('friendship.create')
  end


  it 'rejects friendship request' do
    access_token  = Fabricate(:access_token_received_friendship_request)
    user          = User.find(access_token.resource_owner_id)
    request       = user.received_friendship_requests.first

    delete_with_token "/api/v1/users/#{user.id}/friendship-requests/#{request.id}", access_token.token
    expect(response).to have_http_status(204)
    modified_user = User.find(access_token.resource_owner_id)
    expect(modified_user.friends.size).to eq(0)
    expect(modified_user.received_friendship_requests.size).to eq(0)
  end


  it 'creates activity when rejects friendship request' do
    access_token  = Fabricate(:access_token_received_friendship_request)
    user          = User.find(access_token.resource_owner_id)
    request       = user.received_friendship_requests.first

    delete_with_token "/api/v1/users/#{user.id}/friendship-requests/#{request.id}", access_token.token
    activities = PublicActivity::Activity.where({ owner_type: 'User', owner_id: user.id })
    expect(activities.first.key).to eq('friendship_request.reject')
  end


  it 'gets related devices for user' do
    access_token  = Fabricate(:public_access_token)
    user          = User.find(access_token.resource_owner_id)
    device        = Fabricate(:device)
    user.add_role(:manager, device)

    get_with_token "/api/v1/users/#{user.id}/devices", access_token.token
    expect(response).to have_http_status(200)
    expect(json['data'].size).to eq(1)
  end


  it 'paginate devices' do
    access_token  = Fabricate(:public_access_token)
    user          = User.find(access_token.resource_owner_id)
    page_overload.times do
      device      = Fabricate(:device)
      user.add_role(:manager, device)
    end

    get_with_token "/api/v1/users/#{user.id}/devices", access_token.token
    expect(response).to have_http_status(200)
    expect(json['meta']['total_pages']).to eq(2)

    get_with_token "/api/v1/users/#{user.id}/devices", {per_page: 200}, access_token.token
    expect(response).to have_http_status(422)
  end

  it 'gets user activities' do
    access_token  = Fabricate(:public_access_token)
    user          = User.find(access_token.resource_owner_id)
    user2         = Fabricate(:user)
    Fabricate(:friendship_request_with_activity, { sender: user, receiver: user2 })

    get_with_token "/api/v1/users/#{user.id}/activities", access_token.token
    expect(response).to have_http_status(200)
    expect(json['data'].first['attributes']['owner-id']).to eq(user.id)
  end

end
