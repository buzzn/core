describe 'Addresses API' do

  let(:page_overload) { 11 }


  it 'does not get all addresses with regular token or without token' do
    Fabricate(:address)
    access_token = Fabricate(:simple_access_token)

    get_with_token '/api/v1/addresses', {}, access_token.token
    expect(response).to have_http_status(403)
    get_without_token '/api/v1/addresses'
    expect(response).to have_http_status(401)
  end

  it 'get all addresses with full access token' do
    address      = Fabricate(:address)
    access_token = Fabricate(:full_access_token_as_admin)

    get_with_token '/api/v1/addresses', {}, access_token.token
    expect(response).to have_http_status(200)
    expect(json['data'].size).to eq(1)
    expect(json['data'].first['attributes']['time-zone']).to eq(address['time_zone'])
  end


  it 'paginate addresses with full access token' do
    page_overload.times do
      Fabricate(:address)
    end
    access_token = Fabricate(:full_access_token_as_admin)

    get_with_token '/api/v1/addresses', {}, access_token.token
    expect(response).to have_http_status(200)
    expect(json['meta']['total_pages']).to eq(2)
    get_with_token '/api/v1/addresses', {per_page: 200}, access_token.token
    expect(response).to have_http_status(422)
  end

  it 'get address only with full access token' do
    address           = Fabricate(:address)
    full_access_token = Fabricate(:full_access_token_as_admin)
    access_token      = Fabricate(:simple_access_token)

    get_without_token "/api/v1/addresses/#{address.id}"
    expect(response).to have_http_status(401)
    get_with_token "/api/v1/addresses/#{address.id}", {}, access_token.token
    expect(response).to have_http_status(403)
    get_with_token "/api/v1/addresses/#{address.id}", {}, full_access_token.token
    expect(response).to have_http_status(200)
  end

  it 'creates address using full token' do
    full_access_token = Fabricate(:full_access_token_as_admin)
    access_token      = Fabricate(:simple_access_token)
    params = {
      address: '*****',
      street_name: '*****',
      street_number: '*****',
      city: '*****',
      state: '*****',
      zip: 88888,
      country: '*****',
    }

    post_without_token '/api/v1/addresses', params.to_json
    expect(response).to have_http_status(401)
    post_with_token '/api/v1/addresses', params.to_json, access_token.token
    expect(response).to have_http_status(403)
    post_with_token '/api/v1/addresses', params.to_json, full_access_token.token
    expect(response).to have_http_status(201)
  end

  it 'updates address using full token' do
    full_access_token = Fabricate(:full_access_token_as_admin)
    access_token      = Fabricate(:simple_access_token)
    params = {
      address: '*****',
      street_name: '*****',
      street_number: '*****',
      city: '*****',
      state: '*****',
      zip: 88888,
      country: '*****',
    }

    post_without_token '/api/v1/addresses', params.to_json
    expect(response).to have_http_status(401)
    post_with_token '/api/v1/addresses', params.to_json, access_token.token
    expect(response).to have_http_status(403)
    post_with_token '/api/v1/addresses', params.to_json, full_access_token.token
    expect(response).to have_http_status(201)
  end

  it 'deletes address using full token' do
    address           = Fabricate(:address)
    full_access_token = Fabricate(:full_access_token_as_admin)
    access_token      = Fabricate(:simple_access_token)

    delete_without_token "/api/v1/addresses/#{address.id}"
    expect(response).to have_http_status(401)
    delete_with_token "/api/v1/addresses/#{address.id}", access_token.token
    expect(response).to have_http_status(403)
    delete_with_token "/api/v1/addresses/#{address.id}", full_access_token.token
    expect(response).to have_http_status(204)
  end

end
