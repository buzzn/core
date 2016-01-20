describe "Users API" do


  it 'gets the current user' do
    user  = Fabricate(:user)
    app   = Doorkeeper::Application.create(name: 'backend')
    token = Doorkeeper::AccessToken.create!(:application_id => app.id, :resource_owner_id => user.id).token

    request_headers = {
      "Accept"              => "application/json",
      "Content-Type"        => "application/json",
      "HTTP_AUTHORIZATION"  => "Bearer #{token}"
    }

    get "/api/v1/users/me", nil, request_headers

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