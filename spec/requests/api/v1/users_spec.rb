describe "Users API" do


  it 'gets the current user' do
    user          = Fabricate(:user)
    access_token  = Fabricate(:access_token, resource_owner_id: user.id)

    get_with_token '/api/v1/users/me', access_token.token

    expect(response).to be_success
    expect(json['data']['attributes']['slug']).to eq(user.slug)
  end


  # it 'gets a singe user' do
  #   user = Fabricate(:user)

  #   get "/api/v1/users/#{user.id}"
  #   json = JSON.parse(response.body)

  #   # test for the 200 status-code
  #   expect(response).to be_success
  #   expect(json['data']['attributes']['slug']).to eq(user.slug)
  # end


  # it 'creates a singe user' do
  #   get "/api/v1/users/create"

  #   json = JSON.parse(response.body)

  #   # test for the 200 status-code
  #   expect(response).to be_success
  #   expect(json['data']['attributes']['slug']).to eq(user.slug)
  # end





end