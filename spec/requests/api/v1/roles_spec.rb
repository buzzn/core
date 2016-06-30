describe 'Roles API' do

  before(:all) do
    @metering_point   = Fabricate(:metering_point_readable_by_world)
    @group            = Fabricate(:group)
    @member_token     = Fabricate(:access_token)
    @member           = User.find(@member_token.resource_owner_id)
    @manager_token    = Fabricate(:access_token)
    @manager          = User.find(@manager_token.resource_owner_id)
    @wrong_token      = Fabricate(:access_token)

    @member2          = Fabricate(:user_with_world_readable_profile)
    @manager2         = Fabricate(:user_with_world_readable_profile)
    @member3          = Fabricate(:user_with_world_readable_profile)
    @manager3         = Fabricate(:user_with_world_readable_profile)

    @member.add_role(:member, @metering_point)
    @member2.add_role(:member, @metering_point)
    @member3.add_role(:member, @metering_point)
    @group.metering_points << @metering_point

    @manager.add_role(:manager, @metering_point)
    @manager.add_role(:manager, @group)
    @manager2.add_role(:manager, @metering_point)
    @manager2.add_role(:manager, @group)
    @manager3.add_role(:manager, @metering_point)
    @manager3.add_role(:manager, @group)
  end

  it 'does not add role without token' do
    user    = Fabricate(:user)
    params  = {
      resource_id: @group.id,
      resource_type: 'Group',
      role: 'member',
      user_id: user.id,
    }

    put_without_token '/api/v1/roles/add', params.to_json
    expect(response).to have_http_status(401)
  end

  it 'adds member role only by member or manager' do
    user1 = Fabricate(:user_with_world_readable_profile)
    user2 = Fabricate(:user_with_world_readable_profile)
    group_params = {
      resource_id: @group.id,
      resource_type: 'Group',
      role: 'member',
      user_id: user1.id,
    }
    mp_params = {
      resource_id: @metering_point.id,
      resource_type: 'MeteringPoint',
      role: 'member',
      user_id: user1.id,
    }

    put_with_token '/api/v1/roles/add', group_params.to_json, @wrong_token.token
    expect(response).to have_http_status(403)
    put_with_token '/api/v1/roles/add', mp_params.to_json, @wrong_token.token
    expect(response).to have_http_status(403)

    get_with_token "/api/v1/groups/#{@group.id}/members", @member_token.token
    expect(json['data'].size).to eq(3)
    get_with_token "/api/v1/metering-points/#{@metering_point.id}/members", @member_token.token
    expect(json['data'].size).to eq(3)

    put_with_token '/api/v1/roles/add', group_params.to_json, @member_token.token
    expect(response).to have_http_status(200)
    put_with_token '/api/v1/roles/add', mp_params.to_json, @member_token.token
    expect(response).to have_http_status(200)

    get_with_token "/api/v1/groups/#{@group.id}/members", @member_token.token
    expect(json['data'].size).to eq(4)
    get_with_token "/api/v1/metering-points/#{@metering_point.id}/members", @member_token.token
    expect(json['data'].size).to eq(4)

    group_params[:user_id] = user2.id
    mp_params[:user_id] = user2.id

    put_with_token '/api/v1/roles/add', group_params.to_json, @manager_token.token
    expect(response).to have_http_status(200)
    put_with_token '/api/v1/roles/add', mp_params.to_json, @manager_token.token
    expect(response).to have_http_status(200)

    get_with_token "/api/v1/groups/#{@group.id}/members", @member_token.token
    expect(json['data'].size).to eq(5)
    get_with_token "/api/v1/metering-points/#{@metering_point.id}/members", @member_token.token
    expect(json['data'].size).to eq(5)
  end

  it 'adds manager role only by manager' do
    user = Fabricate(:user_with_world_readable_profile)
    group_params = {
      resource_id: @group.id,
      resource_type: 'Group',
      role: 'manager',
      user_id: user.id,
    }
    mp_params = {
      resource_id: @metering_point.id,
      resource_type: 'MeteringPoint',
      role: 'manager',
      user_id: user.id,
    }

    put_with_token '/api/v1/roles/add', group_params.to_json, @wrong_token.token
    expect(response).to have_http_status(403)
    put_with_token '/api/v1/roles/add', mp_params.to_json, @wrong_token.token
    expect(response).to have_http_status(403)

    put_with_token '/api/v1/roles/add', group_params.to_json, @member_token.token
    expect(response).to have_http_status(403)
    put_with_token '/api/v1/roles/add', mp_params.to_json, @member_token.token
    expect(response).to have_http_status(403)

    get_with_token "/api/v1/groups/#{@group.id}/managers", @member_token.token
    expect(json['data'].size).to eq(3)
    get_with_token "/api/v1/metering-points/#{@metering_point.id}/managers", @member_token.token
    expect(json['data'].size).to eq(3)

    put_with_token '/api/v1/roles/add', group_params.to_json, @manager_token.token
    expect(response).to have_http_status(200)
    put_with_token '/api/v1/roles/add', mp_params.to_json, @manager_token.token
    expect(response).to have_http_status(200)

    get_with_token "/api/v1/groups/#{@group.id}/managers", @member_token.token
    expect(json['data'].size).to eq(4)
    get_with_token "/api/v1/metering-points/#{@metering_point.id}/managers", @member_token.token
    expect(json['data'].size).to eq(4)
  end

  it 'does not add role with wrong params' do
    user = Fabricate(:user_with_world_readable_profile)
    group_params = {
      resource_id: @group.id,
      resource_type: 'Group',
      role: 'manager',
      user_id: user.id,
    }

    group_params.each do |missing_param, val|
      broken_params = group_params.reject { |key, val| key == missing_param }
      put_with_token '/api/v1/roles/add', broken_params.to_json, @manager_token.token
      expect(response).to have_http_status(400)
      expect(json['error']).to start_with("#{missing_param} is missing")
    end

    bad_type = group_params.clone
    bad_type[:resource_type] = 'xxxxx'
    put_with_token '/api/v1/roles/add', bad_type.to_json, @manager_token.token
    expect(response).to have_http_status(400)
    expect(json['error']).to eq('resource_type does not have a valid value')

    bad_role = group_params.clone
    bad_role[:role] = 'xxxxx'
    put_with_token '/api/v1/roles/add', bad_role.to_json, @manager_token.token
    expect(response).to have_http_status(400)
    expect(json['error']).to eq('role does not have a valid value')
  end

end