describe "Organizations API" do

  # RETRIEVE

  it 'gets an organization with full access token as admin' do
    access_token = Fabricate(:full_access_token_as_admin)
    organization = Fabricate(:electricity_supplier)

    get_with_token "/api/v1/organizations/#{organization.id}", access_token.token

    expect(response).to have_http_status(200)
    expect(json['data']['id']).to eq organization.id
  end


  it 'gets an organization as manager' do
    access_token = Fabricate(:simple_access_token)
    organization = Fabricate(:electricity_supplier)
    manager = User.find(access_token.resource_owner_id)
    manager.add_role(:manager, organization)

    get_with_token "/api/v1/organizations/#{organization.id}", access_token.token

    expect(response).to have_http_status(200)
    expect(json['data']['id']).to eq organization.id
  end


  it 'gets an organization' do
    organization = Fabricate(:electricity_supplier)
    get_without_token "/api/v1/organizations/#{organization.id}"
    expect(response).to have_http_status(200)
    expect(json['data']['id']).to eq organization.id
  end

  # RETRIEVE bank_account

  it 'gets not the related bank_account of an organization without token' do
    organization       = Fabricate(:metering_service_provider)
    bank_account       = organization.bank_account

    get_without_token "/api/v1/organizations/#{organization.id}/bank-account"
    expect(response).to have_http_status(401)
  end

  it 'gets not the related bank_account of an organization with token' do
    organization       = Fabricate(:metering_service_provider)
    access_token       = Fabricate(:full_access_token)
    organization.bank_account.delete

    get_with_token "/api/v1/organizations/#{organization.id}/bank-account", access_token.token
    expect(response).to have_http_status(404)
  end

  it 'gets the related bank_account of an organization with token' do
    organization    = Fabricate(:metering_service_provider)
    manager_access_token = Fabricate(:full_access_token)
    manager_user         = User.find(manager_access_token.resource_owner_id)
    manager_user.add_role(:manager, organization)

    get_with_token "/api/v1/organizations/#{organization.id}/bank-account", manager_access_token.token
    expect(response).to have_http_status(200)
    expect(json['data']['id']).to eq(organization.bank_account.id)
  end


  # RETRIEVE address

  it 'gets the related address of an organization without token' do
    organization    = Fabricate(:transmission_system_operator_with_address)
    address       = organization.address

    get_without_token "/api/v1/organizations/#{organization.id}/address"

    expect(response).to have_http_status(200)
    expect(json['data']['id']).to eq(address.id)
    expect(json['data']['attributes']['time-zone']).to eq('Berlin')
  end

  it 'gets not the related address of an organization with token' do
    organization       = Fabricate(:metering_service_provider)
    access_token       = Fabricate(:full_access_token)

    get_with_token "/api/v1/organizations/#{organization.id}/address", access_token.token
    expect(response).to have_http_status(404)
  end

  it 'gets the related address of an organization with token' do
    access_token    = Fabricate(:simple_access_token)
    organization    = Fabricate(:transmission_system_operator_with_address)
    address         = organization.address

    get_with_token "/api/v1/organizations/#{organization.id}/address", access_token.token

    expect(response).to have_http_status(200)
    expect(json['data']['id']).to eq(address.id)
    expect(json['data']['attributes']['time-zone']).to eq('Berlin')
  end

end
