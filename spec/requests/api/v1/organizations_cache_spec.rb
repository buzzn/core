describe "Organizations API Cache" do

  before do
    @r = Redis.new(Redis::Store::Factory.resolve("redis://localhost:6379/0"))
    @r.flushdb
  end
  
  it 'lifecycle of an organization with full access token as admin' do
    access_token = Fabricate(:full_access_token_as_admin)
    organization = Fabricate.build(:metering_service_provider)

    request_params = {
      name:        organization.name,
      phone:       organization.phone,
      fax:         organization.fax,
      website:     organization.website,
      description: organization.description,
      mode:        organization.mode,
      email:       organization.email
    }.to_json

    post_with_token "/api/v1/organizations", request_params, access_token.token
    expect(response).to have_http_status(201)
    id = json['data']['id']

    get_with_token "/api/v1/organizations/#{id}", access_token.token
    expect(response.headers['X-Rack-Cache']).to eq 'miss, store'

    get_with_token "/api/v1/organizations/#{id}", access_token.token
    expect(response.headers['X-Rack-Cache']).to eq 'fresh'

    request_params = {
      name:        'Google',
    }.to_json

    put_with_token "/api/v1/organizations/#{id}", request_params, access_token.token
    expect(response.headers['X-Rack-Cache']).to eq 'invalidate, pass'
    expect(json['data']['attributes']['name']).to eq 'Google'

    get_with_token "/api/v1/organizations/#{id}", access_token.token
    expect(response.headers['X-Rack-Cache']).to eq 'stale, invalid, store'
    expect(json['data']['attributes']['name']).to eq 'Google'

    get_with_token "/api/v1/organizations/#{id}", access_token.token
    expect(response.headers['X-Rack-Cache']).to eq 'fresh'
    expect(json['data']['attributes']['name']).to eq 'Google'

    delete_with_token "/api/v1/organizations/#{id}", access_token.token
    expect(response.headers['X-Rack-Cache']).to eq 'invalidate, pass'

    get_with_token "/api/v1/organizations/#{id}", access_token.token
    expect(response).to have_http_status(404)
    expect(response.headers['X-Rack-Cache']).to eq 'stale, invalid'
  end

  it 'conditional GET an organization' do
    organization = Fabricate(:electricity_supplier)

    # the header 'Expect: true' will bypass the cache
    get_without_token "/api/v1/organizations/#{organization.id}", {}, 'Expect': true

    expect(response).to have_http_status(200)

    expect(to_time('Expires')).to be > Time.now
    expect(split('Cache-Control')).to match_array ['public', 'must-revalidate', 'max-age=86400']
    expect(last = response['Last-Modified']).to eq organization.updated_at.httpdate
    expect(etag = response['ETag']).not_to be_nil

    get_without_token "/api/v1/organizations/#{organization.id}", {}, 'If-Modified-Since': last
    expect(response).to have_http_status(304)
    
    get_without_token "/api/v1/organizations/#{organization.id}", {}, 'If-None-Match': etag
    expect(response).to have_http_status(304)
  end

  it 'conditional GET all organizations' do
    organization = Fabricate(:electricity_supplier)

    get_without_token "/api/v1/organizations", {}, 'Expect': true

    expect(response).to have_http_status(200)
    expect(json['data'].size).to eq Organization.all.size
    expect(json['data'].last['id']).to eq organization.id

    expect(last = response['Last-Modified']).to eq organization.updated_at.httpdate
    expect(etag = response['ETag']).not_to be_nil
    expect(to_time('Expires')).to be > Time.now
    expect(split('Cache-Control')).to match_array ['public', 'must-revalidate', 'max-age=86400']

    get_without_token "/api/v1/organizations/#{organization.id}", {}, 'If-Modified-Since': last
    expect(response).to have_http_status(304)
    
    get_without_token "/api/v1/organizations/#{organization.id}", {}, 'If-None-Match': etag
    expect(response).to have_http_status(304)
  end

  it 'conditional GET the related contracts of an organization' do

    organization    = Fabricate(:electricity_supplier_with_contracts)
    contracts       = organization.contracts

    get_without_token "/api/v1/organizations/#{organization.id}/contracts"
    expect(response).to have_http_status(200)
    expect(json['data'].size).to eq(contracts.size)

    expect(split('Cache-Control')).to(
      match_array ['private', 'max-age=0', 'no-store', 'no-cache', 'must-revalidate'])
    expect(response['Pragma']).to eq 'no-cache'
    expect(to_time('Expires')).to be < Time.now
    expect(response['Last-Modified']).to be_nil
    expect(response['ETag']).to be_nil
  end

  it 'conditional GET the related address of an organization' do
    organization  = Fabricate(:transmission_system_operator_with_address)
    address       = organization.address

    get_without_token "/api/v1/organizations/#{organization.id}/address"

    expect(response).to have_http_status(200)
    expect(json['data']['id']).to eq(address.id)
    
    expect(split('Cache-Control')).to match_array ['max-age=86400', 'must-revalidate', 'public']
    expect(response['Pragma']).to be_nil
    expect(to_time('Expires')).to be > Time.now
    expect(last = response['Last-Modified']).to eq organization.updated_at.httpdate
    expect(etag = response['ETag']).not_to be_nil

    get_without_token "/api/v1/organizations/#{organization.id}/address", {}, 'If-Modified-Since': last
    expect(response).to have_http_status(304)
    
    get_without_token "/api/v1/organizations/#{organization.id}/address", {}, 'If-None-Match': etag
    expect(response).to have_http_status(304)
  end

  it 'conditional GET the related contracting_party of an organization' do
    organization      = Fabricate(:metering_service_provider_with_contracting_party)
    contracting_party = organization.contracting_party

    get_without_token "/api/v1/organizations/#{organization.id}/contracting_party"

    expect(response).to have_http_status(200)
    expect(json['data']['id']).to eq(contracting_party.id)

    expect(split('Cache-Control')).to match_array ['max-age=86400', 'must-revalidate', 'public']
    expect(to_time('Expires')).to be > Time.now
    expect(last = response['Last-Modified']).to eq organization.updated_at.httpdate
    expect(etag = response['ETag']).not_to be_nil

    get_without_token "/api/v1/organizations/#{organization.id}/contracting_party", {}, 'If-Modified-Since': last
    expect(response).to have_http_status(304)
    
    get_without_token "/api/v1/organizations/#{organization.id}/contracting_party", {}, 'If-None-Match': etag
    expect(response).to have_http_status(304)
  end

  it 'conditional GET the related managers of an organization' do
    organization  = Fabricate(:distribution_system_operator)

    get_without_token "/api/v1/organizations/#{organization.id}/managers"
    expect(response).to have_http_status(200)

    expect(split('Cache-Control')).to(
      match_array ['private', 'max-age=0', 'no-store', 'no-cache', 'must-revalidate'])
    expect(response['Pragma']).to eq 'no-cache'
    expect(to_time('Expires')).to be < Time.now
    expect(response['Last-Modified']).to be_nil
    expect(response['ETag']).to be_nil
  end
  
  it 'conditional GET the related members of an organization' do
    organization  = Fabricate(:distribution_system_operator)

    get_without_token "/api/v1/organizations/#{organization.id}/members"
    expect(response).to have_http_status(200)

    expect(split('Cache-Control')).to(
      match_array ['private', 'max-age=0', 'no-store', 'no-cache', 'must-revalidate'])
    expect(response['Pragma']).to eq 'no-cache'
    expect(to_time('Expires')).to be < Time.now
    expect(response['Last-Modified']).to be_nil
    expect(response['ETag']).to be_nil
  end
end
