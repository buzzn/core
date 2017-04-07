describe "Users API" do

  let(:page_overload) { 33 }


  # RETRIEVE me

  it 'does not get me without token' do
    get_without_token "/api/v1/users/me"
    expect(response).to have_http_status(401)
  end


  [:simple_access_token, :full_access_token, :smartmeter_access_token].each do |token|
    it "gets me with #{token}" do
      access_token = Fabricate(token)
      get_with_token "/api/v1/users/me", access_token.token
      expect(response).to have_http_status(200)
      expect(json['data']['id']).to eq access_token.resource_owner_id
    end
  end


  # RETRIEVE users

  it 'does not get users without token' do
    get_without_token "/api/v1/users"
    expect(response).to have_http_status(401)
  end

  [:simple_access_token, :smartmeter_access_token].each do |token|
    it "does not get users with #{token}" do
      access_token = Fabricate(token)
      get_with_token "/api/v1/users", {}, access_token.token
      expect(response).to have_http_status(403)
    end
  end


  it 'get all users with full access token as admin' do
    Fabricate(:user)
    Fabricate(:user)
    access_token = Fabricate(:full_access_token_as_admin).token
    get_with_token '/api/v1/users', {}, access_token
    expect(response).to have_http_status(200)
    expect(json['data'].size).to eq User.all.size
  end


  it 'search users with full access token as admin' do
    user = Fabricate(:user)
    Fabricate(:user)
    Fabricate(:user)
    access_token = Fabricate(:full_access_token_as_admin).token

    request_params = { filter: user.email }
    get_with_token '/api/v1/users', request_params, access_token

    expect(response).to have_http_status(200)
    expect(json['data'].size).to eq 1
    expect(json['data'].first['id']).to eq user.id
  end

  it 'does not gets an user without token' do
    user = Fabricate(:user)
    get_without_token "/api/v1/users/#{user.id}"
    expect(response).to have_http_status(401)
  end

 [:simple_access_token, :smartmeter_access_token].each do |token|
    it "does not get an user with #{token}" do
      access_token = Fabricate(token)
      user         = Fabricate(:user)
      get_with_token "/api/v1/users/#{user.id}", access_token.token
      expect(response).to have_http_status(403)
    end
  end


  # everything else . . .

  it 'gets user profile only with token' do
    access_token  = Fabricate(:simple_access_token)
    user          = User.find(access_token.resource_owner_id)

    get_without_token "/api/v1/users/#{user.id}/profile"
    expect(response).to have_http_status(401)
    get_with_token "/api/v1/users/#{user.id}/profile", access_token.token
    expect(response).to have_http_status(200)
  end


  it 'gets related bank_account for User' do
    stranger_access_token = Fabricate(:full_access_token)
    user_access_token     = Fabricate(:full_access_token)
    user                  = User.find(user_access_token.resource_owner_id)

    get_with_token "/api/v1/users/#{user.id}/bank-account", stranger_access_token.token
    expect(response).to have_http_status(403)

    get_with_token "/api/v1/users/#{user.id}/bank-account", user_access_token.token
    expect(response).to have_http_status(200)
    expect(json['data']['id']).to eq(user.bank_account.id)
  end

  [:full_access_token, :smartmeter_access_token].each do |token|
    it "gets all related meters with #{token}" do
      meter1 = Fabricate(:input_meter)
      meter2 = Fabricate(:output_meter)
      meter3 = Fabricate(:meter)

      access_token = Fabricate(token)
      user         = User.find(access_token.resource_owner_id)
      user.add_role(:manager, meter1.input_register)
      user.add_role(:manager, meter2.output_register)

      get_with_token "/api/v1/users/#{user.id}/meters", access_token.token
      expect(response).to have_http_status(200)
      expect(json['data'].size).to eq(2)
    end
  end

  it 'get all meters' do
    access_token = Fabricate(:full_access_token_as_admin)
    user         = Fabricate(:user)
    page_overload.times do
      meter = Fabricate(:meter)
      user.add_role(:manager, meter.registers.first)
    end

    pages_profile_ids = []
    params = {order_direction: 'DESC', order_by: 'created_at'}
    get_with_token "/api/v1/users/#{user.id}/meters", params, access_token.token
    expect(response).to have_http_status(200)
    expect(json['data'].size).to eq(page_overload)
  end




  it 'gets the related meters for User but filtered by manufacturer_product_serialnumber' do
    meter1 = Fabricate(:input_meter)
    meter2 = Fabricate(:output_meter)
    meter3 = Fabricate(:meter)

    access_token  = Fabricate(:full_access_token)
    user          = User.find(access_token.resource_owner_id)
    user.add_role(:manager, meter1.input_register)
    user.add_role(:manager, meter2.output_register)

    request_params = {
      filter: meter1.manufacturer_product_serialnumber
    }

    get_with_token "/api/v1/users/#{user.id}/meters", request_params, access_token.token
    expect(response).to have_http_status(200)
    expect(json['data'].size).to eq(1)
    expect(json['data'].first['attributes']['manufacturer-product-serialnumber']).to eq(meter1.manufacturer_product_serialnumber)
  end

end
