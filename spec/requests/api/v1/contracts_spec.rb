describe 'Contracts API' do

  before(:all) do
    @page_overload = 11
    @org1 = Fabricate(:metering_point_operator, name: 'buzzn Metering')
    @org2 = Fabricate(:metering_point_operator, name: 'Discovergy')
    @org3 = Fabricate(:metering_point_operator, name: 'MySmartGrid')
    @contract_param_names = [
      'tariff',
      'status',
      'customer_number',
      'contract_number',
      'signing_user',
      'terms',
      'power_of_attorney',
      'confirm_pricing_model',
      'commissioning',
      'mode',
      'organization_id',
    ]
  end

  it 'does not get all contracts without token' do
    get_without_token '/api/v1/contracts'
    expect(response).to have_http_status(401)
  end

  it 'get all contracts for manager user' do
    contract_ids = [ Fabricate(:mpoc_buzzn_metering).id, Fabricate(:mpoc_ferraris_0002_amperix).id ]
    access_token = Fabricate(:full_edit_access_token_as_admin).token
    get_with_token '/api/v1/contracts', {}, access_token
    expect(response).to have_http_status(200)
    contracts = json['data'].reject { |contract| contract_ids.include?(contract['id']) }
    expect(contracts).to be_empty
  end

  it 'paginate all contracts for manager user' do
    @page_overload.times do
      Fabricate(:mpoc_buzzn_metering)
    end
    access_token = Fabricate(:full_edit_access_token_as_admin).token
    get_with_token '/api/v1/contracts', {}, access_token
    expect(response).to have_http_status(200)
    expect(json['meta']['total_pages']).to eq(2)
  end

  it 'does not get a contract without token' do
    contract_id = Fabricate(:mpoc_buzzn_metering).id
    get_without_token "/api/v1/contracts/#{contract_id}"
    expect(response).to have_http_status(401)
  end

  it 'get contract with token' do
    contract_id = Fabricate(:mpoc_buzzn_metering).id
    access_token  = Fabricate(:public_access_token).token
    get_with_token "/api/v1/contracts/#{contract_id}", {}, access_token
    expect(response).to have_http_status(200)
  end

  it 'have crud infos' do
    contract = Fabricate(:mpoc_buzzn_metering)
    access_token  = Fabricate(:public_access_token)

    get_with_token "/api/v1/contracts/#{contract.id}", {}, access_token.token
    ['updateable', 'deletable'].each do |attr|
      expect(json['data']['attributes']).to include(attr)
    end
  end

  it 'does not get contract with token for wrong id' do
    access_token  = Fabricate(:public_access_token).token
    get_with_token "/api/v1/contracts/xxrandomxx", {}, access_token
    expect(response).to have_http_status(404)
  end

  it 'does not create contract without token' do
    contract = Fabricate.build(:mpoc_buzzn_metering)
    request_params = Hash.new
    @contract_param_names.each do |param_name|
      request_params[param_name] = contract[param_name]
    end
    post_without_token "/api/v1/contracts/", request_params.to_json
    expect(response).to have_http_status(401)
  end

  it 'create contract with manager token' do
    contract = Fabricate.build(:mpoc_buzzn_metering)
    request_params = Hash.new
    @contract_param_names.each do |param_name|
      request_params[param_name] = contract[param_name]
    end
    access_token  = Fabricate(:full_edit_access_token_as_admin).token
    post_with_token "/api/v1/contracts/", request_params.to_json, access_token
    expect(response).to have_http_status(201)
  end

  it 'does not create contract with manager token if some of the params missing' do
    contract = Fabricate.build(:mpoc_buzzn_metering)
    request_params = Hash.new
    @contract_param_names.each do |param_name|
      request_params[param_name] = contract[param_name]
    end
    access_token  = Fabricate(:full_edit_access_token_as_admin).token
    request_params.each do |missing_param, val|
      broken_params = request_params.reject { |key, val| key == missing_param }
      post_with_token "/api/v1/contracts/", broken_params.to_json, access_token
      expect(response).to have_http_status(400)
      expect(json['error']).to eq("#{missing_param} is missing")
    end
  end

  it 'does not create contract with manager token if some params are wrong' do
    contract = Fabricate.build(:mpoc_buzzn_metering)
    request_params = Hash.new
    @contract_param_names.each do |param_name|
      if contract[param_name].is_a?(Date)
        request_params[param_name] = false
      elsif contract[param_name].is_a?(Boolean)
        request_params[param_name] = "unknown"
      else
        request_params[param_name] = contract[param_name]
      end
    end
    access_token  = Fabricate(:full_edit_access_token_as_admin).token
    post_with_token "/api/v1/contracts/", request_params.to_json, access_token
    expect(response).to have_http_status(400)
  end

  it 'does not update contract without token' do
    contract_id = Fabricate(:mpoc_buzzn_metering).id
    new_contract = Fabricate.build(:mpoc_ferraris_0002_amperix)
    request_params = {
      id: contract_id,
      mode:  new_contract.mode,
    }.to_json
    put_without_token "/api/v1/contracts/", request_params
    expect(response).to have_http_status(401)
  end

  it 'update contract with manager token' do
    contract_id = Fabricate(:mpoc_buzzn_metering).id
    new_contract = Fabricate.build(:mpoc_ferraris_0002_amperix)
    access_token  = Fabricate(:full_edit_access_token_as_admin).token
    request_params = {
      id: contract_id,
      mode:  new_contract.mode,
    }.to_json
    put_with_token "/api/v1/contracts/", request_params, access_token
    expect(response).to have_http_status(200)
    expect(json['data']['attributes']['mode']).to eq(new_contract.mode)
  end

  it 'does not update contract with manager token if some params are wrong' do
    contract_id = Fabricate(:mpoc_buzzn_metering).id
    new_contract = Fabricate.build(:mpoc_ferraris_0002_amperix)
    access_token  = Fabricate(:full_edit_access_token_as_admin).token
    request_params = { id: contract_id }
    @contract_param_names.each do |param_name|
      if new_contract[param_name].is_a?(Date)
        request_params[param_name] = false
      elsif new_contract[param_name].is_a?(Boolean)
        request_params[param_name] = "unknown"
      end
    end
    put_with_token "/api/v1/contracts/", request_params.to_json, access_token
    expect(response).to have_http_status(400)
  end

  it 'does not update contract with manager token and wrong id' do
    id = SecureRandom.uuid
    new_contract = Fabricate.build(:mpoc_ferraris_0002_amperix)
    access_token  = Fabricate(:full_edit_access_token_as_admin).token
    request_params = {
      id: "#{id}random",
      mode:  new_contract.mode,
    }.to_json
    put_with_token "/api/v1/contracts/", request_params, access_token
    expect(response).to have_http_status(404)
  end

  it 'does not delete contract without token' do
    contract_id = Fabricate(:mpoc_buzzn_metering).id
    delete_without_token "/api/v1/contracts/#{contract_id}"
    expect(response).to have_http_status(401)
  end

  it 'delete contract with manager token' do
    contract_id = Fabricate(:mpoc_buzzn_metering).id
    access_token  = Fabricate(:full_edit_access_token_as_admin).token
    delete_with_token "/api/v1/contracts/#{contract_id}", access_token
    expect(response).to have_http_status(200)
  end

end
