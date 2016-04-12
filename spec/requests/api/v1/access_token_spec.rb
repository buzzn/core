describe "AccessTokens API" do

  it 'does not creates a AccessToken without token' do
    access_token  = Fabricate(:admin_access_token)
    access_token.update_attribute :scopes, 'admin'
    application = Fabricate(:application)

    request_params = {
      application_id: application.id,
      scopes: 'read, write'
    }.to_json

    post_without_token "/api/v1/access-tokens", request_params
    expect(response).to have_http_status(401)
  end


  it 'does not creates a AccessToken with read token' do
    access_token  = Fabricate(:admin_access_token)
    access_token.update_attribute :scopes, 'read'
    application = Fabricate(:application)

    request_params = {
      application_id: application.id,
      scopes: 'read, write'
    }.to_json

    post_with_token "/api/v1/access-tokens", request_params, access_token.token
    expect(response).to have_http_status(403)
  end


  it 'does creates a AccessToken with admin token' do
    access_token  = Fabricate(:admin_access_token)
    access_token.update_attribute :scopes, 'admin'
    application = Fabricate(:application)

    request_params = {
      application_id: application.id,
      scopes: 'read, write'
    }.to_json

    post_with_token "/api/v1/access-tokens", request_params, access_token.token
    expect(response).to have_http_status(201)
  end




end
