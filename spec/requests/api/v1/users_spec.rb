describe "Users API" do


  it 'get all users with admin token' do
    Fabricate(:profile)
    Fabricate(:profile)
    access_token = Fabricate(:admin_access_token).token
    get_with_token '/api/v1/users', {}, access_token
    expect(response).to have_http_status(200)
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


  it 'gets the related access_tokens for User' do
    access_token  = Fabricate(:access_token)
    access_token.update_attribute :scopes, 'admin'
    user          = User.find(access_token.resource_owner_id)
    get_with_token "/api/v1/users/#{user.id}/access-tokens", access_token.token
    expect(response).to have_http_status(200)
  end


  it 'gets the related groups for User' do
    access_token  = Fabricate(:access_token)
    group         = Fabricate(:group_readable_by_members)
    user          = User.find(access_token.resource_owner_id)
    get_with_token "/api/v1/users/#{user.id}/groups", access_token.token
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


end
