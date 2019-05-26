require 'buzzn/schemas/support/visitor'
describe Admin, :swagger, :request_helper, order: :defined do
  include SwaggerHelper

  def app
    CoreRoda
  end

  login_path '/api/me/login'

  entity!(:person) { create(:person, :with_account) }

  entity!(:account) { Account::Base.where(person: person) }

  entity!(:bank_account_1) { create(:bank_account, owner: person) }

  entity!(:bank_account_2) { create(:bank_account, owner: person) }

  entity!(:organization) { create(:organization,
                                  :with_address,
                                  :with_contact,
                                  :with_legal_representation) }

  entity!(:bank_account_3) { create(:bank_account, owner: organization) }

  entity!(:bank_account_4) { create(:bank_account, owner: organization) }

  entity!(:localpool) do
    localpool = create(:group, :localpool, :with_address, owner: person)
    create(:contract, :localpool_processing, localpool: localpool)
    localpool
  end

  entity(:metering_point_operator_contract) do
    create(:contract, :metering_point_operator, localpool: localpool)
  end

  entity!(:document) do
    document = create(:document, :pdf)
    contract = localpool.contracts.sample
    contract.documents << document
    document
  end

  entity!(:localpool2) { create(:group, :localpool, owner: nil, gap_contract_customer: person) }

  entity!(:localpool3) do
    create(:group, :localpool, owner: organization, gap_contract_customer: organization)
  end

  entity!(:localpool_pta) do
    localpool
  end

  entity!(:localpool_pto) do
    localpool
  end

  entity!(:localpool_ptp) do
    localpool
  end

  entity!(:localpool_3pc) do
    localpool
  end

  entity!(:localpool_lpc) do
    localpool3
  end

  entity!(:localpool_mpo) do
    localpool3
  end

  entity!(:localpool_meter_real) do
    localpool
  end

  entity!(:localpool_meter_virtual) do
    localpool
  end

  entity!(:metering_point_contract_json) do
    {
      'type' => 'contract_metering_point_operator',
    }
  end

  entity!(:localpool_processing_contract_json) do
    {
      'type' => 'contract_localpool_processing',
    }
  end

  entity!(:localpool_third_party_contract_json) do
    {
      'type' => 'contract_localpool_third_party',
    }
  end

  entity!(:localpool_power_taker_contract_assign_json) do
    {
      'type' => 'contract_localpool_power_taker',
      'customer' => { id: ''},
    }
  end

  entity!(:localpool_power_taker_contract_org_json) do
    {
      'type' => 'contract_localpool_power_taker',
      'customer' => { type: 'organization'},
    }
  end

  entity!(:localpool_power_taker_contract_person_json) do
    {
      'type' => 'contract_localpool_power_taker',
      'customer' => { type: 'person'},
    }
  end

  entity!(:billing_cycle_1) { create(:billing_cycle, localpool: localpool) }

  entity!(:billing_cycle_2) { create(:billing_cycle, localpool: localpool) }

  entity!(:tariff) { create(:tariff, group: localpool) }

  entity!(:tariff_2) { create(:tariff, group: localpool, begin_date: Date.today) }

  entity!(:contract) { localpool.contracts.sample }

  entity!(:device) { create(:device, localpool: localpool) }

  let!(:localpool_processing_contract) do
    localpool.localpool_processing_contracts.first
  end

  entity!(:meter) { create(:meter, :real, group: localpool) }

  entity!(:real_meter) { meter }

  entity!(:real_register) { real_meter.registers.first }

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
    register = create(:meter, :real, group: localpool).registers.first
    create(:contract, :localpool_powertaker,
           localpool: localpool,
           register_meta: register.meta)
  end

  entity!(:localpool_third_party_contract) do
    register = create(:meter, :real, group: localpool).registers.first
    create(:contract, :localpool_third_party,
           localpool: localpool,
           register_meta: register.meta)
  end

  entity!(:localpool_power_taker_contract_2) do
    register = create(:meter, :real, group: localpool).registers.first
    create(:contract, :localpool_powertaker,
           customer: organization,
           localpool: localpool,
           register_meta: register.meta)
  end

  entity!(:register_meta) { localpool_power_taker_contract.register_meta }

  entity!(:payment_1) { create(:payment, contract: localpool_power_taker_contract) }

  entity!(:billing_1) do
    create(:billing, billing_cycle: billing_cycle_1,
              contract: localpool_power_taker_contract)
  end

  entity!(:document2) do
    document = create(:document, :pdf)
    billing_1.documents << document
    document
  end

  entity!(:billing_item_1) do
    create(:billing_item,
           billing: billing_1,
           tariff: billing_1.contract.tariffs.first)

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

  get '/organizations-market' do
    description 'return all market organizations'
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
    schema Schemas::Transactions::Admin::Localpool.update_for(localpool)
  end

  get '/localpools/{localpool.id}/bubbles' do
    description 'returns the bubbles of the localpool'
  end

  # contracts

  get '/localpools/{localpool.id}/contracts' do
    description 'returns all the contracts of the localpool'
  end

  post '/localpools/{localpool_mpo.id}/contracts', $admin, {}, metering_point_contract_json do
    description 'adds a metering point operator contract to the localpool'
    schema Schemas::Transactions::Admin::Contract::Localpool::MeteringPointOperator::Create
  end

  post '/localpools/{localpool_lpc.id}/contracts', $admin, {}, localpool_processing_contract_json do
    description 'adds a processing contract to the localpool'
    schema Schemas::Transactions::Admin::Contract::Localpool::Processing::Create
  end

  post '/localpools/{localpool_pto.id}/contracts', $admin, {}, localpool_power_taker_contract_org_json do
    description 'adds a power taker contract (organization) to the localpool'
    schema Schemas::Transactions::Admin::Contract::Localpool::PowerTaker::CreateWithOrganization
  end

  post '/localpools/{localpool_ptp.id}/contracts', $admin, {}, localpool_power_taker_contract_person_json do
    description 'adds a power taker contract (person) to the localpool'
    schema Schemas::Transactions::Admin::Contract::Localpool::PowerTaker::CreateWithPerson
  end

  post '/localpools/{localpool_pta.id}/contracts', $admin, {}, localpool_power_taker_contract_assign_json do
    description 'adds a power taker contract (assign) to the localpool'
    schema Schemas::Transactions::Admin::Contract::Localpool::PowerTaker::CreateWithAssign
  end

  post '/localpools/{localpool_3pc.id}/contracts', $admin, {}, localpool_third_party_contract_json do
    description 'adds a third party contract to the localpool'
    schema Schemas::Transactions::Admin::Contract::Localpool::ThirdParty::Create
  end

  get '/localpools/{localpool.id}/contracts/{contract.id}' do
    description 'returns the contract for the given ID'
  end

  patch '/localpools/{localpool.id}/contracts/{localpool_processing_contract.id}' do
    description 'updates an existing LocalpoolProcessingContract'
    schema Schemas::Transactions::Admin::Contract::Localpool::Processing::Update
  end

  patch '/localpools/{localpool.id}/contracts/{metering_point_operator_contract.id}' do
    description 'updates an existing MeteringPointOperatorContract'
    schema Schemas::Transactions::Admin::Contract::Localpool::MeteringPointOperator::Update
  end

  patch '/localpools/{localpool.id}/contracts/{localpool_power_taker_contract.id}' do
    description 'updates an existing LocalpoolPowerTakerContract'
    schema Schemas::Transactions::Admin::Contract::Localpool::PowerTaker::Update
  end

  patch '/localpools/{localpool.id}/contracts/{localpool_third_party_contract.id}' do
    description 'updates an existing LocalpoolThirdPartyContract'
    schema Schemas::Transactions::Admin::Contract::Localpool::ThirdParty::Update
  end

  patch '/localpools/{localpool.id}/contracts/{localpool_power_taker_contract_2.id}/customer-organization' do
    description 'updates the organization owner of the localpool'
    schema Schemas::Transactions::Organization.update_for(localpool_power_taker_contract_2.customer)
  end

  patch '/localpools/{localpool.id}/contracts/{localpool_power_taker_contract.id}/customer-person' do
    description 'updates an existing LocalpoolPowerTakerContract'
    schema Schemas::Transactions::Person.update_for(localpool_power_taker_contract.customer)
  end

  patch '/localpools/{localpool.id}/contracts/{localpool_power_taker_contract_2.id}/customer-bank-account' do
    description 'assigns a bank account of the customer to the contract'
    schema Schemas::Transactions::BankAccount::Assign
  end

  patch '/localpools/{localpool.id}/contracts/{localpool_power_taker_contract_2.id}/contractor-bank-account' do
    description 'assigns a bank account of the contractor to the contract'
    schema Schemas::Transactions::BankAccount::Assign
  end

  get '/localpools/{localpool.id}/contracts/{localpool_power_taker_contract.id}/tariffs' do
    description 'returns the tariffs of the contract'
  end

  patch '/localpools/{localpool.id}/contracts/{localpool_power_taker_contract.id}/tariffs' do
    description 'updates the tariffs of an LocalpoolPowerTakerContract'
    schema Schemas::Transactions::Admin::Contract::Localpool::PowerTaker::AssignTariffs
  end

  get '/localpools/{localpool.id}/contracts/{contract.id}/contractor' do
    description 'returns the contractor of the contract'
  end

  get '/localpools/{localpool.id}/contracts/{contract.id}/customer' do
    description 'returns the customer of the contract'
  end

  get '/localpools/{localpool.id}/contracts/{contract.id}/documents' do
    description 'returns the documents of the contract'
  end

  post '/localpools/{localpool.id}/contracts/{contract.id}/documents', $admin, :consumes => ['multipart/form-data'] do
    description 'attaches a document to a contract'
    schema Schemas::Transactions::Admin::Document::Create
  end

  get '/localpools/{localpool.id}/contracts/{contract.id}/documents/{document.id}' do
    description 'returns the metadata of a document'
  end

  get '/localpools/{localpool.id}/contracts/{contract.id}/documents/{document.id}/fetch', $admin, :produces => ['application/octet-stream', 'application/pdf'] do
    description 'serves the actual document'
  end

  post '/localpools/{localpool.id}/contracts/{contract.id}/documents/generate', $admin do
    description 'documents the contract by producing a PDF'
    schema Schemas::Transactions::Admin::Contract::Document
  end

  delete '/localpools/{localpool.id}/contracts/{contract.id}/documents/{document.id}' do
    description 'deletes a document'
  end

  # contract -> billings

  get '/localpools/{localpool.id}/contracts/{localpool_power_taker_contract.id}/billings' do
    description 'get billings for an LocalpoolPowerTakerContract'
  end

  post '/localpools/{localpool.id}/contracts/{localpool_power_taker_contract.id}/billings' do
    description 'create a new billing for an LocalpoolPowerTakerContract'
    schema Schemas::Transactions::Admin::Billing::Create
  end

  get '/localpools/{localpool.id}/contracts/{localpool_power_taker_contract.id}/billings/{billing_1.id}' do
    description 'get a specific billing for an LocalpoolPowerTakerContract'
  end

  patch '/localpools/{localpool.id}/contracts/{localpool_power_taker_contract.id}/billings/{billing_1.id}' do
    description 'updates a billing for an LocalpoolPowerTakerContract'
    schema Schemas::Transactions::Admin::Billing::Update
  end

  # contract -> billings -> items

  patch '/localpools/{localpool.id}/contracts/{localpool_power_taker_contract.id}/billings/{billing_1.id}/items/{billing_item_1.id}' do
    description 'updates a billing item for a Billing'
    schema Schemas::Transactions::Admin::BillingItem::Update
  end

  # contract -> billings -> documents

  get '/localpools/{localpool.id}/contracts/{localpool_power_taker_contract.id}/billings/{billing_1.id}/documents' do
    description 'returns the documents of the billing'
  end

  get '/localpools/{localpool.id}/contracts/{localpool_power_taker_contract.id}/billings/{billing_1.id}/documents/{document2.id}' do
    description 'returns the metadata of a document'
  end

  get '/localpools/{localpool.id}/contracts/{localpool_power_taker_contract.id}/billings/{billing_1.id}/documents/{document2.id}/fetch', $admin, :produces => ['application/octet-stream', 'application/pdf'] do
    description 'serves the actual document'
  end

  # contract -> accounting

  get '/localpools/{localpool.id}/contracts/{localpool_power_taker_contract.id}/accounting/balance_sheet' do
    description 'retrieve balance sheet for the contract'
  end

  post '/localpools/{localpool.id}/contracts/{localpool_power_taker_contract.id}/accounting/book' do
    schema Schemas::Transactions::Accounting::Book
    description 'book an entry onto the account of the contract'
  end

  # contract -> payments

  get '/localpools/{localpool.id}/contracts/{localpool_power_taker_contract.id}/payments' do
    description 'retrieve payments of the contract'
  end

  post '/localpools/{localpool.id}/contracts/{localpool_power_taker_contract.id}/payments', $admin, {}, {'price_cents' => 'dontinclude'} do
    schema Schemas::Transactions::Admin::Contract::Payment::Create
    description 'add an payment entry to the contract'
  end

  get '/localpools/{localpool.id}/contracts/{localpool_power_taker_contract.id}/payments/{payment_1.id}' do
    description 'retrieve a payment entry of the contract'
  end

  patch '/localpools/{localpool.id}/contracts/{localpool_power_taker_contract.id}/payments/{payment_1.id}' do
    schema Schemas::Transactions::Admin::Contract::Payment::Update
    description 'update an payment entry to the contract'
  end

  delete '/localpools/{localpool.id}/contracts/{localpool_power_taker_contract.id}/payments/{payment_1.id}' do
    description 'delete a payment entry'
  end

  # meters

  get '/localpools/{localpool.id}/meters' do
    description 'returns all the meters of the localpool'
  end

  get '/localpools/{localpool.id}/meters/{meter.id}' do
    description 'returns the meters for the given ID'
  end

  post '/localpools/{localpool_meter_real.id}/meters', $admin, {}, {'type' => 'real'} do
    description 'creates a new real meter'
    schema Schemas::Transactions::Admin::Meter::CreateReal
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

  patch '/localpools/{localpool.id}/meters/{meter.id}/registers/{register.id}' do
    description 'update a real register'
    schema Schemas::Transactions::Admin::Register::UpdateReal
  end

  # register_meta

  get '/localpools/{localpool.id}/register-metas' do
    description 'get all market locations of a localpool'
  end

  get '/localpools/{localpool.id}/register-metas/{register_meta.id}' do
    description 'get all market locations of a localpool'
  end

  patch '/localpools/{localpool.id}/register-metas/{register_meta.id}' do
    description 'update the meta register'
    schema Schemas::Transactions::Admin::Register::UpdateMeta
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

  post '/localpools/{localpool.id}/meters/{meter.id}/registers/{register.id}/readings/request/read' do
    description 'request a reading for the register from an external provider'
    schema Schemas::Transactions::Admin::Reading::Request
  end

  post '/localpools/{localpool.id}/meters/{meter.id}/registers/{register.id}/readings/request/create' do
    description 'request a reading for the register from an external provider and store it'
    schema Schemas::Transactions::Admin::Reading::Request
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

  post '/localpools/{localpool.id}/persons/{person.id}/bank-accounts' do
    description 'create a new bank-account of the person for the given ID'
    schema Schemas::Transactions::BankAccount::Create
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

  get '/localpools/{localpool3.id}/organizations' do
    description 'returns all the organizations of the localpool'
  end

  get '/localpools/{localpool3.id}/organizations/{organization.id}' do
    description 'returns the organization of the localpool for the given IDs'
  end

  # organizations > bank-accounts

  get '/localpools/{localpool3.id}/organizations/{organization.id}/bank-accounts' do
    description 'returns all bank-accounts of the organization for the given ID'
  end

  post '/localpools/{localpool3.id}/organizations/{organization.id}/bank-accounts' do
    description 'create a new bank-account of the organization for the given ID'
    schema Schemas::Transactions::BankAccount::Create
  end

  get '/localpools/{localpool3.id}/organizations/{organization.id}/bank-accounts/{bank_account_3.id}' do
    description 'returns the bank-accounts of the organization for the given IDs'
  end

  patch '/localpools/{localpool3.id}/organizations/{organization.id}/bank-accounts/{bank_account_3.id}' do
    description 'updates the bank-accounts of the organization for the given IDs'
    schema Schemas::Transactions::BankAccount::Update
  end

  delete '/localpools/{localpool3.id}/organizations/{organization.id}/bank-accounts/{bank_account_4.id}' do
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

  get '/localpools/{localpool.id}/gap-contract-tariffs' do
    description 'returns all the tariffs of the localpool that are configured for gap contracts'
  end

  patch '/localpools/{localpool.id}/gap-contract-tariffs' do
    description 'set the tariffs for the localpool will be used for future gap contracts'
    schema Schemas::Transactions::Admin::Localpool::AssignGapContractTariffs
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

  # owner

  post '/localpools/{localpool2.id}/person-owner' do
    description 'creates person owner of the localpool'
    schema Schemas::Transactions::Person::CreateWithAddress
  end

  patch '/localpools/{localpool.id}/person-owner' do
    description 'updates the person owner of the localpool'
    schema Schemas::Transactions::Person.update_for(localpool.owner)
  end

  post '/localpools/{localpool.id}/person-owner/{person.id}' do
    description 'assign different person as owner of the localpool'
    schema Schemas::Support.Form
  end

  post '/localpools/{localpool2.id}/organization-owner' do
    description 'creates organization owner of the localpool'
    schema Schemas::Transactions::Organization::CreateWithNested
  end

  patch '/localpools/{localpool3.id}/organization-owner' do
    description 'updates the organization owner of the localpool'
    schema Schemas::Transactions::Organization.update_for(localpool3.gap_contract_customer)
  end

  post '/localpools/{localpool.id}/organization-owner/{organization.id}' do
    description 'assign different organization as owner of the localpool'
    schema Schemas::Support.Form
  end

  # gap contract customer

  post '/localpools/{localpool2.id}/person-gap-contract-customer' do
    description 'creates person gap contract customer of the localpool'
    schema Schemas::Transactions::Person::CreateWithAddress
  end

  patch '/localpools/{localpool.id}/person-gap-contract-customer' do
    description 'updates the gap contract customer of the localpool'
    schema Schemas::Transactions::Person.update_for(localpool2.gap_contract_customer)
  end

  post '/localpools/{localpool.id}/person-gap-contract-customer/{person.id}' do
    description 'assign different person as gap contract customer of the localpool'
    schema Schemas::Support.Form
  end

  post '/localpools/{localpool2.id}/organization-gap-contract-customer' do
    description 'creates organization gap contract customer of the localpool'
    schema Schemas::Transactions::Organization::CreateWithNested
  end

  patch '/localpools/{localpool3.id}/organization-gap-contract-customer' do
    description 'updates the organization owner of the localpool'
    schema Schemas::Transactions::Organization.update_for(localpool3.gap_contract_customer)
  end

  post '/localpools/{localpool.id}/organization-gap-contract-customer/{organization.id}' do
    description 'assign different organization as owner of the localpool'
    schema Schemas::Support.Form
  end

  patch '/localpools/{localpool.id}/gap-contract-customer-bank-account' do
    description 'assigns a bank account of the gap contract customer'
    schema Schemas::Transactions::BankAccount::Assign
  end

  # gap contracts

  post '/localpools/{localpool2.id}/gap-contracts' do
    description 'creates gap contracts for the localpool'
    schema Schemas::Transactions::Admin::Contract::Localpool::GapContracts::Create
  end

  # organizations

  patch '/localpools/{localpool.id}/distribution-system-operator' do
    description 'assigns a the DSO'
    schema Schemas::Transactions::Admin::Localpool::AssignOrganizationMarket
  end

  patch '/localpools/{localpool.id}/transmission-system-operator' do
    description 'assigns a the TSO'
    schema Schemas::Transactions::Admin::Localpool::AssignOrganizationMarket
  end

  patch '/localpools/{localpool.id}/electricity-supplier' do
    description 'assigns a the ES'
    schema Schemas::Transactions::Admin::Localpool::AssignOrganizationMarket
  end
  # devices

  get '/localpools/{localpool.id}/devices' do
    description 'returns all devices of the localpool'
  end

  post '/localpools/{localpool.id}/devices' do
    description 'creates a new for the localpool'
    schema Schemas::Transactions::Device::Create
  end

  get '/localpools/{localpool.id}/devices/{device.id}' do
    description 'returns a device of the localpool'
  end

  patch '/localpools/{localpool.id}/devices/{device.id}' do
    description 'updates a device of the localpool'
    schema Schemas::Transactions::Device::Update
  end

  delete '/localpools/{localpool.id}/devices/{device.id}' do
    description 'deletes a device of the localpool'
  end

  # reports

  post '/localpools/{localpool.id}/reports/eeg' do
    description 'returns the eeg report for the localpool'
    schema Schemas::Transactions::Admin::Report::CreateEegReport
  end

  # swagger

  it 'GET /swagger.json' do
    GET swagger.basePath + '/swagger.json', $admin
    expect(response).to have_http_status(200)
    expect(json).not_to be_nil
  end

end
