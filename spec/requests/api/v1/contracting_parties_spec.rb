describe 'Contracting parties API' do

  let(:page_overload) { 11 }


  it 'does not get all contracting parties with regular token or without token' do
    Fabricate(:contracting_party)
    access_token = Fabricate(:simple_access_token)

    get_with_token '/api/v1/contracting-parties', {}, access_token.token
    expect(response).to have_http_status(403)
    get_without_token '/api/v1/contracting-parties'
    expect(response).to have_http_status(401)
  end

  it 'get all contractig parties with full access token' do
    contracting_party = Fabricate(:contracting_party)
    access_token      = Fabricate(:full_access_token_as_admin)

    get_with_token '/api/v1/contracting-parties', {}, access_token.token
    expect(response).to have_http_status(200)
    expect(json['data'].size).to eq(ContractingParty.count)
  end


  it 'paginate contracting parties with full access token' do
    page_overload.times do
      Fabricate(:contracting_party)
    end
    access_token = Fabricate(:full_access_token_as_admin)

    get_with_token '/api/v1/contracting-parties', {}, access_token.token
    expect(response).to have_http_status(200)
    expect(json['meta']['total_pages']).to eq(2)
    get_with_token '/api/v1/contracting-parties', {per_page: 200}, access_token.token
    expect(response).to have_http_status(422)
  end

  it 'get contractig party only with full access token' do
    contracting_party = Fabricate(:contracting_party)
    full_access_token = Fabricate(:full_access_token_as_admin)
    access_token      = Fabricate(:simple_access_token)

    get_without_token "/api/v1/contracting-parties/#{contracting_party.id}"
    expect(response).to have_http_status(401)

    get_with_token "/api/v1/contracting-parties/#{contracting_party.id}", {}, access_token.token
    expect(response).to have_http_status(403)

    get_with_token "/api/v1/contracting-parties/#{contracting_party.id}", {}, full_access_token.token
    expect(response).to have_http_status(200)
    expect(json['meta']['deletable']).to be_truthy
  end

  it 'creates contracting party using full token' do
    full_access_token = Fabricate(:full_access_token_as_admin)
    organization      = Fabricate(:organization, mode: :other)
    access_token      = Fabricate(:simple_access_token)
    params = {
      legal_entity:    'company',
      organization_id: organization.id
    }

    post_without_token '/api/v1/contracting-parties', params.to_json
    expect(response).to have_http_status(401)
    post_with_token '/api/v1/contracting-parties', params.to_json, access_token.token
    expect(response).to have_http_status(403)
    post_with_token '/api/v1/contracting-parties', params.to_json, full_access_token.token
    expect(response).to have_http_status(201)
  end

  it 'updates contracting party using full token' do
    contracting_party = Fabricate(:contracting_party)
    full_access_token = Fabricate(:full_access_token_as_admin)
    access_token      = Fabricate(:simple_access_token)
    params = {
      legal_entity: 'natural_person',
    }

    patch_without_token "/api/v1/contracting-parties/#{contracting_party.id}", params.to_json
    expect(response).to have_http_status(401)
    patch_with_token "/api/v1/contracting-parties/#{contracting_party.id}", params.to_json, access_token.token
    expect(response).to have_http_status(403)
    patch_with_token "/api/v1/contracting-parties/#{contracting_party.id}", params.to_json, full_access_token.token
    expect(response).to have_http_status(200)
  end

  it 'deletes contracting party using full token' do
    contracting_party = Fabricate(:contracting_party)
    full_access_token = Fabricate(:full_access_token_as_admin)
    access_token      = Fabricate(:simple_access_token)

    delete_without_token "/api/v1/contracting-parties/#{contracting_party.id}"
    expect(response).to have_http_status(401)
    delete_with_token "/api/v1/contracting-parties/#{contracting_party.id}", access_token.token
    expect(response).to have_http_status(403)
    delete_with_token "/api/v1/contracting-parties/#{contracting_party.id}", full_access_token.token
    expect(response).to have_http_status(204)
  end

end
