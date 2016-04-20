describe "Users API" do


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


  it 'does gets a user as friend' do
    access_token      = Fabricate(:access_token_with_friend)
    token_user        = User.find(access_token.resource_owner_id)
    token_user_friend = token_user.friends.first
    get_with_token "/api/v1/users/#{token_user_friend.id}", access_token.token
    expect(response).to have_http_status(200)
  end


  it 'does creates a user as admin' do
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


  it 'does gets the access_tokens for user with admin scope' do
    access_token  = Fabricate(:access_token)
    access_token.update_attribute :scopes, 'admin'
    user          = User.find(access_token.resource_owner_id)
    get_with_token "/api/v1/users/#{user.id}/access-tokens", access_token.token
    expect(response).to have_http_status(200)
  end



end
