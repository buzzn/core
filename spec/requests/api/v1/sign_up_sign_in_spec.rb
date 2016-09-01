describe "Sign up and Sign in" do

  it 'signs up a new user and sign in' do
    user = Fabricate.build(:user)
    request_params = {
      email:      user.email,
      password:   user.password,
      profile:  { user_name:  user.profile.user_name,
                  first_name: user.profile.first_name,
                  last_name:  user.profile.last_name }
    }.to_json
    post_without_token "/api/v1/users", request_params
    expect(response).to have_http_status(201)

    post '/oauth/token', {grant_type: 'password', username: user.email, password: user.password, scope: 'full'}, {'Content-Type': 'application/x-www-form-urlencoded', 'Accept': 'application/json'}
    expect(response).to have_http_status(200)
    expect(access_token = json['access_token']).to_not be_nil
    expect(json['refresh_token']).to_not be_nil

    get_with_token '/api/v1/users/me', access_token
    expect(response).to have_http_status(200)
    expect(User.find(json['data']['id'])).to eq User.where(email: user.email).first
  end

  it 'signs in an user and refresh token' do
    user = Fabricate(:user)

    post '/oauth/token', {grant_type: 'password', username: user.email, password: user.password, scope: 'full'}, {'Content-Type': 'application/x-www-form-urlencoded', 'Accept': 'application/json'}
    expect(response).to have_http_status(200)
    expect(json['access_token']).to_not be_nil
    expect(json['refresh_token']).to_not be_nil

    token = json['access_token']
    refresh = json['refresh_token']

    post '/oauth/token', {grant_type: 'refresh_token', refresh_token: refresh}, {'Content-Type': 'application/x-www-form-urlencoded', 'Accept': 'application/json'}
    expect(response).to have_http_status(200)
    expect(access_token = json['access_token']).to_not eq token
    expect(json['refresh_token']).to_not eq refresh

    post '/oauth/token', {grant_type: 'refresh_token', refresh_token: refresh}, {'Content-Type': 'application/x-www-form-urlencoded', 'Accept': 'application/json'}
    expect(response).to have_http_status(401)
    expect(json['error']).to eq 'invalid_grant'

    get_with_token '/oauth/token/info', access_token
    expect(response).to have_http_status(200)
    expect(User.find(json['resource_owner_id'])).to eq user
  end

end
