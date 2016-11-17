describe 'Contracts API' do

  let (:group) { Fabricate(:group_hopf) }
  let (:access_token_for_group_manager) do
    token = Fabricate(:full_access_token)
    User.find(token.resource_owner_id).add_role(:manager, group)
    token
  end
  let (:contract) { group.contracts.first }
  let(:register) do
    mp = Fabricate(:register)
    mp.contracts << contract
    mp
  end
  let (:access_token_for_register_manager) do
    token = Fabricate(:full_access_token)
    User.find(token.resource_owner_id).add_role(:manager, register)
    token
  end
  let(:full_access_token_as_admin) { Fabricate(:full_access_token_as_admin) }
  let(:page_overload) { 11 }

  before do
    Fabricate(:register_operator, name: 'buzzn Metering')
    Fabricate(:register_operator, name: 'Discovergy')
    Fabricate(:register_operator, name: 'MySmartGrid')
  end

  let(:contract_param_names) do
    [
      'status',
      'customer-number',
      'contract-number',
      'signing-user',
      'terms',
      'power-of-attorney',
      'confirm-pricing-model',
      'commissioning',
      'mode',
      'retailer',
      'price-cents-per-kwh',
      'price-cents-per-month',
      'discount-cents-per-month',
      'other-contract',
      'move-in',
      'beginning',
      'authorization',
      'feedback',
      'attention-by',
      'organization-id',
    ]
  end

  let(:required_contract_param_names) do
    [
      'terms',
      'power_of_attorney',
      'confirm_pricing_model',
      'commissioning',
      'mode',
    ]
  end

  it 'does not get all contracts without token' do
    get_without_token '/api/v1/contracts'
    expect(response).to have_http_status(401)
  end

  it 'gets all contracts as admin with full access token' do
    contract_ids = [ Fabricate(:mpoc_buzzn_metering).id, Fabricate(:mpoc_ferraris_0002_amperix).id ]
    access_token = Fabricate(:full_access_token_as_admin).token
    get_with_token '/api/v1/contracts', {}, access_token
    expect(response).to have_http_status(200)
    contracts = json['data'].reject { |contract| contract_ids.include?(contract['id']) }
    expect(contracts).to be_empty
  end

  it 'search contracts with full access token as admin' do
    contract =  Fabricate(:mpoc_justus)
    Fabricate(:mpoc_ferraris_0002_amperix)
    access_token = Fabricate(:full_access_token_as_admin).token

    request_params = { filter: contract.signing_user }
    get_with_token '/api/v1/contracts', request_params, access_token

    expect(response).to have_http_status(200)
    expect(json['data'].size).to eq 1
    expect(json['data'].first['id']).to eq contract.id
  end

  it 'paginates all contracts as admin with full access token' do
    page_overload.times do
      Fabricate(:mpoc_buzzn_metering)
    end
    access_token = Fabricate(:full_access_token_as_admin).token
    get_with_token '/api/v1/contracts', {}, access_token
    expect(response).to have_http_status(200)
    expect(json['meta']['total_pages']).to eq(2)

    get_with_token '/api/v1/contracts', {per_page: 200}, access_token
    expect(response).to have_http_status(422)
  end

  it 'does not get a contract without token' do
    contract_id = Fabricate(:mpoc_buzzn_metering).id
    get_without_token "/api/v1/contracts/#{contract_id}"
    expect(response).to have_http_status(401)
  end

  it 'does not get a contract with smartmeter token' do
    contract_id = Fabricate(:mpoc_buzzn_metering).id
    access_token  = Fabricate(:smartmeter_access_token)
    get_with_token "/api/v1/contracts/#{contract_id}", access_token.token
    expect(response).to have_http_status(403)
  end

  it 'gets contract with full access token as admin' do
    contract = Fabricate(:mpoc_buzzn_metering)
    access_token  = Fabricate(:full_access_token_as_admin).token
    get_with_token "/api/v1/contracts/#{contract.id}", {}, access_token
    expect(response).to have_http_status(200)
  end

  [:full_access_token_as_admin,
   :access_token_for_group_manager,
   :access_token_for_register_manager].each do |token_name|
    it "gets contract with #{token_name}" do
      get_with_token "/api/v1/contracts/#{contract.id}", {}, send(token_name).token
      expect(response).to have_http_status(200)
    end

    it "updates contract with #{token_name}" do
      new_contract = Fabricate.build(:mpoc_ferraris_0002_amperix)
      contract_param_names.each do |param_name|
        next if ['commissioning', 'beginning', 'organization-id'].include? param_name
        name = param_name.gsub(/-/, '_')
        request_params = {
          "#{name}":  new_contract[param_name],
        }
        patch_with_token "/api/v1/contracts/#{contract.id}", request_params.to_json, send(token_name).token
        expect(response).to have_http_status(200)
        expect(json['data']['attributes'][param_name]).to eq request_params[name.to_sym]
      end
    end

    it "delete contract with #{token_name}" do
      delete_with_token "/api/v1/contracts/#{contract.id}", send(token_name).token
      expect(response).to have_http_status(204)
    end
  end


  it 'does not get contract with token for wrong id' do
    access_token  = Fabricate(:simple_access_token).token
    get_with_token "/api/v1/contracts/xxrandomxx", {}, access_token
    expect(response).to have_http_status(404)
  end

  it 'does not create contract without token' do
    contract = Fabricate.build(:mpoc_buzzn_metering)
    request_params = Hash.new
    contract_param_names.each do |param_name|
      request_params[param_name] = contract[param_name]
    end
    post_without_token "/api/v1/contracts/", request_params.to_json
    expect(response).to have_http_status(401)
  end

  it 'creates contract as admin with full access token' do
    contract = Fabricate.build(:mpoc_buzzn_metering)
    request_params = Hash.new
    contract_param_names.each do |param_name|
      name = param_name.gsub(/-/, '_')
      request_params[name] = contract[name]
    end
    access_token  = Fabricate(:full_access_token_as_admin).token
    post_with_token "/api/v1/contracts/", request_params.to_json, access_token
    expect(response).to have_http_status(201)
    expect(response.headers['Location']).to eq json['data']['id']
    contract_param_names.each do |param_name|
      next if ['commissioning', 'beginning', 'organization-id'].include? param_name
      name = param_name.gsub(/-/, '_')
      expect(json['data']['attributes'][param_name]).to eq request_params[name]
    end
  end

  it 'does not create contract as admin with full access token if some of the required params missing' do
    contract = Fabricate.build(:mpoc_buzzn_metering)
    request_params = Hash.new
    required_contract_param_names.each do |param_name|
      request_params[param_name] = contract[param_name]
    end
    access_token  = Fabricate(:full_access_token_as_admin).token
    request_params.each do |missing_param, val|
      broken_params = request_params.reject { |key, val| key == missing_param }
      post_with_token "/api/v1/contracts/", broken_params.to_json, access_token
      expect(response).to have_http_status(422)
      json['errors'].each do |error|
        expect(error['source']['pointer']).to eq "/data/attributes/#{missing_param}"
        expect(error['title']).to eq 'Invalid Attribute'
        expect(error['detail']).to eq "#{missing_param} is missing"
      end
    end
  end

  it 'does not create contract as admin with full access token if some params are wrong' do
    contract = Fabricate.build(:mpoc_buzzn_metering)
    request_params = Hash.new
    wrong_ones = []
    contract_param_names.each do |param_name|
      if contract[param_name].is_a?(Date)
        wrong_ones << param_name
        request_params[param_name] = false
      elsif contract[param_name].is_a?(Boolean)
        wrong_ones << param_name
        request_params[param_name] = "unknown"
      else
        request_params[param_name] = contract[param_name]
      end
    end
    access_token  = Fabricate(:full_access_token_as_admin).token

    post_with_token "/api/v1/contracts/", request_params.to_json, access_token

    expect(response).to have_http_status(422)
    wrong_ones.each do |param_name|
      error_json = json['errors'].detect do |error|
        error && error['source']['pointer'] ==  "/data/attributes/#{param_name}"
      end
      expect(error_json['title']).to eq 'Invalid Attribute'
      expect(error_json['detail']).to eq "#{param_name} is invalid"
    end
  end

  it 'does not update contract without token' do
    contract_id = Fabricate(:mpoc_buzzn_metering).id
    new_contract = Fabricate.build(:mpoc_ferraris_0002_amperix)
    request_params = {
      mode:  new_contract.mode,
    }.to_json
    patch_without_token "/api/v1/contracts/#{contract_id}", request_params
    expect(response).to have_http_status(401)
  end

  it 'does not update contract as admin with full access token if some params are wrong' do
    contract_id = Fabricate(:mpoc_buzzn_metering).id
    new_contract = Fabricate.build(:mpoc_ferraris_0002_amperix)
    access_token  = Fabricate(:full_access_token_as_admin).token
    request_params = { id: contract_id }
    contract_param_names.each do |param_name|
      if new_contract[param_name].is_a?(Date)
        request_params[param_name] = false
      elsif new_contract[param_name].is_a?(Boolean)
        request_params[param_name] = "unknown"
      end
    end
    patch_with_token "/api/v1/contracts/#{contract_id}", request_params.to_json, access_token
    expect(response).to have_http_status(422)
    json['errors'].each do |error|
      expect(error['source']['pointer']).to match %r(/data/attributes/)
      expect(error['title']).to eq 'Invalid Attribute'
      expect(error['detail']).not_to be_nil
    end
  end

  it 'does not update contract as admin with full access token and wrong id' do
    id = SecureRandom.uuid
    new_contract = Fabricate.build(:mpoc_ferraris_0002_amperix)
    access_token  = Fabricate(:full_access_token_as_admin).token
    request_params = {
      mode:  new_contract.mode,
    }.to_json
    patch_with_token "/api/v1/contracts/#{id}random", request_params, access_token
    expect(response).to have_http_status(404)
  end

  it 'does not delete contract without token' do
    contract_id = Fabricate(:mpoc_buzzn_metering).id
    delete_without_token "/api/v1/contracts/#{contract_id}"
    expect(response).to have_http_status(401)
  end

end
