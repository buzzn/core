require 'buzzn/schemas/support/visitor'
describe Admin, :swagger do
  include SwaggerHelper

  def app
    CoreRoda
  end

  login_path '/api/me/login'

  entity!(:person) { create(:person, :with_account) }

  entity!(:account) { Account::Base.where(person: person) }

  entity!(:bank_account_1) { create(:bank_account, owner: person) }

  entity!(:bank_account_2) { create(:bank_account, owner: person) }

  entity!(:organization) { create(:organization, :other) }

  entity!(:bank_account_3) { create(:bank_account, owner: organization) }

  entity!(:bank_account_4) { create(:bank_account, owner: organization) }

  entity!(:localpool) do
    localpool = create(:group, :localpool)
    person.add_role(Role::GROUP_OWNER, localpool)
    create(:contract, :localpool_processing, localpool: localpool, customer: organization)
    create(:contract, :metering_point_operator, localpool: localpool)
    localpool
  end

  entity!(:billing_cycle_1) { create(:billing_cycle, localpool: localpool) }

  entity!(:billing_cycle_2) { create(:billing_cycle, localpool: localpool) }

  entity!(:tariff) { create(:tariff, group: localpool) }

  entity!(:tariff_2) { create(:tariff, group: localpool, begin_date: Date.today) }

  entity!(:contract) { localpool.contracts.sample }

  entity!(:meter) { create(:meter, :real, group: localpool) }

  entity!(:real_meter) { meter }

  entity!(:real_register) { real_meter.input_register }

  entity!(:virtual_meter) { create(:meter, :virtual, group: localpool) }

  entity!(:virtual_register) do
    reg = virtual_meter.register
    create(:formula_part, operand: real_register, register: reg)
    reg
  end

  entity!(:formula_part) { virtual_register.formula_parts.first }

  entity!(:register) { meter.registers.first }

  entity!(:reading) { create(:reading, register: register) }
  entity!(:reading_2) { create(:reading, register: register, date: Date.today) }

  entity!(:localpool_power_taker_contract) do
    register = create(:meter, :real, group: localpool).input_register
    create(:contract, :localpool_powertaker,
           localpool: localpool,
           market_location: create(:market_location, register: register))
  end

  entity!(:billing_1) do
    create(:billing, billing_cycle: billing_cycle_1,
              contract: localpool_power_taker_contract)
  end

  entity!(:billing_2) do
    create(:billing, billing_cycle: billing_cycle_1,
              contract: localpool_power_taker_contract)
  end

  swagger do |s|
    s.basePath = '/api/admin'
  end

  get '/persons' do
    description 'return all persons'
  end

  get '/organizations' do
    description 'return all organizations'
  end

  get '/localpools' do
    description 'return all localpools'
  end

  post '/localpools' do
    description 'creates localpool'
    schema Schemas::Transactions::Admin::Localpool::Create
  end

  get '/localpools/{localpool.id}' do
    description 'returns the localpool'
  end

  patch '/localpools/{localpool.id}' do
    description 'updates the localpool'
    schema Schemas::Transactions::Admin::Localpool::Update
  end

  get '/localpools/{localpool.id}/bubbles' do
    description 'returns the bubbles of the localpool'
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

  # meters

  get '/localpools/{localpool.id}/meters' do
    description 'returns all the meters of the localpool'
  end

  get '/localpools/{localpool.id}/meters/{meter.id}' do
    description 'returns the meters for the given ID'
  end

  patch '/localpools/{localpool.id}/meters/{real_meter.id}' do
    description 'updates the real meter for the given IDs'
    schema Schemas::Transactions::Admin::Meter::UpdateReal
  end

  # virtual_meters > formula_parts

  get '/localpools/{localpool.id}/meters/{virtual_meter.id}/formula-parts' do
    description 'get formula-parts of virtual meter for the given IDs'
  end

  get '/localpools/{localpool.id}/meters/{virtual_meter.id}/formula-parts/{formula_part.id}' do
    description 'get formula-part of virtual meter for the given IDs'
  end

  patch '/localpools/{localpool.id}/meters/{virtual_meter.id}/formula-parts/{formula_part.id}' do
    description 'update formula-part of virtual meter for the given IDs'
    schema Schemas::Transactions::Admin::Register::UpdateFormulaPart
  end

  # meters > registers

  get '/localpools/{localpool.id}/meters/{meter.id}/registers' do
    description 'returns all registers of a meter for the given IDs'
  end

  get '/localpools/{localpool.id}/meters/{meter.id}/registers/{register.id}' do
    description 'returns the register of a meter for the given IDs'
  end

  patch '/localpools/{localpool.id}/meters/{real_meter.id}/registers/{real_register.id}' do
    description 'update the real register of a meter for the given IDs'
    schema Schemas::Transactions::Admin::Register::UpdateReal
  end

  # meters > registers > ticker

  # return status 404 as is so it always fails
  # get '/localpools/{localpool.id}/meters/{meter.id}/registers/{register.id}/ticker' do
  #  description 'returns the energy ticker of the register for the given IDs'
  # end

  # meters > registers > readings

  post '/localpools/{localpool.id}/meters/{meter.id}/registers/{register.id}/readings' do
    description 'create reading for the register'
    schema Schemas::Transactions::Admin::Reading::Create
  end

  get '/localpools/{localpool.id}/meters/{meter.id}/registers/{register.id}/readings' do
    description 'returns all readings of a register for the given IDs'
  end

  get '/localpools/{localpool.id}/meters/{meter.id}/registers/{register.id}/readings/{reading.id}' do
    description 'returns the reading of a register for the given IDs'
  end

  delete '/localpools/{localpool.id}/meters/{meter.id}/registers/{register.id}/readings/{reading_2.id}' do
    description 'deletes the reading of a register for the given IDs'
  end

  # persons
  get '/localpools/{localpool.id}/persons' do
    description 'returns all the persons of the localpool'
  end

  get '/localpools/{localpool.id}/persons/{person.id}' do
    description 'returns the person of the localpool for the given ID'
  end

  # persons > bank-accounts

  get '/localpools/{localpool.id}/persons/{person.id}/bank-accounts' do
    description 'returns all bank-accounts of the person for the given ID'
  end

  get '/localpools/{localpool.id}/persons/{person.id}/bank-accounts/{bank_account_1.id}' do
    description 'returns the bank-accounts of the person for the given IDs'
  end

  patch '/localpools/{localpool.id}/persons/{person.id}/bank-accounts/{bank_account_1.id}' do
    description 'updates the bank-accounts of the person for the given IDs'
    schema Schemas::Transactions::BankAccount::Update
  end

  delete '/localpools/{localpool.id}/persons/{person.id}/bank-accounts/{bank_account_2.id}' do
    description 'delete the bank-accounts of the person for the given IDs'
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
    schema Schemas::Transactions::BankAccount::Update
  end

  delete '/localpools/{localpool.id}/organizations/{organization.id}/bank-accounts/{bank_account_4.id}' do
    description 'delete the bank-accounts of the organization for the given IDs'
  end

  # tariffs

  get '/localpools/{localpool.id}/tariffs' do
    description 'returns all the tariffs of the localpool'
  end

  post '/localpools/{localpool.id}/tariffs' do
    description 'create tariff for the localpool'
    schema Schemas::Transactions::Admin::Tariff::Create
  end

  get '/localpools/{localpool.id}/tariffs/{tariff.id}' do
    description 'returns the tariff of the localpool for the given IDs'
  end

  delete '/localpools/{localpool.id}/tariffs/{tariff_2.id}' do
    description 'deletes the tariff of the localpool for the given IDs'
  end

  # billing-cycles

  get '/localpools/{localpool.id}/billing-cycles' do
    description 'returns all the billing-cycles of the localpool'
  end

  post '/localpools/{localpool.id}/billing-cycles' do
    description 'creates a billing-cycles for the localpool'
    schema Schemas::Transactions::Admin::BillingCycle::Create
  end

  get '/localpools/{localpool.id}/billing-cycles/{billing_cycle_1.id}' do
    description 'returns the billing-cycles of the localpool'
  end

  patch '/localpools/{localpool.id}/billing-cycles/{billing_cycle_1.id}' do
    description 'updates the billing-cycles of the localpool'
    schema Schemas::Transactions::Admin::BillingCycle::Update
  end

  delete '/localpools/{localpool.id}/billing-cycles/{billing_cycle_2.id}' do
    description 'deletes the billing-cycles of the localpool'
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
    GET swagger.basePath + '/swagger.json', $admin
    expect(response).to have_http_status(200)
    expect(json).not_to be_nil
  end
end
