describe "Groups API" do

  it 'does gets a group readable by world without token' do
    group = Fabricate(:group)
    get_without_token "/api/v1/groups/#{group.id}"
    expect(response).to have_http_status(200)
  end

  it 'does not gets a group readable by community without token' do
    group = Fabricate(:group_readable_by_community)
    get_without_token "/api/v1/groups/#{group.id}"
    expect(response).to have_http_status(401)
  end


  it 'does not create a group without token' do
    group = Fabricate.build(:group)
    request_params = {
      name:  group.name,
      readable: group.readable,
      description: group.description
    }.to_json
    post_without_token "/api/v1/groups", request_params
    expect(response).to have_http_status(401)
  end

  it 'does not create a group with missing name' do
    access_token  = Fabricate(:access_token)
    group = Fabricate.build(:group)
    request_params = {
      # name:  group.name,
      readable: group.readable,
      description: group.description
    }.to_json
    post_with_token "/api/v1/groups", request_params, access_token.token
    expect(response).to have_http_status(400)
  end


  it 'does create a group' do
    metering_point = Fabricate(:out_metering_point_with_manager)
    manager       = metering_point.managers.first
    access_token  = Fabricate(:access_token, resource_owner_id: manager.id)
    access_token.update_attribute :scopes, 'write'
    group = Fabricate.build(:group)
    request_params = {
      name: group.name,
      readable: group.readable,
      description: group.description
    }.to_json
    post_with_token "/api/v1/groups", request_params, access_token.token
    expect(response).to have_http_status(201)
  end


  it 'does update a group' do
    metering_point = Fabricate(:out_metering_point_with_manager)
    manager       = metering_point.managers.first
    access_token  = Fabricate(:access_token, resource_owner_id: manager.id)
    access_token.update_attribute :scopes, 'write'
    group = Fabricate(:group)
    manager.add_role(:manager, group)
    request_params = {
      id: group.id,
      name: "#{group.name} updated",
      readable: group.readable,
      description: group.description
    }.to_json
    put_with_token "/api/v1/groups", request_params, access_token.token
    expect(response).to have_http_status(200)
    expect(json['data']['attributes']['name']).to eq("#{group.name} updated")
  end


  it 'does delete a group' do
    metering_point = Fabricate(:out_metering_point_with_manager)
    manager       = metering_point.managers.first
    access_token  = Fabricate(:access_token, resource_owner_id: manager.id)
    access_token.update_attribute :scopes, 'write'
    group = Fabricate(:group)
    manager.add_role(:manager, group)
    delete_with_token "/api/v1/groups/#{group.id}", access_token.token
    expect(response).to have_http_status(204)
  end


  it 'does gets a group readable by community' do
    access_token  = Fabricate(:access_token)
    group         = Fabricate(:group_readable_by_community)
    get_with_token "/api/v1/groups/#{group.id}", access_token.token
    expect(response).to have_http_status(200)
  end

  it 'does gets a group readable by members if user is member' do
    access_token  = Fabricate(:access_token)
    group         = Fabricate(:group_readable_by_members)
    group.users   << User.find(access_token.resource_owner_id)
    get_with_token "/api/v1/groups/#{group.id}", access_token.token
    expect(response).to have_http_status(200)
  end

  it 'does not gets a group readable by members if user is not member' do
    access_token  = Fabricate(:access_token)
    group         = Fabricate(:group_readable_by_members)
    get_with_token "/api/v1/groups/#{group.id}", access_token.token
    expect(response).to have_http_status(403)
  end





end
