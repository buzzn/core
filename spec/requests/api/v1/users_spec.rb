describe "Users API" do


  it 'gets the current user' do
    access_token  = Fabricate(:access_token)
    user          = User.find(access_token.resource_owner_id)
    get_with_token '/api/v1/users/me', access_token.token
    expect(response).to be_success
    expect(json['data']['attributes']['slug']).to eq(user.slug)
  end


  it 'does not gets a user without token' do
    user = Fabricate(:user)
    get_without_token "/api/v1/users/#{user.id}"
    expect(response).not_to be_successful
  end


  it 'does not gets a user as stranger' do
    access_token  = Fabricate(:access_token)
    user          = Fabricate(:user)
    get_with_token "/api/v1/users/#{user.id}", access_token.token
    expect(response).not_to be_successful
  end


  it 'does gets a user as friend' do
    access_token      = Fabricate(:access_token_with_friend)
    token_user        = User.find(access_token.resource_owner_id)
    token_user_friend = token_user.friends.first
    get_with_token "/api/v1/users/#{token_user_friend.id}", access_token.token
    expect(response).to be_successful
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
    expect(response).to be_successful
    expect(json['data']['attributes']['email']).to eq(user.email)
  end


  it 'does not creates a user as guest with missing data' do
    user = Fabricate.build(:user)
    request_params = {
      email:      user.email,
      user_name:  user.profile.user_name,
      first_name: user.profile.first_name,
      last_name:  user.profile.last_name
    }.to_json
    post_without_token "/api/v1/users", request_params
    expect(response).not_to be_successful
  end


  it 'does not creates a user as guest with short password' do
    user = Fabricate.build(:user)
    request_params = {
      email:      user.email,
      password:   '1234',
      user_name:  user.profile.user_name,
      first_name: user.profile.first_name,
      last_name:  user.profile.last_name
    }.to_json
    post_without_token "/api/v1/users", request_params
    expect(response).not_to be_successful
  end


end
