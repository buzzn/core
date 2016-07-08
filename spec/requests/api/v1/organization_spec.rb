describe "Organizations API" do

  let(:page_overload) { 11 }


  it 'gets an organization with admin token' do
    access_token = Fabricate(:admin_access_token)
    organization = Fabricate(:electricity_supplier)

    get_with_token "/api/v1/organizations/#{organization.id}", access_token.token

    expect(response).to have_http_status(200)
    expect(json['data']['id']).to eq organization.id
  end

  it 'gets an organization as manager' do
    access_token = Fabricate(:access_token)
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


  it 'gets all organizations with admin token' do
    access_token = Fabricate(:admin_access_token)
    organization = Fabricate(:electricity_supplier)
    get_with_token "/api/v1/organizations", access_token.token
    expect(response).to have_http_status(200)
    expect(json['data'].size).to eq Organization.all.size
    expect(json['data'].last['id']).to eq organization.id
  end


  it 'gets all organizations as manager' do
    access_token = Fabricate(:admin_access_token)
    organization = Fabricate(:electricity_supplier)
    manager = User.find(access_token.resource_owner_id)
    manager.add_role(:manager, organization)

    get_with_token "/api/v1/organizations", access_token.token
    expect(response).to have_http_status(200)
    expect(json['data'].size).to eq Organization.all.size
    expect(json['data'].last['id']).to eq organization.id
  end

  
  it 'gets all organizations' do
    organization = Fabricate(:electricity_supplier)

    get_without_token "/api/v1/organizations"

    expect(response).to have_http_status(200)
    expect(json['data'].size).to eq Organization.all.size
    expect(json['data'].last['id']).to eq organization.id
  end


  it 'paginate organizations' do
    page_overload.times do
      Fabricate(:distribution_system_operator)
    end
    access_token = Fabricate(:admin_access_token)
    get_with_token "/api/v1/organizations", access_token.token
    expect(response).to have_http_status(200)
    expect(json['meta']['total_pages']).to eq(2)
  end


  it 'does not create an organization without token' do
    access_token = Fabricate(:access_token)
    organization = Fabricate.build(:metering_service_provider)

    request_params = {}.to_json

    post_without_token "/api/v1/organizations", request_params

    expect(response).to have_http_status(401)
  end


  it 'does not create an organization with user token' do
    access_token = Fabricate(:access_token)
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

    expect(response).to have_http_status(403)
  end


  it 'creates an organization with admin token' do
    access_token = Fabricate(:admin_access_token)
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
    expect(json['data']['id']).not_to eq organization.id
    expect(json['data']['attributes']['name']).to eq organization.name
    expect(json['data']['attributes']['email']).to eq organization.email
    expect(json['data']['attributes']['fax']).to eq organization.fax
    expect(json['data']['attributes']['phone']).to eq organization.phone
    expect(json['data']['attributes']['website']).to eq organization.website
    expect(json['data']['attributes']['mode']).to eq organization.mode
    expect(json['data']['attributes']['description']).to eq organization.description
  end



  it 'does not update an organization without token' do
    organization = Fabricate(:metering_service_provider)

    request_params = {
      id:          organization.id,
      name:        'Google',
      phone:       organization.phone,
      fax:         organization.fax,
      website:     organization.website,
      description: organization.description,
      mode:        organization.mode,
      email:       organization.email
    }.to_json

    put "/api/v1/organizations", request_params

    expect(response).to have_http_status(401)
  end


  it 'does not update an organization with user token' do
    access_token = Fabricate(:access_token)
    organization = Fabricate(:metering_service_provider)

    request_params = {
      id:          organization.id,
      name:        'Google',
      phone:       organization.phone,
      fax:         organization.fax,
      website:     organization.website,
      description: organization.description,
      mode:        organization.mode,
      email:       organization.email
    }.to_json

    put_with_token "/api/v1/organizations", request_params, access_token.token
    expect(response).to have_http_status(403)
  end


  it 'updates an organization with admin token' do
    access_token = Fabricate(:admin_access_token)
    organization = Fabricate(:metering_service_provider)

    request_params = {
      id:          organization.id,
      name:        'Google',
      phone:       organization.phone,
      fax:         organization.fax,
      website:     organization.website,
      description: organization.description,
      mode:        organization.mode,
      email:       organization.email
    }.to_json

    put_with_token "/api/v1/organizations", request_params, access_token.token

    expect(response).to have_http_status(200)
    expect(json['data']['id']).to eq organization.id
    expect(json['data']['attributes']['name']).to eq 'Google'
  end

  it 'does not update an organization as manager' do
    access_token = Fabricate(:access_token)
    organization = Fabricate(:metering_service_provider)
    manager = User.find(access_token.resource_owner_id)
    manager.add_role(:manager, organization)

    request_params = {
      id:          organization.id,
      name:        'Google',
      phone:       organization.phone,
      fax:         organization.fax,
      website:     organization.website,
      description: organization.description,
      mode:        organization.mode,
      email:       organization.email
    }.to_json

    put_with_token "/api/v1/organizations", request_params, access_token.token

    expect(response).to have_http_status(403)
  end

  it 'updates an organization as manager with admin token' do
    organization = Fabricate(:metering_service_provider)
    access_token = Fabricate(:user_with_admin_access_token)

    manager = User.find(access_token.resource_owner_id)
    manager.add_role(:manager, organization)

    request_params = {
      id:          organization.id,
      name:        'Google',
      phone:       organization.phone,
      fax:         organization.fax,
      website:     organization.website,
      description: organization.description,
      mode:        organization.mode,
      email:       organization.email
    }.to_json

    put_with_token "/api/v1/organizations", request_params, access_token.token

    expect(response).to have_http_status(200)
    expect(json['data']['id']).to eq organization.id
    expect(json['data']['attributes']['name']).to eq 'Google'
  end

  
  it 'does not delete an organization without token' do
    organization_id = Fabricate(:metering_service_provider).id

    delete "/api/v1/organizations/#{organization_id}"
   
    expect(response).to have_http_status(401)
  end


  it 'does not delete an organization with user token' do
    access_token = Fabricate(:access_token)
    organization_id = Fabricate(:metering_service_provider).id

    delete_with_token "/api/v1/organizations/#{organization_id}", access_token.token

    expect(response).to have_http_status(403)
  end

  
  it 'deletes an organization with admin token' do
    access_token = Fabricate(:admin_access_token)
    organization_id = Fabricate(:metering_service_provider).id

    delete_with_token "/api/v1/organizations/#{organization_id}", access_token.token

    expect(response).to have_http_status(204)
  end

end
