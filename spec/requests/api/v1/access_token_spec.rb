describe "AccessTokens API" do

  it 'does not creates a AccessToken without token' do
    post_without_token "/api/v1/access-tokens", {}.to_json
    expect(response).to have_http_status(401)
  end


  [:public_access_token,
   :smartmeter_access_token].each do |token|

    it "does not creates a AccessToken with #{token}" do
      access_token  = Fabricate(token)
      post_with_token "/api/v1/access-tokens", {
      application_id: 123,
      scopes: 'smartmeter, full_edit, unknown'}.to_json, access_token.token
      expect(response).to have_http_status(403)
    end

  end


  it 'does not create a AccessToken with full_edit_access_token' do
    access_token  = Fabricate(:full_edit_access_token)
    application = Fabricate(:application)

    request_params = {
      application_id: application.id,
      scopes: 'smartmeter, full_edit, unknown'
    }.to_json

    post_with_token "/api/v1/access-tokens", request_params, access_token.token
    expect(response).to have_http_status(403)
  end


  it 'does not create a AccessToken with unknown scope as admin with full_edit_access_token' do
    access_token  = Fabricate(:full_edit_access_token_as_admin)
    application = Fabricate(:application)

    request_params = {
      application_id: application.id,
      scopes: 'smartmeter, full_edit, unknown'
    }.to_json

    post_with_token "/api/v1/access-tokens", request_params, access_token.token
    expect(response).to have_http_status(400)
  end


  it 'creates a AccessToken with manager token as admin' do
    access_token  = Fabricate(:full_edit_access_token_as_admin)
    application = Fabricate(:application)

    request_params = {
      application_id: application.id,
      scopes: 'smartmeter, full_edit'
    }.to_json

    post_with_token "/api/v1/access-tokens", request_params, access_token.token
    expect(response).to have_http_status(201)
  end

end
