describe 'Roles API' do

  it 'adds a member role to metering point for some user with admin token' do
    admin_token     = Fabricate(:admin_access_token)
    metering_point  = Fabricate(:metering_point)
    user            = Fabricate(:user)
    params = {
      resource_id:    metering_point.id,
      resource_type:  'MeteringPoint',
      name:           'member',
      user_id:        user.id,
    }.to_json

    get_with_token "/api/v1/metering-points/#{metering_point.id}/members", admin_token.token
    expect(response).to have_http_status(200)
    expect(json['data'].length).to eq(0)
    post_with_token '/api/v1/roles/add', params, admin_token.token
    get_with_token "/api/v1/metering-points/#{metering_point.id}/members", admin_token.token
    expect(response).to have_http_status(200)
    expect(json['data'].length).to eq(1)
  end

  it 'removes a member role from metering point for some user with admin token' do
    admin_token     = Fabricate(:admin_access_token)
    metering_point  = Fabricate(:metering_point)
    user            = Fabricate(:user)
    user.add_role(:member, metering_point)
    params = {
      resource_id:    metering_point.id,
      resource_type:  'MeteringPoint',
      name:           'member',
      user_id:        user.id,
    }.to_json

    get_with_token "/api/v1/metering-points/#{metering_point.id}/members", admin_token.token
    expect(response).to have_http_status(200)
    expect(json['data'].length).to eq(1)
    post_with_token '/api/v1/roles/remove', params, admin_token.token
    get_with_token "/api/v1/metering-points/#{metering_point.id}/members", admin_token.token
    expect(response).to have_http_status(200)
    expect(json['data'].length).to eq(0)
  end

end