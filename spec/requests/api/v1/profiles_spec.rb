describe "Profiles API" do



  it 'does not gets a profile without token' do
    profile = Fabricate(:profile)
    get_without_token "/api/v1/profiles/#{profile.id}"
    expect(response).not_to be_successful
  end


  # it 'does not gets a profile with bad token' do
  #   token = Fabricate(:access_token).token
  #   profile = Fabricate(:profile)
  #   get_with_token "/api/v1/profiles/#{profile.id}", token
  #   expect(response).not_to be_successful
  # end



  it 'does not creates a profile as simple user' do
    token = Fabricate(:access_token).token

    profile = Fabricate.build(:profile)

    request_params = {
      user_name:  profile.user_name,
      first_name: profile.first_name,
      last_name:  profile.last_name
    }.to_json

    post_with_token "/api/v1/profiles", request_params, token

    expect(response).not_to be_successful
  end





  it 'creates a profile as admin' do
    token = Fabricate(:admin_access_token).token

    profile = Fabricate.build(:profile)

    request_params = {
      user_name:  profile.user_name,
      first_name: profile.first_name,
      last_name:  profile.last_name
    }.to_json

    post_with_token "/api/v1/profiles", request_params, token

    expect(response).to be_successful
    expect(json['data']['attributes']['first-name']).to eq(profile.first_name)
    expect(json['data']['attributes']['last-name']).to eq(profile.last_name)
  end





end