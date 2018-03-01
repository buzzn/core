shared_examples 'GET resource' do |object_name|

  let(:object) { send(object_name) }

  def errors_detail
    json['errors'].first['detail'].sub(/.*[0-9]+ /, '')
  end

  it '401' do
    GET path, $admin
    expire_admin_session do
      GET path, $admin
      expect(response).to be_session_expired_json(401)
    end
  end

  it '403' do
    GET path
    expect(response.status).to eq(403)
    # this comes from the me_roda mounted in TestAdminLocalpoolRoda
    expect(errors_detail).to eq('retrieve Person: permission denied for User: --anonymous--')

    GET path, $user
    expect(response.status).to eq(403)
    expect(errors_detail).to eq("permission denied for User: #{$user.id}")
  end

  it '404' do
    wrong_path = path.sub(/[0-9]*$/, '1234567890')
    GET wrong_path, $admin
    expect(response.status).to eq(404)
    expect(errors_detail).to eq("not found by User: #{$admin.id}")
  end

  it '200' do
    GET path, $admin
    expect(response).to have_http_status(200)
    expect(json.to_yaml).to eq expected_json.to_yaml
  end
end

shared_examples 'GET resources' do

  let(:all_path) { path.sub(%r(/[0-9]+$), '') }

  def errors_detail
    json['errors'].first['detail'].sub(/.*[0-9]+ /, '')
  end

  it '401' do
    GET all_path, $admin
    expire_admin_session do
      GET path, $admin
      expect(response).to be_session_expired_json(401)
    end
  end

  it '403' do
    GET all_path
    expect(response.status).to eq(403)
    # this comes from the me_roda mounted in TestAdminLocalpoolRoda
    expect(errors_detail).to eq('retrieve Person: permission denied for User: --anonymous--')

    GET all_path, $user
    expect(response.status).to eq(403)
    expect(errors_detail).to eq("permission denied for User: #{$user.id}")
  end

  it '200' do
    GET all_path, $admin
    expect(response).to have_http_status(200)
    array = json.is_a?(Array) ? json : json['array']
    expect(array.to_yaml).to eq [expected_json].to_yaml
  end
end
