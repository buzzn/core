describe "Groups API" do

  it 'does gets a group readable by world without token' do
    group = Fabricate(:group)
    get_without_token "/api/v1/groups/#{group.id}"
    expect(response).to be_successful
  end

  it 'does not gets a group readable by community without token' do
    group = Fabricate(:group_readable_by_community)
    get_without_token "/api/v1/groups/#{group.id}"
    expect(response).not_to be_successful
  end

  it 'does gets a group readable by community with token' do
    access_token  = Fabricate(:access_token)
    group         = Fabricate(:group_readable_by_community)
    get_with_token "/api/v1/groups/#{group.id}", access_token.token
    expect(response).to be_successful
  end

  it 'does gets a group readable by members if user is member and with token' do
    access_token  = Fabricate(:access_token)
    group         = Fabricate(:group_readable_by_members)
    group.users   << User.find(access_token.resource_owner_id)
    get_with_token "/api/v1/groups/#{group.id}", access_token.token
    expect(response).to be_successful
  end

  it 'does not gets a group readable by members if user is not member and with token' do
    access_token  = Fabricate(:access_token)
    group         = Fabricate(:group_readable_by_members)
    get_with_token "/api/v1/groups/#{group.id}", access_token.token
    expect(response).not_to be_successful
  end


end
