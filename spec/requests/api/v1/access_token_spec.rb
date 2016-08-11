describe "AccessTokens API" do

  it 'does not create an AccessToken without token' do
    post_without_token "/api/v1/access-tokens", {}.to_json
    expect(response).to have_http_status(401)
  end


  [:public_access_token,
   :smartmeter_access_token].each do |token|

    it "does not create an AccessToken with #{token}" do
      access_token  = Fabricate(token)
      post_with_token "/api/v1/access-tokens", {
      application_id: 123,
      scopes: 'smartmeter, full, unknown'}.to_json, access_token.token
      expect(response).to have_http_status(403)
    end

  end


  it 'does not create an AccessToken with full_access_token' do
    access_token  = Fabricate(:full_access_token)
    application = Fabricate(:application)

    request_params = {
      application_id: application.id,
      scopes: 'smartmeter, full'
    }.to_json

    post_with_token "/api/v1/access-tokens", request_params, access_token.token
    expect(response).to have_http_status(403)
  end


  it 'does not create an AccessToken with unknown scope as admin with full_access_token' do
    access_token  = Fabricate(:full_access_token_as_admin)
    application = Fabricate(:application)

    request_params = {
      application_id: application.id,
      scopes: 'smartmeter, full, unknown'
    }.to_json

    post_with_token "/api/v1/access-tokens", request_params, access_token.token

    expect(response).to have_http_status(422)
    json['errors'].each do |error|
      expect(error['source']['pointer']).to eq "/data/attributes/scopes"
      expect(error['title']).to eq 'Invalid Attribute'
      expect(error['detail']).to eq 'scopes does not have a valid value'
    end
  end


  it 'creates an AccessToken with manager token as admin' do
    access_token  = Fabricate(:full_access_token_as_admin)
    application = Fabricate(:application)

    request_params = {
      application_id: application.id,
      scopes: 'smartmeter, full'
    }.to_json

    post_with_token "/api/v1/access-tokens", request_params, access_token.token

    expect(response).to have_http_status(201)
  end

end
