shared_examples 'delete' do |object_name, path:|

  let(:object) { send(object_name) }

  let(:_path) { send(path) }

  it '401' do
    GET _path, $admin
    expire_admin_session do
      DELETE _path, $admin
      expect(response).to be_session_expired_json(401)
    end
  end

  it '403' do
    DELETE _path
    expect(response.status).to eq(403)

    DELETE _path, $user
    expect(response.status).to eq(403)
  end

  it '404' do
    wrong_path = _path.sub(/[0-9]*$/, '1234567890')
    DELETE wrong_path, $admin
    expect(response.status).to eq(404)
  end

  context '204' do
    it do
      DELETE _path, $admin
      expect(response).to have_http_status(204)
      expect(response.body).to be_empty

      GET _path, $admin
      expect(response).to have_http_status(404)

      expect { object.reload }.to raise_error ActiveRecord::RecordNotFound
    end
  end
end

shared_examples 'update' do |object_name, path:, wrong:, params:, errors:, expected:|

  let(:object) { send(object_name) }

  let(:_path) { send(path) }

  let(:wrong_input) do
    case wrong
    when Hash
      wrong
    else
      send(wrong)
    end
  end

  let(:right_input) do
    case params
    when Hash
      params
    else
      send(params)
    end
  end

  let(:errors_json) do
    case errors
    when Hash
      errors
    else
      send(errors)
    end
  end

  let(:update_expected_json) do
    case expected
    when Hash
      expected
    else
      send(expected)
    end
  end

  it '401' do
    GET _path, $admin
    expire_admin_session do
      PATCH _path, $admin
      expect(response).to be_session_expired_json(401)
    end
  end

  it '403' do
    PATCH _path
    expect(response.status).to eq(403)

    PATCH _path, $user
    expect(response.status).to eq(403)
  end

  it '404' do
    wrong_path = _path.sub(/[0-9]*$/, '1234567890')
    PATCH wrong_path, $admin
    expect(response.status).to eq(404)
  end

  it '409' do
    PATCH _path, $admin,
          updated_at: Time.now.as_json
    expect(response).to have_http_status(409)
  end

  it '422' do
    PATCH _path, $admin, wrong_input
    expect(response).to have_http_status(422)
    expect(sort_hash(json).to_yaml).to eq sort_hash(errors_json).to_yaml
  end

  it '200' do
    old = object.updated_at
    PATCH _path, $admin,
          right_input.merge(updated_at: object.updated_at)

    expect(response).to have_http_status(200)
    object.reload
    right_input.each do |key, val|
      expect(object.send(key).as_json).to eq val
    end

    result = json
    expect(result.delete('updated_at')).to be > old.as_json
    expect(result.delete('id')).to eq(object.id)
    expect(sort_hash(result).to_yaml).to eq sort_hash(update_expected_json).to_yaml
  end
end

shared_examples 'single' do |object_name, path:, expected:|

  let(:object) { send(object_name) }

  let(:_path) { send(path) }

  it '401' do
    GET _path, $admin
    expire_admin_session do
      GET _path, $admin
      expect(response).to be_session_expired_json(401)
    end
  end

  it '403' do
    GET _path
    expect(response.status).to eq(403)

    GET _path, $user
    expect(response.status).to eq(403)
  end

  it '404' do
    wrong_path = _path.sub(/[0-9]*$/, '1234567890')
    GET wrong_path, $admin
    expect(response.status).to eq(404)
  end

  it '200' do
    GET _path, $admin
    expect(response).to have_http_status(200)
    expect(sort_hash(json).to_yaml).to eq sort_hash(send(expected)).to_yaml
  end
end

shared_examples 'all' do |path:, expected:, meta: nil|

  let(:all_path) { send(path).sub(%r(/[0-9]+$), '') }

  it '401' do
    GET all_path, $admin
    expire_admin_session do
      GET all_path, $admin
      expect(response).to be_session_expired_json(401)
    end
  end

  it '403' do
    GET all_path
    expect(response.status).to eq(403)

    GET all_path, $user
    expect(response.status).to eq(403)
  end

  it '200' do
    GET all_path, $admin
    expect(response).to have_http_status(200)
    rjson = json
    array = rjson.delete('array')
    expect(sort_hash(array).to_yaml).to eq [sort_hash(send(expected))].to_yaml
    expect(rjson.to_yaml).to eq send(meta).to_yaml if meta
  end
end

shared_examples 'create' do |model_clazz, path:, wrong:, params:, errors:, expected:|

  let(:all_path) { send(path).sub(%r(/[0-9]+$), '') }

  let(:wrong_input) do
    case wrong
    when Hash
      wrong
    else
      send(wrong)
    end
  end

  let(:right_input) do
    case params
    when Hash
      params
    else
      send(params)
    end
  end

  let(:create_expected_json) do
    case expected
    when Hash
      expected
    else
      send(expected)
    end
  end

  let(:errors_json) do
    case errors
    when Hash
      errors
    else
      send(errors)
    end
  end

  it '401' do
    GET all_path, $admin
    expire_admin_session do
      POST all_path, $admin
      expect(response).to be_session_expired_json(401)
    end
  end

  it '422' do
    POST all_path, $admin, wrong_input
    send(:p, json) if response.status != 422
    expect(response).to have_http_status(422)
    expect(json.to_yaml).to eq errors_json.to_yaml
  end

  it '201' do
    POST all_path, $admin, right_input
    send(:p, json) if response.status != 201
    expect(response).to have_http_status(201)
    result = json
    id = result.delete('id')
    object = model_clazz.find(id)
    expect(result.delete('updated_at')).not_to eq nil
    expect(object).not_to be_nil
    obj_attrs = object.attributes
    right_input.each do |key, val|
      next unless object.respond_to?(key)
      expect((obj_attrs[key.to_s] || object.send(key)).as_json).to eq val
    end
    expect(result.to_yaml).to eq create_expected_json.to_yaml
  end
end
