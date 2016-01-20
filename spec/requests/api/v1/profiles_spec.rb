describe "Profiles API" do


  it 'gets a profile' do
    profile = Fabricate(:profile)

    get "/api/v1/profiles/#{profile.id}"

    expect(response).to be_success
    expect(json['data']['attributes']['slug']).to eq(profile.slug)
  end





  it 'creates a profile' do
    token = Fabricate(:admin_access_token).token

    profile = Fabricate.build(:profile)

    request_params = {
      user_name:  profile.user_name,
      first_name: profile.first_name,
      last_name:  profile.last_name
    }.to_json

    post_with_token "/api/v1/profiles", request_params, token

    expect(response).to be_success
    expect(json['data']['attributes']['first-name']).to eq(profile.first_name)
    expect(json['data']['attributes']['last-name']).to eq(profile.last_name)
  end





end