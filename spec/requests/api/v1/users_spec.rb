describe "Users API" do

  before(:all) do
    @page_overload = 11
  end


  it 'get all users with admin token' do
    Fabricate(:user)
    Fabricate(:user)
    access_token = Fabricate(:admin_access_token).token
    get_with_token '/api/v1/users', {}, access_token
    expect(response).to have_http_status(200)
  end

  it 'paginate users' do
    @page_overload.times do
      Fabricate(:user)
    end
    access_token = Fabricate(:admin_access_token).token
    get_with_token '/api/v1/users', {}, access_token
    expect(response).to have_http_status(200)
    expect(json['meta']['total_pages']).to eq(2)
  end


  it 'does not gets a user without token' do
    user = Fabricate(:user)
    get_without_token "/api/v1/users/#{user.id}"
    expect(response).to have_http_status(401)
  end


  it 'does not gets a user as stranger' do
    access_token  = Fabricate(:access_token)
    user          = Fabricate(:user)
    get_with_token "/api/v1/users/#{user.id}", access_token.token
    expect(response).to have_http_status(403)
  end


  it 'gets a user as friend' do
    access_token      = Fabricate(:access_token_with_friend)
    token_user        = User.find(access_token.resource_owner_id)
    token_user_friend = token_user.friends.first
    get_with_token "/api/v1/users/#{token_user_friend.id}", access_token.token
    expect(response).to have_http_status(200)
  end


  it 'creates a user as admin' do
    access_token  = Fabricate(:admin_access_token)

    user = Fabricate.build(:user)
    request_params = {
      email:      user.email,
      password:   user.password,
      user_name:  user.profile.user_name,
      first_name: user.profile.first_name,
      last_name:  user.profile.last_name
    }.to_json
    post_with_token "/api/v1/users", request_params, access_token.token
    expect(response).to have_http_status(201)
    expect(json['data']['attributes']['email']).to eq(user.email)
  end


  it 'gets the related groups for User' do
    access_token  = Fabricate(:access_token)
    group         = Fabricate(:group_readable_by_members)
    user          = User.find(access_token.resource_owner_id)
    metering_point    = Fabricate(:metering_point_readable_by_world)
    user.add_role(:member, metering_point)
    group.metering_points << metering_point
    get_with_token "/api/v1/users/#{user.id}/groups", access_token.token
    expect(response).to have_http_status(200)
  end

  it 'paginate groups' do
    access_token  = Fabricate(:access_token)
    user          = User.find(access_token.resource_owner_id)
    @page_overload.times do
      group             = Fabricate(:group)
      metering_point    = Fabricate(:metering_point_readable_by_world)
      user.add_role(:member, metering_point)
      group.metering_points << metering_point
    end
    get_with_token "/api/v1/users/#{user.id}/groups", access_token.token
    expect(response).to have_http_status(200)
    expect(json['meta']['total_pages']).to eq(2)
  end

  it 'gets related metering points for User' do
    access_token    = Fabricate(:access_token)
    user            = User.find(access_token.resource_owner_id)
    metering_point  = Fabricate(:metering_point)
    user.add_role(:member, metering_point)
    get_with_token "/api/v1/users/#{user.id}/metering-points", access_token.token
    expect(response).to have_http_status(200)
  end


  it 'gets all related meters for User' do
    meter1 = Fabricate(:meter)
    meter2 = Fabricate(:meter)
    meter3 = Fabricate(:meter)

    access_token  = Fabricate(:access_token)
    access_token.update_attribute :scopes, 'admin'
    user = User.find(access_token.resource_owner_id)
    user.add_role(:manager, meter1)
    user.add_role(:manager, meter2)

    get_with_token "/api/v1/users/#{user.id}/meters", access_token.token
    expect(response).to have_http_status(200)
    expect(json['data'].size).to eq(2)
  end

  it 'paginate meters' do
    admin_token = Fabricate(:admin_access_token).token
    user        = Fabricate(:user)
    @page_overload.times do
      meter = Fabricate(:meter)
      user.add_role(:manager, meter)
    end
    get_with_token "/api/v1/users/#{user.id}/meters", admin_token
    expect(response).to have_http_status(200)
    expect(json['meta']['total_pages']).to eq(2)
  end


  it 'gets the related meters for User but filtert by manufacturer_product_serialnumber' do
    meter1 = Fabricate(:meter)
    meter2 = Fabricate(:meter)
    meter3 = Fabricate(:meter)

    access_token  = Fabricate(:access_token)
    access_token.update_attribute :scopes, 'admin'
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
    access_token  = Fabricate(:access_token)
    user          = User.find(access_token.resource_owner_id)
    user.friends << Fabricate(:user)

    get_with_token "/api/v1/users/#{user.id}/friends", access_token.token
    expect(response).to have_http_status(200)
    expect(json['data'].size).to eq(1)
  end


  it 'paginate friends' do
    access_token  = Fabricate(:access_token)
    user          = User.find(access_token.resource_owner_id)
    @page_overload.times do
      user.friends << Fabricate(:user)
    end

    get_with_token "/api/v1/users/#{user.id}/friends", access_token.token
    expect(response).to have_http_status(200)
    expect(json['meta']['total_pages']).to eq(2)
  end

  it 'gets specific friend for user' do
    access_token  = Fabricate(:access_token)
    user          = User.find(access_token.resource_owner_id)
    friend        = Fabricate(:user)
    user.friends << friend

    get_with_token "/api/v1/users/#{user.id}/friends/#{friend.id}", access_token.token
    expect(response).to have_http_status(200)
    expect(json['data']['id']).to eq(friend.id)
  end

  it 'deletes specific friend for user' do
    access_token  = Fabricate(:access_token)
    user          = User.find(access_token.resource_owner_id)
    friend        = Fabricate(:user)
    user.friends << friend

    delete_with_token "/api/v1/users/#{user.id}/friends/#{friend.id}", access_token.token
    expect(response).to have_http_status(200)
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
    access_token  = Fabricate(:access_token)
    user          = User.find(access_token.resource_owner_id)
    target_user   = Fabricate(:user)
    params = {
      receiver_id: target_user.id
    }

    post_with_token "/api/v1/users/#{user.id}/friendship-requests", params.to_json, access_token.token
    expect(response).to have_http_status(201)
  end

  it 'accepts friendship request' do
    access_token  = Fabricate(:access_token_received_friendship_request)
    user          = User.find(access_token.resource_owner_id)
    request       = user.received_friendship_requests.first

    put_with_token "/api/v1/users/#{user.id}/friendship-requests/#{request.id}", {}, access_token.token
    expect(response).to have_http_status(200)
    modified_user = User.find(access_token.resource_owner_id)
    expect(modified_user.friends.size).to eq(1)
    expect(modified_user.received_friendship_requests.size).to eq(0)
  end


  it 'rejects friendship request' do
    access_token  = Fabricate(:access_token_received_friendship_request)
    user          = User.find(access_token.resource_owner_id)
    request       = user.received_friendship_requests.first

    delete_with_token "/api/v1/users/#{user.id}/friendship-requests/#{request.id}", access_token.token
    expect(response).to have_http_status(200)
    modified_user = User.find(access_token.resource_owner_id)
    expect(modified_user.friends.size).to eq(0)
    expect(modified_user.received_friendship_requests.size).to eq(0)
  end


  it 'gets related devices for user' do
    access_token  = Fabricate(:access_token)
    user          = User.find(access_token.resource_owner_id)
    device        = Fabricate(:device)
    user.add_role(:manager, device)

    get_with_token "/api/v1/users/#{user.id}/devices", access_token.token
    expect(response).to have_http_status(200)
    expect(json['data'].size).to eq(1)
  end


  it 'paginate devices' do
    access_token  = Fabricate(:access_token)
    user          = User.find(access_token.resource_owner_id)
    @page_overload.times do
      device      = Fabricate(:device)
      user.add_role(:manager, device)
    end

    get_with_token "/api/v1/users/#{user.id}/devices", access_token.token
    expect(response).to have_http_status(200)
    expect(json['meta']['total_pages']).to eq(2)
  end

end
