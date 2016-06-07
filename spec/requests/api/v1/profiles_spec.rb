describe "Profiles API" do


  it 'get all profiles with token' do
    Fabricate(:profile)
    Fabricate(:profile)
    access_token = Fabricate(:access_token).token
    get_with_token '/api/v1/profiles', {}, access_token
    expect(response).to have_http_status(200)
  end


  it 'does not gets a profile without token' do
    profile = Fabricate(:profile)
    get_without_token "/api/v1/profiles/#{profile.id}"
    expect(response).to have_http_status(401)
  end


  it 'does not gets a profile as foreigner' do
    access_token = Fabricate(:access_token)
    profile = Fabricate(:profile)
    get_with_token "/api/v1/profiles/#{profile.id}", access_token.token
    expect(response).to have_http_status(403)
  end


  it 'does gets a profile as admin' do
    access_token  = Fabricate(:admin_access_token)
    profile       = Fabricate(:profile)
    get_with_token "/api/v1/profiles/#{profile.id}", access_token.token
    expect(response).to have_http_status(200)
  end


  it 'does gets a profile as friend' do
    access_token      = Fabricate(:access_token_with_friend)
    token_user        = User.find(access_token.resource_owner_id)
    token_user_friend = token_user.friends.first
    get_with_token "/api/v1/profiles/#{token_user_friend.profile.id}", access_token.token
    expect(response).to have_http_status(200)
  end


  it 'does not creates a profile as simple user' do
    access_token = Fabricate(:access_token)
    profile = Fabricate.build(:profile)

    request_params = {
      user_name:  profile.user_name,
      first_name: profile.first_name,
      last_name:  profile.last_name
    }.to_json

    post_with_token "/api/v1/profiles", request_params, access_token.token
    expect(response).to have_http_status(403)
  end


  it 'creates a profile as admin' do
    access_token = Fabricate(:admin_access_token)
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



end
