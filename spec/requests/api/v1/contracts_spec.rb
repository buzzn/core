describe 'Contracts API' do

  before(:all) do
    @org1 = Fabricate(:metering_point_operator, name: 'buzzn Metering')
    @org2 = Fabricate(:metering_point_operator, name: 'Discovergy')
    @org3 = Fabricate(:metering_point_operator, name: 'MySmartGrid')
  end

  it 'does not get all contracts without token' do
    get_without_token '/api/v1/contracts'
    expect(response).to have_http_status(401)
  end

  it 'get all contracts for admin user' do
    contract_ids = [ Fabricate(:mpoc_buzzn_metering).id, Fabricate(:mpoc_ferraris_0002_amperix).id ]
    access_token = Fabricate(:admin_access_token).token
    get_with_token '/api/v1/contracts', {}, access_token
    # binding.pry
    expect(response).to have_http_status(200)
    contracts = json['data'].reject { |contract| contract_ids.include?(contract['id']) }
    expect(contracts).to be_empty
  end

  it 'does not get a contract without token' do
    contract_id = Fabricate(:mpoc_buzzn_metering).id
    get_without_token "/api/v1/contracts/#{contract_id}"
    expect(response).to have_http_status(401)
  end

  it 'get contract with token' do
    contract_id = Fabricate(:mpoc_buzzn_metering).id
    access_token  = Fabricate(:access_token).token
    get_with_token "/api/v1/contracts/#{contract_id}", {}, access_token
    expect(response).to have_http_status(200)
  end

  it 'does not create contract without token' do
    contract = Fabricate.build(:mpoc_buzzn_metering)
    request_params = Hash.new
    [
      'tariff',
      'status',
      'customer_number',
      'contract_number',
      'signing_user',
      'terms',
      'power_of_attorney',
      'confirm_pricing_model',
      'commissioning',
      'mode'
    ].each { |param_name| request_params[param_name] = contract[param_name] }
    request_params['organization_id'] = @org2.id
    post_without_token "/api/v1/contracts/", request_params.to_json
    # binding.pry
    expect(response).to have_http_status(401)
  end

  it 'create contract with admin token' do
    contract = Fabricate.build(:mpoc_buzzn_metering)
    request_params = Hash.new
    [
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
    ].each { |param_name| request_params[param_name] = contract[param_name] }
    request_params['organization_id'] = @org2.id
    access_token  = Fabricate(:admin_access_token).token
    post_with_token "/api/v1/contracts/", request_params.to_json, access_token
    # binding.pry
    expect(response).to have_http_status(201)
  end

  it 'does not update contract without token' do
    contract_id = Fabricate(:mpoc_buzzn_metering).id
    new_contract = Fabricate.build(:mpoc_ferraris_0002_amperix)
    request_params = {
      id: contract_id,
      mode:  new_contract.mode,
    }.to_json
    put_without_token "/api/v1/contracts/", request_params
    # binding.pry
    expect(response).to have_http_status(401)
  end

  it 'update contract with admin token' do
    contract_id = Fabricate(:mpoc_buzzn_metering).id
    new_contract = Fabricate.build(:mpoc_ferraris_0002_amperix)
    access_token  = Fabricate(:admin_access_token).token
    request_params = {
      id: contract_id,
      mode:  new_contract.mode,
    }.to_json
    put_with_token "/api/v1/contracts/", request_params, access_token
    # binding.pry
    expect(response).to have_http_status(200)
    expect(json['data']['attributes']['mode']).to eq(new_contract.mode)
  end

  it 'does not delete contract without token' do
    contract_id = Fabricate(:mpoc_buzzn_metering).id
    delete_without_token "/api/v1/contracts/#{contract_id}"
    expect(response).to have_http_status(401)
  end

  it 'delete contract with admin token' do
    contract_id = Fabricate(:mpoc_buzzn_metering).id
    access_token  = Fabricate(:admin_access_token).token
    delete_with_token "/api/v1/contracts/#{contract_id}", access_token
    expect(response).to have_http_status(200)
  end

end