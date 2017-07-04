describe Admin do
  include SwaggerHelper

  def app
    CoreRoda
  end

  entity!(:user) { Fabricate(:user) }

  entity!(:bank_account_1) { Fabricate(:bank_account, contracting_party: user) }

  entity!(:bank_account_2) { Fabricate(:bank_account, contracting_party: user) }

  entity!(:organization) { Fabricate(:other_organization) }

  entity!(:bank_account_3) { Fabricate(:bank_account, contracting_party: organization) }

  entity!(:bank_account_4) { Fabricate(:bank_account, contracting_party: organization) }

  entity!(:localpool) do
    localpool = Fabricate(:localpool)
    user.add_role(:localpool_owner, localpool)
    Fabricate(:localpool_processing_contract, localpool: localpool, customer: organization)
    Fabricate(:metering_point_operator_contract, localpool: localpool)
    localpool
  end

  entity!(:billing_cycle_1) { Fabricate(:billing_cycle, localpool: localpool) }

  entity!(:billing_cycle_2) { Fabricate(:billing_cycle, localpool: localpool) }

  entity!(:price) { Fabricate(:price, localpool: localpool) }

  entity!(:contract) { localpool.contracts.sample }

  entity!(:meter) { Fabricate(:meter) }

  entity!(:real_meter) { meter }

  entity!(:virtual_meter) do
    meter = Fabricate(:virtual_meter)
    meter.register.update(group: localpool)
    meter
  end

  entity!(:register) do
    register = meter.registers.first
    register.update(group: localpool)
    register
  end

  entity!(:localpool_power_taker_contract) do
    register = Fabricate(:input_meter).input_register
    register.update(group: localpool)    
    Fabricate(:localpool_power_taker_contract,
              localpool: localpool,
              register: register)
  end

  entity!(:billing_1) do
    Fabricate(:billing, billing_cycle: billing_cycle_1,
              localpool_power_taker_contract: localpool_power_taker_contract)
  end

  entity!(:billing_2) do
    Fabricate(:billing, billing_cycle: billing_cycle_1,
              localpool_power_taker_contract: localpool_power_taker_contract)
  end

  swagger do |s|
    s.basePath = '/api/admin'
  end

  get '/localpools' do
    description 'return all public localpools'
  end

  get '/localpools/{localpool.id}' do
    description 'returns the localpool'
  end

  get '/localpools/{localpool.id}/bubbles' do
    description 'returns the bubbles of the localpool'
  end

  get '/localpools/{localpool.id}/charts' do
    description 'returns the charts of the localpool'
    schema 'charts_schema'
  end

  # contracts
  
  get '/localpools/{localpool.id}/contracts' do
    description 'returns all the contracts of the localpool'
  end

  get '/localpools/{localpool.id}/contracts/{contract.id}' do
    description 'returns the contract for the given ID'
  end

  get '/localpools/{localpool.id}/contracts/{contract.id}/contractor' do
    description 'returns the contractor of the contract'
  end

  get '/localpools/{localpool.id}/contracts/{contract.id}/customer' do
    description 'returns the customer of the contract'
  end

  # registers

  get '/localpools/{localpool.id}/registers' do
    description 'returns all registers'
  end

  get '/localpools/{localpool.id}/registers/{register.id}' do
    description 'returns the register for given ID'
  end

  get '/localpools/{localpool.id}/registers/{register.id}/ticker' do
    description 'returns the power ticker of the register'
  end

  get '/localpools/{localpool.id}/registers/{register.id}/charts' do
    description 'returns the charts of the localpool'
    schema 'charts_schema'
  end

  # meters

  get '/localpools/{localpool.id}/meters' do
    description 'returns all the meters of the localpool'
  end

  get '/localpools/{localpool.id}/meters/{meter.id}' do
    description 'returns the meters for the given ID'
  end

  patch '/localpools/{localpool.id}/meters/{real_meter.id}' do
    description 'updates the real meter for the given ID'
    schema 'update_real_meter_schema'
  end

  patch '/localpools/{localpool.id}/meters/{virtual_meter.id}' do
    description 'updates the virtual meter for the given ID'
    schema 'update_virtual_meter_schema'
  end

  # users
  
  get '/localpools/{localpool.id}/users' do
    description 'returns all the users of the localpool'
  end

  get '/localpools/{localpool.id}/users/{user.id}' do
    description 'returns the user of the localpool for the given ID'
  end

  # users > bank-accounts

  get '/localpools/{localpool.id}/users/{user.id}/bank-accounts' do
    description 'returns all bank-accounts of the user for the given ID'
  end

  get '/localpools/{localpool.id}/users/{user.id}/bank-accounts/{bank_account_1.id}' do
    description 'returns the bank-accounts of the user for the given IDs'
  end

  patch '/localpools/{localpool.id}/users/{user.id}/bank-accounts/{bank_account_1.id}' do
    description 'updates the bank-accounts of the user for the given IDs'
    schema 'update_bank_account_schema'
  end

  delete '/localpools/{localpool.id}/users/{user.id}/bank-accounts/{bank_account_2.id}' do
    description 'delete the bank-accounts of the user for the given IDs'
  end

  # organizations
  
  get '/localpools/{localpool.id}/organizations' do
    description 'returns all the organizations of the localpool'
  end

  get '/localpools/{localpool.id}/organizations/{organization.id}' do
    description 'returns the organization of the localpool for the given IDs'
  end

  # organizations > bank-accounts

  get '/localpools/{localpool.id}/organizations/{organization.id}/bank-accounts' do
    description 'returns all bank-accounts of the organization for the given ID'
  end

  get '/localpools/{localpool.id}/organizations/{organization.id}/bank-accounts/{bank_account_3.id}' do
    description 'returns the bank-accounts of the organization for the given IDs'
  end

  patch '/localpools/{localpool.id}/organizations/{organization.id}/bank-accounts/{bank_account_3.id}' do
    description 'updates the bank-accounts of the organization for the given IDs'
    schema 'update_bank_account_schema'
  end

  delete '/localpools/{localpool.id}/organizations/{organization.id}/bank-accounts/{bank_account_4.id}' do
    description 'delete the bank-accounts of the organization for the given IDs'
  end

  # prices
  
  get '/localpools/{localpool.id}/prices' do
    description 'returns all the prices of the localpool'
  end

  post '/localpools/{localpool.id}/prices' do
    description 'create price for the localpool'
    schema 'create_price_schema'
  end

  get '/localpools/{localpool.id}/prices/{price.id}' do
    description 'returns the price of the localpool for the given IDs'
  end

  patch '/localpools/{localpool.id}/prices/{price.id}' do
    description 'updates the price of the localpool for the given IDs'
    schema 'update_price_schema'
  end

  # billing-cycles

  get '/localpools/{localpool.id}/billing-cycles' do
    description 'returns all the billing-cycles of the localpool'
  end

  post '/localpools/{localpool.id}/billing-cycles' do
    description 'creates a billing-cycles for the localpool'
    schema 'create_billing_cycle_schema'
  end

  get '/localpools/{localpool.id}/billing-cycles/{billing_cycle_1.id}' do
    description 'returns the billing-cycles of the localpool'
  end

  patch '/localpools/{localpool.id}/billing-cycles/{billing_cycle_1.id}' do
    description 'updates the billing-cycles of the localpool'
    schema 'update_billing_cycle_schema'
  end

  delete '/localpools/{localpool.id}/billing-cycles/{billing_cycle_2.id}' do
    description 'deletes the billing-cycles of the localpool'
  end

  # billing-cycles > billings

  get '/localpools/{localpool.id}/billing-cycles/{billing_cycle_1.id}/billings' do
    description 'returns all billings of the billing-cycles for the given IDs'
  end

  post '/localpools/{localpool.id}/billing-cycles/{billing_cycle_1.id}/billings/regular' do
    description 'creates a regular billings for billing-cycles'
    schema 'create_regular_billings_schema'
  end

  get '/localpools/{localpool.id}/billing-cycles/{billing_cycle_1.id}/billings/{billing_1.id}' do
    description 'returns the billing of the billing-cycle for the given IDs'
  end

  patch '/localpools/{localpool.id}/billing-cycles/{billing_cycle_1.id}/billings/{billing_1.id}' do
    description 'updates the billing of the billing-cycles for the given IDs'
    schema 'update_billing_schema'
  end

  delete '/localpools/{localpool.id}/billing-cycles/{billing_cycle_1.id}/billings/{billing_2.id}' do
    description 'deletes the billing of the billing-cycles for the given IDs'
  end

  # localpool-processing-contract
  
  get '/localpools/{localpool.id}/localpool-processing-contract' do
    description 'returns the localpool-processing-contract of the localpool'
  end

  # metering-point-operator-contract
  
  get '/localpools/{localpool.id}/metering-point-operator-contract' do
    description 'returns the metering-point-operator-contract of the localpool'
  end

  # power-taker-contracts
  
  get '/localpools/{localpool.id}/power-taker-contracts' do
    description 'returns all the power-taker-contracts of the localpool'
  end

  # managers
  
  get '/localpools/{localpool.id}/managers' do
    description 'returns all the managers of the localpool'
  end

  # swagger

  it 'GET /swagger.json' do
    GET swagger.basePath + '/swagger.json', admin
    expect(response).to have_http_status(200)
    expect(json).not_to be_nil
  end
end
