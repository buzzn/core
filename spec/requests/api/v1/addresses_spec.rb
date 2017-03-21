# coding: utf-8
describe 'Addresses API' do

  let(:page_overload) { 11 }
  let(:params) do
    {
      street_name: 'Lützowplatz',
      street_number: '17',
      city: 'Berlin',
      state: Address.states.first.to_s,
      zip: 10785,
      country: 'Germany',
      addition: 'HH'
    }
  end

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
    expect(json['meta']['deletable']).to be_truthy
  end

  it 'creates address using full token' do
    full_access_token = Fabricate(:full_access_token_as_admin)
    access_token      = Fabricate(:simple_access_token)

    post_without_token '/api/v1/addresses', params.to_json
    expect(response).to have_http_status(401)
    post_with_token '/api/v1/addresses', params.to_json, access_token.token
    expect(response).to have_http_status(403)
    post_with_token '/api/v1/addresses', params.to_json, full_access_token.token
    expect(response).to have_http_status(201)
    params.each do |k,v|
      expect(json['data']['attributes'][k]).not_to eq(v)
    end
  end

  it 'updates address using full token' do
    address           = Fabricate(:address)
    full_access_token = Fabricate(:full_access_token_as_admin)
    access_token      = Fabricate(:simple_access_token)

    patch_without_token "/api/v1/addresses/#{address.id}", {}.to_json
    expect(response).to have_http_status(401)
    patch_with_token "/api/v1/addresses/#{address.id}", {}.to_json, access_token.token
    expect(response).to have_http_status(403)

    params.each do |k,v|
      request_params = { "#{k}": v }

      patch_with_token "/api/v1/addresses/#{address.id}", request_params.to_json, full_access_token.token
      expect(response).to have_http_status(200)
      expect(json['data']['attributes'][k.to_s.gsub('_','-')]).to eq(v)
    end
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
