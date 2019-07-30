shared_examples 'single' do |object_name|

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

shared_examples 'all' do

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
    array = json['array']
    expect(array.to_yaml).to eq [expected_json].to_yaml
  end
end

shared_examples 'create' do |model_clazz, wrong_params, params|

  let(:all_path) { path.sub(%r(/[0-9]+$), '') }

  it '401' do
    GET all_path, $admin
    expire_admin_session do
      POST all_path, $admin
      expect(response).to be_session_expired_json(401)
    end
  end

  it '422' do
    POST all_path, $admin, wrong_params
    expect(response).to have_http_status(422)
    expect(json['errors'].to_yaml).to eq expected_errors.to_yaml
  end

  it '201' do
    POST all_path, $admin, params
    expect(response).to have_http_status(201)
    result = json
    id = result.delete('id')
    expect(result.delete('updated_at')).not_to eq nil
    expect(model_clazz.find(id)).not_to be_nil
    expect(result.to_yaml).to eq expected_json.to_yaml
  end
end
