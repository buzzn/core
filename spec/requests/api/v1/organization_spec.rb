describe "Organizations API" do

  let(:page_overload) { 11 }

  # RETRIEVE

  it 'gets an organization with full access token as admin' do
    access_token = Fabricate(:full_access_token_as_admin)
    organization = Fabricate(:electricity_supplier)

    get_with_token "/api/v1/organizations/#{organization.id}", access_token.token

    expect(response).to have_http_status(200)
    expect(json['data']['id']).to eq organization.id
  end


  it 'gets an organization as manager' do
    access_token = Fabricate(:public_access_token)
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


  it 'gets all organizations with full access token as admin' do
    access_token = Fabricate(:full_access_token_as_admin)
    organization = Fabricate(:electricity_supplier)
    get_with_token "/api/v1/organizations", access_token.token
    expect(response).to have_http_status(200)
    expect(json['data'].size).to eq Organization.all.size
    expect(json['data'].last['id']).to eq organization.id
  end


  it 'gets all organizations with full access token as admin' do
    access_token = Fabricate(:full_access_token_as_admin)
    organization = Fabricate(:electricity_supplier)
    manager = User.find(access_token.resource_owner_id)
    manager.add_role(:manager, organization)

    get_with_token "/api/v1/organizations", access_token.token
    expect(response).to have_http_status(200)
    expect(json['data'].size).to eq Organization.all.size
    expect(json['data'].last['id']).to eq organization.id
  end


  it 'search organizations with full access token as admin' do
    organization = Fabricate(:electricity_supplier)
    Fabricate(:distribution_system_operator)
    access_token = Fabricate(:full_access_token_as_admin).token

    request_params = { search: organization.email }
    get_with_token '/api/v1/organizations', request_params, access_token
    expect(response).to have_http_status(200)
    expect(json['data'].size).to eq 1
    expect(json['data'].first['id']).to eq organization.id
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
    access_token = Fabricate(:full_access_token_as_admin)
    get_with_token "/api/v1/organizations", access_token.token
    expect(response).to have_http_status(200)
    expect(json['meta']['total_pages']).to eq(2)
  end


  # CREATE

  it 'does not create an organization without token' do
    request_params = {}.to_json

    post_without_token "/api/v1/organizations", request_params

    expect(response).to have_http_status(401)
  end


  [:public_access_token, :smartmeter_access_token].each do |token|
    it "does not create an organization with #{token}" do
      access_token = Fabricate(token)

      post_with_token "/api/v1/organizations", {}.to_json, access_token.token

      expect(response).to have_http_status(403)
    end
  end

  it 'does not create an organization with full access token' do
    access_token = Fabricate(:full_access_token)
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

  it 'creates an organization with full access token as admin' do
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
    expect(json['data']['id']).not_to eq organization.id
    expect(json['data']['attributes']['name']).to eq organization.name
    expect(json['data']['attributes']['email']).to eq organization.email
    expect(json['data']['attributes']['fax']).to eq organization.fax
    expect(json['data']['attributes']['phone']).to eq organization.phone
    expect(json['data']['attributes']['website']).to eq organization.website
    expect(json['data']['attributes']['mode']).to eq organization.mode
    expect(json['data']['attributes']['description']).to eq organization.description
  end


  #UPDATE

  it 'does not update an organization without token' do
    patch_without_token "/api/v1/organizations/123", {}.to_json
    expect(response).to have_http_status(401)
  end


  [:public_access_token, :smartmeter_access_token].each do |token|
    it "does not update an organization with #{token}" do
      access_token = Fabricate(token)
      patch_with_token "/api/v1/organizations/321", {}.to_json, access_token.token
      expect(response).to have_http_status(403)
    end
  end

  it 'does not update an organization with full access token' do
    organization = Fabricate(:metering_service_provider)
    access_token = Fabricate(:full_access_token)
    patch_with_token "/api/v1/organizations/#{organization.id}", {}.to_json, access_token.token
    expect(response).to have_http_status(403)
  end


  it 'updates an organization with full access token admin' do
    access_token = Fabricate(:full_access_token_as_admin)
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

    patch_with_token "/api/v1/organizations/#{organization.id}", request_params, access_token.token

    expect(response).to have_http_status(200)
    expect(json['data']['id']).to eq organization.id
    expect(json['data']['attributes']['name']).to eq 'Google'
  end


  it 'updates an organization as full access with manager token' do
    organization = Fabricate(:metering_service_provider)
    access_token = Fabricate(:full_access_token)

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

    patch_with_token "/api/v1/organizations/#{organization.id}", request_params, access_token.token

    expect(response).to have_http_status(200)
    expect(json['data']['id']).to eq organization.id
    expect(json['data']['attributes']['name']).to eq 'Google'
  end


  #DELETE


  it 'does not delete an organization without token' do
    organization_id = Fabricate(:metering_service_provider).id

    delete "/api/v1/organizations/#{organization_id}"

    expect(response).to have_http_status(401)
  end


  [:public_access_token,
   :smartmeter_access_token,
   :full_access_token].each do |token|
    it "does not delete an organization with #{token}" do
      access_token = Fabricate(token)
      organization = Fabricate(:metering_service_provider)
      manager = User.find(access_token.resource_owner_id)
      manager.add_role(:manager, organization)

      delete_with_token "/api/v1/organizations/#{organization.id}", access_token.token

      expect(response).to have_http_status(403)
    end
  end

  it 'deletes an organization with manager token as admin' do
    access_token = Fabricate(:full_access_token_as_admin)
    organization_id = Fabricate(:metering_service_provider).id

    delete_with_token "/api/v1/organizations/#{organization_id}", access_token.token

    expect(response).to have_http_status(204)
  end

  # RETRIEVE contracts

  it 'gets the related contracts of an organization without token' do
    organization    = Fabricate(:electricity_supplier_with_contracts)
    contracts       = organization.contracts

    get_without_token "/api/v1/organizations/#{organization.id}/contracts"
    expect(response).to have_http_status(200)
    contracts.each do |contract|
      expect(json['data'].find{ |c| c['id'] == contract.id }['attributes']['mode']).to eq('electricity_supplier_contract')
    end
    expect(json['data'].size).to eq(contracts.size)
  end

  it 'gets the related contracts of an organization with token' do
    access_token    = Fabricate(:public_access_token)
    organization    = Fabricate(:electricity_supplier_with_contracts)
    contracts       = organization.contracts

    get_with_token "/api/v1/organizations/#{organization.id}/contracts", access_token.token
    expect(response).to have_http_status(200)
    contracts.each do |contract|
      expect(json['data'].find{ |c| c['id'] == contract.id }['attributes']['mode']).to eq('electricity_supplier_contract')
    end
    expect(json['data'].size).to eq(contracts.size)
  end

  it 'paginate contracts' do
    access_token    = Fabricate(:public_access_token).token
    organization    = Fabricate(:electricity_supplier)

    page_overload.times do
      organization.contracts << Fabricate(:electricity_supplier_contract)
    end
    get_with_token "/api/v1/organizations/#{organization.id}/contracts", access_token
    expect(response).to have_http_status(200)
    expect(json['meta']['total_pages']).to eq(2)
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

  it 'gets the related address of an organization with token' do
    access_token    = Fabricate(:public_access_token)
    organization    = Fabricate(:transmission_system_operator_with_address)
    address         = organization.address

    get_with_token "/api/v1/organizations/#{organization.id}/address", access_token.token

    expect(response).to have_http_status(200)
    expect(json['data']['id']).to eq(address.id)
    expect(json['data']['attributes']['time-zone']).to eq('Berlin')
  end


  # RETRIEVE contracting_party

  it 'gets the related contracting_party of an organization without token' do
    organization      = Fabricate(:metering_service_provider_with_contracting_party)
    contracting_party = organization.contracting_party

    get_without_token "/api/v1/organizations/#{organization.id}/contracting_party"

    expect(response).to have_http_status(200)
    expect(json['data']['id']).to eq(contracting_party.id)
    expect(json['data']['attributes']['legal-entity']).to eq('natural_person')
  end

  it 'gets the related contracting_party of an organization with token' do
    access_token    = Fabricate(:public_access_token)
    organization    = Fabricate(:metering_service_provider_with_contracting_party)
    party           = organization.contracting_party

    get_with_token "/api/v1/organizations/#{organization.id}/contracting_party", access_token.token

    expect(response).to have_http_status(200)
    expect(json['data']['id']).to eq(party.id)
    expect(json['data']['attributes']['legal-entity']).to eq('natural_person')
  end


  # RETRIEVE manager

  it 'gets the related managers of an organization only with token' do
    access_token  = Fabricate(:public_access_token)
    organization  = Fabricate(:distribution_system_operator)

    get_with_token "/api/v1/organizations/#{organization.id}/managers", access_token.token
    expect(response).to have_http_status(200)
    get_without_token "/api/v1/organizations/#{organization.id}/managers"
    expect(response).to have_http_status(200)
  end

  it 'paginate managers of an organziation' do
    access_token  = Fabricate(:public_access_token)
    organization  = Fabricate(:distribution_system_operator)
    page_overload.times do
      user = Fabricate(:user)
      user.add_role(:manager, organization)
    end
    get_with_token "/api/v1/organizations/#{organization.id}/managers", access_token.token
    expect(response).to have_http_status(200)
    expect(json['meta']['total_pages']).to eq(2)
  end

  it 'gets the related members for Organization' do
    access_token  = Fabricate(:public_access_token)
    organization  = Fabricate(:distribution_system_operator)

    get_with_token "/api/v1/organizations/#{organization.id}/members", access_token.token
    expect(response).to have_http_status(200)
    get_without_token "/api/v1/organizations/#{organization.id}/members"
    expect(response).to have_http_status(200)
  end

  it 'paginate members of an organziation' do
    access_token  = Fabricate(:public_access_token)
    organization  = Fabricate(:distribution_system_operator)
    page_overload.times do
      user = Fabricate(:user)
      user.add_role(:member, organization)
    end
    get_with_token "/api/v1/organizations/#{organization.id}/members", access_token.token
    expect(response).to have_http_status(200)
    expect(json['meta']['total_pages']).to eq(2)
  end

  # CREATE manager/member

  it 'does not add organization manager/member without token' do
    organization  = Fabricate(:distribution_system_operator)

    post_without_token "/api/v1/organizations/#{organization.id}/managers", {}.to_json
    expect(response).to have_http_status(401)

    post_without_token "/api/v1/organizations/#{organization.id}/members", {}.to_json
    expect(response).to have_http_status(401)
  end


  [:public_access_token, :smartmeter_access_token].each do |token|
    [:member, :manager, :admin].each do |role|
      it "does not add organization manager/member as member with #{token} as #{role}" do
        organization    = Fabricate(:distribution_system_operator)
        member_token    = Fabricate(token)
        member          = User.find(member_token.resource_owner_id)
        member.add_role(role, organization)

        post_with_token "/api/v1/organizations/#{organization.id}/managers", {}.to_json, member_token.token
        expect(response).to have_http_status(403)

        post_with_token "/api/v1/organizations/#{organization.id}/members", {}.to_json, member_token.token
        expect(response).to have_http_status(403)
        end
    end
  end


  it 'adds organization manager/member with full access token as manager' do
    organization     = Fabricate(:distribution_system_operator)
    manager_token = Fabricate(:full_access_token)
    manager = User.find(manager_token.resource_owner_id)
    manager.add_role(:manager, organization)

    user = Fabricate(:user)
    user_params = {
      user_id: user.id
    }.to_json

    post_with_token "/api/v1/organizations/#{organization.id}/managers", user_params, manager_token.token
    expect(response).to have_http_status(201)

    post_with_token "/api/v1/organizations/#{organization.id}/members", user_params, manager_token.token
    expect(response).to have_http_status(201)

    expect(organization.managers).to match_array [manager, user]
    expect(organization.members).to eq [user]
  end


  it 'adds organization manager/member with full access token as admin' do
    organization     = Fabricate(:distribution_system_operator)
    manager_token = Fabricate(:full_access_token_as_admin)

    user = Fabricate(:user)
    user_params = {
      user_id: user.id
    }.to_json

    post_with_token "/api/v1/organizations/#{organization.id}/managers", user_params, manager_token.token
    expect(response).to have_http_status(201)

    post_with_token "/api/v1/organizations/#{organization.id}/members", user_params, manager_token.token
    expect(response).to have_http_status(201)

    expect(organization.managers).to eq [user]
    expect(organization.members).to eq [user]
  end


  # REMOVE manager/member

  it 'does not delete organization manager/member without token' do
    organization  = Fabricate(:distribution_system_operator)

    delete_without_token "/api/v1/organizations/#{organization.id}/managers/123"
    expect(response).to have_http_status(401)

    delete_without_token "/api/v1/organizations/#{organization.id}/members/123"
    expect(response).to have_http_status(401)
  end
 

  [:public_access_token, :smartmeter_access_token].each do |token|
    [:member, :manager, :admin].each do |role|
      it "does not delete organization manager/member as #{role} with #{token}" do
        organization    = Fabricate(:distribution_system_operator)
        member_token    = Fabricate(token)
        member          = User.find(member_token.resource_owner_id)
        member.add_role(role, organization)

        delete_with_token "/api/v1/organizations/#{organization.id}/managers/123", member_token.token
        expect(response).to have_http_status(403)

        delete_with_token "/api/v1/organizations/#{organization.id}/members/123", member_token.token
        expect(response).to have_http_status(403)
      end
    end
  end



  it 'deletes organization manager/member as manager with full access token' do
    organization     = Fabricate(:distribution_system_operator)
    manager_token = Fabricate(:full_access_token)
    manager = User.find(manager_token.resource_owner_id)
    manager.add_role(:manager, organization)

    user = Fabricate(:user)
    user.add_role(:manager, organization)
    user.add_role(:member, organization)

    delete_with_token "/api/v1/organizations/#{organization.id}/managers/#{user.id}", manager_token.token
    expect(response).to have_http_status(204)

    delete_with_token "/api/v1/organizations/#{organization.id}/members/#{user.id}", manager_token.token
    expect(response).to have_http_status(204)

    expect(organization.managers).to eq [manager]
    expect(organization.members).to eq []
  end


  it 'deletes organization manager/member with full access token as admin' do
    organization     = Fabricate(:distribution_system_operator)
    manager_token = Fabricate(:full_access_token_as_admin)

    user = Fabricate(:user)
    user.add_role(:manager, organization)
    user.add_role(:member, organization)

    delete_with_token "/api/v1/organizations/#{organization.id}/managers/#{user.id}", manager_token.token
    expect(response).to have_http_status(204)

    delete_with_token "/api/v1/organizations/#{organization.id}/members/#{user.id}", manager_token.token
    expect(response).to have_http_status(204)

    expect(organization.managers).to eq []
    expect(organization.members).to eq []
  end
end
