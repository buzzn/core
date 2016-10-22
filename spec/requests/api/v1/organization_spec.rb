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


  it 'gets all organizations with full access token as admin' do
    access_token = Fabricate(:full_access_token_as_admin)
    organization = Fabricate(:electricity_supplier)
    get_with_token "/api/v1/organizations", access_token.token
    expect(response).to have_http_status(200)
    expect(json['data'].size).to eq Organization.all.size
    expect(json['data'].detect{ |item| item['id'] == organization.id }).not_to be_nil
  end


  it 'gets all organizations with full access token as manager' do
    access_token = Fabricate(:full_access_token_as_admin)
    organization = Fabricate(:electricity_supplier)
    manager = User.find(access_token.resource_owner_id)
    manager.add_role(:manager, organization)

    get_with_token "/api/v1/organizations", access_token.token
    expect(response).to have_http_status(200)
    expect(json['data'].size).to eq Organization.all.size
    expect(json['data'].detect{ |item| item['id'] == organization.id }).not_to be_nil
  end


  it 'search organizations with full access token as admin' do
    organization = Fabricate(:electricity_supplier)
    Fabricate(:distribution_system_operator)
    access_token = Fabricate(:full_access_token_as_admin).token

    request_params = { filter: organization.email }
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
  end


  it 'paginates organizations' do
    page_overload.times do
      Fabricate(:distribution_system_operator)
    end
    access_token = Fabricate(:full_access_token_as_admin)
    get_with_token "/api/v1/organizations", access_token.token
    expect(response).to have_http_status(200)
    expect(json['meta']['total_pages']).to eq(2)

    get_with_token "/api/v1/organizations", {per_page: 200}, access_token.token
    expect(response).to have_http_status(422)
  end


  # CREATE

  it 'does not create an organization without token' do
    request_params = {}.to_json

    post_without_token "/api/v1/organizations", request_params

    expect(response).to have_http_status(401)
  end


  [:simple_access_token, :smartmeter_access_token].each do |token|
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

  it 'does not create an organization with missing parameters' do
    access_token = Fabricate(:full_access_token_as_admin)
    organization = Fabricate.build(:metering_service_provider)

    request_params = {
      name:        organization.name,
      phone:       organization.phone,
      mode:        organization.mode,
      email:       organization.email
    }

    request_params.keys.each do |name|
      params = request_params.reject {|k,v| k == name }
      post_with_token "/api/v1/organizations", params.to_json, access_token.token

      expect(response).to have_http_status(422)
      json['errors'].each do |error|
        expect(error['source']['pointer']).to eq "/data/attributes/#{name}"
        expect(error['title']).to eq 'Invalid Attribute'
        expect(error['detail']).to eq "#{name} is missing"
      end
    end
  end


  it 'does not create an organization with invalid parameters' do
    access_token = Fabricate(:full_access_token_as_admin)
    organization = Fabricate.build(:metering_service_provider)

    request_params = {
      name:        organization.name,
      phone:       organization.phone,
      mode:        organization.mode,
      email:       organization.email
    }

    request_params.keys.each do |name|
      next if name == :phone
      params = request_params.dup
      params[name] = 'a' * 2000
      post_with_token "/api/v1/organizations", params.to_json, access_token.token

      expect(response).to have_http_status(422)

      json['errors'].each do |error|
        expect(error['source']['pointer']).to eq "/data/attributes/#{name}"
        expect(error['title']).to eq 'Invalid Attribute'
        expect(error['detail']).to match /#{name}/
      end
    end
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
    expect(response.headers['Location']).to eq json['data']['id']

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


  [:simple_access_token, :smartmeter_access_token].each do |token|
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


  it 'does not update an organization with invalid parameters' do
    access_token = Fabricate(:full_access_token_as_admin)
    organization = Fabricate(:metering_service_provider)

    [:name, :mode, :email].each do |name|
      params = { "#{name}": 'a' * 2000 }

      patch_with_token "/api/v1/organizations/#{organization.id}", params.to_json, access_token.token

      expect(response).to have_http_status(422)

      json['errors'].each do |error|
        expect(error['source']['pointer']).to eq "/data/attributes/#{name}"
        expect(error['title']).to eq 'Invalid Attribute'
        expect(error['detail']).to match /#{name}/
      end
    end
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


  [:simple_access_token,
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
    organization    = Fabricate(:power_giver_with_contracts)
    contracts       = organization.contracts

    get_without_token "/api/v1/organizations/#{organization.id}/contracts"
    expect(response).to have_http_status(200)
    expect(json['data'].size).to eq(0)
  end

  it 'gets the related contracts of an organization with token' do
    access_token    = Fabricate(:full_access_token_as_admin)
    organization    = Fabricate(:power_giver_with_contracts)
    contracts       = organization.contracts

    get_with_token "/api/v1/organizations/#{organization.id}/contracts", access_token.token
    expect(response).to have_http_status(200)
    contracts.each do |contract|
      expect(json['data'].find{ |c| c['id'] == contract.id }['attributes']['mode']).to eq('power_giver_contract')
    end
    expect(json['data'].size).to eq(contracts.size)
  end

  it 'paginates contracts' do
    access_token    = Fabricate(:full_access_token_as_admin).token
    organization    = Fabricate(:power_giver)

    page_overload.times do
      organization.contracts << Fabricate(:power_giver_contract)
    end
    get_with_token "/api/v1/organizations/#{organization.id}/contracts", access_token
    expect(response).to have_http_status(200)
    expect(json['meta']['total_pages']).to eq(2)

    get_with_token "/api/v1/organizations/#{organization.id}/contracts", {per_page: 200}, access_token
    expect(response).to have_http_status(422)
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
    access_token    = Fabricate(:simple_access_token)
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
    expect(json['data']['attributes']['legal-entity']).to eq('company')

    # no contracting_party
    organization    = Fabricate(:metering_point_operator)

    get_without_token "/api/v1/organizations/#{organization.id}/contracting_party"

    expect(response).to have_http_status(200)
    expect(json['data']).to eq({})
  end

  it 'gets the related contracting_party of an organization with token' do
    access_token    = Fabricate(:simple_access_token)
    organization    = Fabricate(:metering_service_provider_with_contracting_party)
    party           = organization.contracting_party

    get_with_token "/api/v1/organizations/#{organization.id}/contracting_party", access_token.token

    expect(response).to have_http_status(200)
    expect(json['data']['id']).to eq(party.id)
    expect(json['data']['attributes']['legal-entity']).to eq('company')

    # no contracting_party
    organization    = Fabricate(:metering_point_operator)

    get_with_token "/api/v1/organizations/#{organization.id}/contracting_party", access_token.token

    expect(response).to have_http_status(200)
    expect(json['data']).to eq({})
  end


  # RETRIEVE manager

  it 'gets the related managers of an organization only with token' do
    access_token  = Fabricate(:simple_access_token)
    organization  = Fabricate(:distribution_system_operator)

    get_with_token "/api/v1/organizations/#{organization.id}/managers", access_token.token
    expect(response).to have_http_status(200)
    get_without_token "/api/v1/organizations/#{organization.id}/managers"
    expect(response).to have_http_status(200)
    get_without_token "/api/v1/organizations/#{organization.id}/relationships/managers"
    expect(response).to have_http_status(200)
  end

  it 'paginates managers of an organziation' do
    access_token  = Fabricate(:full_access_token_as_admin)
    organization  = Fabricate(:distribution_system_operator)
    page_overload.times do
      user = Fabricate(:user)
      user.add_role(:manager, organization)
    end

    get_with_token "/api/v1/organizations/#{organization.id}/managers", access_token.token
    expect(response).to have_http_status(200)
    expect(json['meta']['total_pages']).to eq(2)

    User.all.each {|u| u.profile.update! readable: 'world'}
    access_token  = Fabricate(:simple_access_token)
    get_with_token "/api/v1/organizations/#{organization.id}/managers", access_token.token
    expect(response).to have_http_status(200)
    expect(json['meta']['total_pages']).to eq(2)

    get_with_token "/api/v1/organizations/#{organization.id}/managers", {per_page: 200}, access_token.token
    expect(response).to have_http_status(422)
  end

  it 'gets the related members for Organization' do
    access_token  = Fabricate(:simple_access_token)
    organization  = Fabricate(:distribution_system_operator)

    get_with_token "/api/v1/organizations/#{organization.id}/members", access_token.token
    expect(response).to have_http_status(200)
    get_without_token "/api/v1/organizations/#{organization.id}/members"
    expect(response).to have_http_status(200)
    get_without_token "/api/v1/organizations/#{organization.id}/relationships/members"
    expect(response).to have_http_status(200)
  end

  it 'paginates members of an organziation' do
    access_token  = Fabricate(:full_access_token_as_admin)
    organization  = Fabricate(:distribution_system_operator)
    page_overload.times do
      user = Fabricate(:user)
      user.add_role(:member, organization)
    end

    get_with_token "/api/v1/organizations/#{organization.id}/members", access_token.token
    expect(response).to have_http_status(200)
    expect(json['meta']['total_pages']).to eq(2)

    User.all.each {|u| u.profile.update! readable: 'world'}
    access_token  = Fabricate(:simple_access_token)
    get_with_token "/api/v1/organizations/#{organization.id}/members", {per_page: 200}, access_token.token
    expect(response).to have_http_status(422)
  end

  # CREATE manager/member

  it 'does not add organization manager/member without token' do
    organization  = Fabricate(:distribution_system_operator)

    post_without_token "/api/v1/organizations/#{organization.id}/relationships/managers", {}.to_json
    expect(response).to have_http_status(401)

    post_without_token "/api/v1/organizations/#{organization.id}/relationships/members", {}.to_json
    expect(response).to have_http_status(401)
  end


  [:simple_access_token, :smartmeter_access_token].each do |token|
    [:member, :manager, :admin].each do |role|
      it "does not add organization manager/member as member with #{token} as #{role}" do
        organization    = Fabricate(:distribution_system_operator)
        member_token    = Fabricate(token)
        member          = User.find(member_token.resource_owner_id)
        member.add_role(role, organization)

        post_with_token "/api/v1/organizations/#{organization.id}/relationships/managers", {}.to_json, member_token.token
        expect(response).to have_http_status(403)

        post_with_token "/api/v1/organizations/#{organization.id}/relationships/members", {}.to_json, member_token.token
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
      data: {id: user.id}
    }.to_json

    post_with_token "/api/v1/organizations/#{organization.id}/relationships/managers", user_params, manager_token.token
    expect(response).to have_http_status(204)

    post_with_token "/api/v1/organizations/#{organization.id}/relationships/members", user_params, manager_token.token
    expect(response).to have_http_status(204)

    expect(organization.managers).to match_array [manager, user]
    expect(organization.members).to eq [user]
  end


  it 'adds organization manager/member with full access token as admin' do
    organization     = Fabricate(:distribution_system_operator)
    manager_token = Fabricate(:full_access_token_as_admin)

    user = Fabricate(:user)
    user_params = {
      data: {id: user.id}
    }.to_json

    post_with_token "/api/v1/organizations/#{organization.id}/relationships/managers", user_params, manager_token.token
    expect(response).to have_http_status(204)

    post_with_token "/api/v1/organizations/#{organization.id}/relationships/members", user_params, manager_token.token
    expect(response).to have_http_status(204)

    expect(organization.managers).to eq [user]
    expect(organization.members).to eq [user]
  end


  # REPLACE manager/member


  it 'replaces organization managers/members' do
    admin_token   = Fabricate(:full_access_token_as_admin)
    organization  = Fabricate(:distribution_system_operator)
    simple_token  = Fabricate(:simple_access_token)
    manager_token = Fabricate(:full_access_token)
    manager = User.find(manager_token.resource_owner_id)
    manager.add_role(:manager, organization)

    [user1 = Fabricate(:user), user2 = Fabricate(:user)].each do |u|
      u.add_role(:manager, organization)
      u.add_role(:member, organization)
    end

    user = Fabricate(:user)
    params = {
      data: [{ id: user.id }]
    }

    patch_with_token "/api/v1/organizations/#{organization.id}/relationships/managers", params.to_json, simple_token.token
    expect(response).to have_http_status(403)
    patch_with_token "/api/v1/organizations/#{organization.id}/relationships/members", params.to_json, simple_token.token
    expect(response).to have_http_status(403)
    patch_with_token "/api/v1//organizations/#{organization.id}/relationships/members", params.to_json, manager_token.token
    expect(response).to have_http_status(200)
    patch_with_token "/api/v1//organizations/#{organization.id}/relationships/managers", params.to_json, manager_token.token
    expect(response).to have_http_status(200)

    get_with_token "/api/v1//organizations/#{organization.id}/relationships/managers", params.to_json, admin_token.token
    expect(json['data'].size).to eq 1
    expect(json['data'].first['id']).to eq user.id
    get_with_token "/api/v1//organizations/#{organization.id}/relationships/members", params.to_json, admin_token.token
    expect(json['data'].size).to eq 1
    expect(json['data'].first['id']).to eq user.id

    # manager is not manager of organization anymore, i.e. just community user
    get_with_token "/api/v1//organizations/#{organization.id}/relationships/managers", params.to_json, manager_token.token
    expect(json['data'].size).to eq 0
    get_with_token "/api/v1//organizations/#{organization.id}/relationships/members", params.to_json, manager_token.token
    expect(json['data'].size).to eq 0

    User.all.each {|u| u.profile.update! readable: 'world'}
    get_with_token "/api/v1//organizations/#{organization.id}/relationships/managers", params.to_json, manager_token.token
    expect(json['data'].size).to eq 1
    get_with_token "/api/v1//organizations/#{organization.id}/relationships/members", params.to_json, manager_token.token
    expect(json['data'].size).to eq 1
  end



  # REMOVE manager/member

  it 'does not delete organization manager/member without token' do
    organization  = Fabricate(:distribution_system_operator)
    params = {
      data: {id: 123}
    }.to_json

    delete_without_token "/api/v1/organizations/#{organization.id}/relationships/managers", params
    expect(response).to have_http_status(401)

    delete_without_token "/api/v1/organizations/#{organization.id}/relationships/members", params
    expect(response).to have_http_status(401)
  end


  [:simple_access_token, :smartmeter_access_token].each do |token|
    [:member, :manager, :admin].each do |role|
      it "does not delete organization manager/member as #{role} with #{token}" do
        organization    = Fabricate(:distribution_system_operator)
        member_token    = Fabricate(token)
        member          = User.find(member_token.resource_owner_id)
        member.add_role(role, organization)
        params = {
          data: {id: 123}
        }.to_json

        delete_with_token "/api/v1/organizations/#{organization.id}/relationships/managers", params, member_token.token
        expect(response).to have_http_status(403)

        delete_with_token "/api/v1/organizations/#{organization.id}/relationships/members", params, member_token.token
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

    params = {
      data: {id: user.id}
    }.to_json

    delete_with_token "/api/v1/organizations/#{organization.id}/relationships/managers", params, manager_token.token
    expect(response).to have_http_status(204)

    delete_with_token "/api/v1/organizations/#{organization.id}/relationships/members", params, manager_token.token
    expect(response).to have_http_status(204)

    expect(organization.managers).to eq [manager]
    expect(organization.members).to eq []
  end


  it 'deletes organization manager/member with full access token as admin' do
    organization  = Fabricate(:distribution_system_operator)
    manager_token = Fabricate(:full_access_token_as_admin)

    user = Fabricate(:user)
    user.add_role(:manager, organization)
    user.add_role(:member, organization)

    params = {
      data: {id: user.id}
    }.to_json

    delete_with_token "/api/v1/organizations/#{organization.id}/relationships/managers", params, manager_token.token
    expect(response).to have_http_status(204)

    delete_with_token "/api/v1/organizations/#{organization.id}/relationships/members", params, manager_token.token
    expect(response).to have_http_status(204)

    expect(organization.managers).to eq []
    expect(organization.members).to eq []
  end
end
