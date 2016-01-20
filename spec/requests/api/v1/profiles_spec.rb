describe "Profiles API" do


  it 'gets a profile' do
    profile = Fabricate(:profile)

    get "/api/v1/profiles/#{profile.id}"

    expect(response).to be_success

    expect(json['data']['attributes']['slug']).to eq(profile.slug)
  end


  it 'creates a profile' do
    user = Fabricate(:user)
    user.add_role :admin

    app = Doorkeeper::Application.create(name: 'backend')
    token = Doorkeeper::AccessToken.create!(:application_id => app.id, :resource_owner_id => user.id)

    profile = Fabricate.build(:profile)

    params = {
      user_name:  profile.user_name,
      first_name: profile.first_name,
      last_name:  profile.last_name
    }.to_json

    request_headers = {
      "Accept" => "application/json",
      "Content-Type" => "application/json",
      "Authorization" => "Token token='#{token}'"
    }

    post "/api/v1/profiles", params, request_headers

    expect(response).to be_success
    expect(json['data']['attributes']['first-name']).to eq(profile.first_name)
    expect(json['data']['attributes']['last-name']).to eq(profile.last_name)
  end





end