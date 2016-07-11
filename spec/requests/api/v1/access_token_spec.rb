describe "AccessTokens API" do

  it 'does not creates a AccessToken without token' do
    access_token  = Fabricate(:manager_access_token_as_admin)
    application = Fabricate(:application)

    request_params = {
      application_id: application.id,
      scopes: 'smartmeter, manager'
    }.to_json

    post_without_token "/api/v1/access-tokens", request_params
    expect(response).to have_http_status(401)
  end


  [:public_access_token,
   :smartmeter_access_token,
   :manager_access_token].each do |token|

    it "does not creates a AccessToken with #{token}" do
      access_token  = Fabricate(token)
      application = Fabricate(:application)

      request_params = {
        application_id: application.id,
        scopes: 'smartmeter, manager'
      }.to_json

      post_with_token "/api/v1/access-tokens", request_params, access_token.token
      expect(response).to have_http_status(403)
    end

  end


  it 'does not create a AccessToken with unknown scope as admin with manager_access_token' do
    access_token  = Fabricate(:manager_access_token_as_admin)
    application = Fabricate(:application)

    request_params = {
      application_id: application.id,
      scopes: 'smartmeter, manager, unknown'
    }.to_json

    post_with_token "/api/v1/access-tokens", request_params, access_token.token
    expect(response).to have_http_status(400)
  end


  it 'creates a AccessToken with manager token as admin' do
    access_token  = Fabricate(:manager_access_token_as_admin)
    application = Fabricate(:application)

    request_params = {
      application_id: application.id,
      scopes: 'smartmeter, manager'
    }.to_json

    post_with_token "/api/v1/access-tokens", request_params, access_token.token
    expect(response).to have_http_status(201)
  end

end
