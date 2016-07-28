describe "Groups API Cache" do

  before do
    @r = Redis.new(Redis::Store::Factory.resolve("redis://localhost:6379/0"))
    @r.flushdb
  end

  let(:metering_point) { Fabricate(:out_metering_point_with_manager) }
  let(:manager) { metering_point.managers.first }
  let(:access_token) { Fabricate(:full_access_token, resource_owner_id: manager.id) }
  let(:token) { access_token.token }
  let(:group) do
    group = Fabricate(:group)
    manager.add_role(:manager, group)
    group
  end

  it 'lifecycle of an group with full access token as admin' do
    new_group = Fabricate.build(:group)

    request_params = {
      name:        new_group.name,
      readable:    new_group.readable,
      description: new_group.description
    }.to_json

    post_with_token "/api/v1/groups", request_params, token
    expect(response).to have_http_status(201)
    id = json['data']['id']

    get_with_token "/api/v1/groups/#{id}", token
    expect(response.headers['X-Rack-Cache']).to eq 'miss, store'

    get_with_token "/api/v1/groups/#{id}", token
    expect(response.headers['X-Rack-Cache']).to eq 'fresh'

    request_params = {
      name:        'Google',
    }.to_json

    put_with_token "/api/v1/groups/#{id}", request_params, token
    expect(response.headers['X-Rack-Cache']).to eq 'invalidate, pass'
    expect(json['data']['attributes']['name']).to eq 'Google'

    get_with_token "/api/v1/groups/#{id}", token
    expect(response.headers['X-Rack-Cache']).to eq 'stale, invalid, store'
    expect(json['data']['attributes']['name']).to eq 'Google'

    get_with_token "/api/v1/groups/#{id}", token
    expect(response.headers['X-Rack-Cache']).to eq 'fresh'
    expect(json['data']['attributes']['name']).to eq 'Google'

    delete_with_token "/api/v1/groups/#{id}", token
    expect(response.headers['X-Rack-Cache']).to eq 'invalidate, pass'

    get_with_token "/api/v1/groups/#{id}", token
    expect(response).to have_http_status(404)
    expect(response.headers['X-Rack-Cache']).to eq 'stale, invalid'
  end

  it 'conditional GET a group' do
    # the header 'Expect: true' will bypass the cache
    get_without_token "/api/v1/groups/#{group.id}", {}, 'Expect': true

    expect(response).to have_http_status(200)

    expect(to_time('Expires')).to be > Time.now
    expect(split('Cache-Control')).to match_array ['public', 'must-revalidate', 'max-age=86400']
    expect(last = response['Last-Modified']).to eq group.updated_at.httpdate
    expect(etag = response['ETag']).not_to be_nil

    get_without_token "/api/v1/groups/#{group.id}", {}, 'If-Modified-Since': last
    expect(response).to have_http_status(304)
    
    get_without_token "/api/v1/groups/#{group.id}", {}, 'If-None-Match': etag
    expect(response).to have_http_status(304)
  end

  it 'conditional GET all groups' do
    group # create it
    get_without_token "/api/v1/groups", {}, 'Expect': true
    expect(response).to have_http_status(200)
    expect(json['data'].size).to eq Group.all.size
    expect(json['data'].last['id']).to eq group.id

    expect(last = response['Last-Modified']).to eq group.updated_at.httpdate
    expect(etag = response['ETag']).not_to be_nil
    expect(to_time('Expires')).to be > Time.now
    expect(split('Cache-Control')).to match_array ['public', 'must-revalidate', 'max-age=86400']

    get_without_token "/api/v1/groups/#{group.id}", {}, 'If-Modified-Since': last
    expect(response).to have_http_status(304)
    
    get_without_token "/api/v1/groups/#{group.id}", {}, 'If-None-Match': etag
    expect(response).to have_http_status(304)
  end

  it 'conditional GET the related managers of a group' do
    get_with_token "/api/v1/groups/#{group.id}/managers", token
    expect(response).to have_http_status(200)

    expect(split('Cache-Control')).to(
      match_array ['private', 'max-age=0', 'no-store', 'no-cache', 'must-revalidate'])
    expect(response['Pragma']).to eq 'no-cache'
    expect(to_time('Expires')).to be < Time.now
    expect(response['Last-Modified']).to be_nil
    expect(response['ETag']).to be_nil
  end
  
  it 'conditional GET the related members of an group' do
    get_with_token "/api/v1/groups/#{group.id}/members", token
    expect(response).to have_http_status(200)

    expect(split('Cache-Control')).to(
      match_array ['private', 'max-age=0', 'no-store', 'no-cache', 'must-revalidate'])
    expect(response['Pragma']).to eq 'no-cache'
    expect(to_time('Expires')).to be < Time.now
    expect(response['Last-Modified']).to be_nil
    expect(response['ETag']).to be_nil
  end
end
