require 'buzzn/transactions/admin/contract/localpool/create_power_taker_with_organization'
require 'buzzn/transactions/admin/contract/localpool/create_power_taker_with_person'
require 'buzzn/transactions/admin/contract/localpool/create_power_taker_assign'

require 'buzzn/resources/contract/localpool_power_taker_resource'

require_relative '../../../support/params_helper.rb'

shared_examples 'without processing contract' do |transaction|

  let(:result) do
    transaction.(resource: r, params: params, localpool: lp)
  end

  it 'does not create' do
    expect(lp.localpool_processing_contracts.count).to eql 0
    expect {result}.to raise_error Buzzn::ValidationError
  end

end

shared_examples 'with existing contract on same register' do |transaction|

  let!(:begin_date) { Date.today }
  let!(:end_date) { Date.today + 30 }

  let!(:begin_date_new) { begin_date + 10 }

  let!(:register_meta) { create(:meta) }
  let!(:other_contract) do
    create(:contract, :localpool_powertaker,
           register_meta: register_meta,
           localpool: lp.object,
           begin_date: begin_date,
           termination_date: nil,
           end_date: end_date)
  end

  let(:params_modified) do
    p = params.dup
    p[:begin_date] = begin_date_new
    p[:register_meta] = { id: register_meta.id }
    p
  end

  let(:result) do
    unless lp.localpool_processing_contracts.any?
      create(:contract, :localpool_processing,
             customer: lp.object.owner,
             contractor: Organization::Market.buzzn,
             localpool: lp.object)
      lp.object.reload
    end
    transaction.(resource: r, params: params_modified, localpool: lp)
  end

  it 'does not create' do
    expect {result}.to raise_error(Buzzn::ValidationError, "{:register_meta=>[{:error=>\"other_contract_active_at_begin\", :contract_id=>#{other_contract.id}}]}")
  end

end

describe Transactions::Admin::Contract::Localpool::CreatePowerTakerAssign, order: :defined do

  let!(:localpool) { create(:group, :localpool) }
  let(:operator) { create(:account, :buzzn_operator) }
  let!(:localpoolr) { Admin::LocalpoolResource.all(operator).retrieve(localpool.id) }

  let(:resource) do
    localpool.save
    localpoolr.localpool_power_taker_contracts
  end

  let(:power_taker_person) { create(:person) }
  let(:power_taker_org) { create(:organization) }

  let(:assign_request_person) do
    { customer: { id: power_taker_person.id, type: 'person' },
      begin_date: Date.today.as_json,
      share_register_publicly: false,
      share_register_with_group: true,
      register_meta: { name: 'Secret Room', label: 'CONSUMPTION'} }
  end

  let(:invalid_assign_request_person) do
    { customer: { id: 13371337, type: 'person' },
      begin_date: Date.today.as_json,
      share_register_publicly: false,
      share_register_with_group: true,
      register_meta: { name: 'Secret Room', label: 'CONSUMPTION'} }
  end

  let(:register_meta) do
    create(:meta)
  end

  let(:assign_request_org) do
    { customer: { id: power_taker_org.id, type: 'organization' },
      begin_date: Date.today.as_json,
      share_register_publicly: false,
      share_register_with_group: true,
      register_meta: { id: register_meta.id } }
  end

  context 'invalid state' do
    it_behaves_like 'without processing contract', Transactions::Admin::Contract::Localpool::CreatePowerTakerAssign.new do
      let(:params) { assign_request_person }
      let(:lp) { localpoolr }
      let(:r) { resource }
    end

    it_behaves_like 'with existing contract on same register', Transactions::Admin::Contract::Localpool::CreatePowerTakerAssign.new do
      let(:params) { assign_request_person }
      let(:lp) { localpoolr }
      let(:r) { resource }
    end

  end

  context 'valid state' do

    let!(:contract) do
      create(:contract, :localpool_processing,
             customer: localpool.owner,
             contractor: Organization::Market.buzzn,
             localpool: localpool)
    end

    let(:result_invalid) do
      Transactions::Admin::Contract::Localpool::CreatePowerTakerAssign.new.(resource: resource,
                                                                            params: invalid_assign_request_person,
                                                                            localpool: localpoolr)
    end

    let(:result_valid_person) do
      Transactions::Admin::Contract::Localpool::CreatePowerTakerAssign.new.(resource: resource,
                                                                            params: assign_request_person,
                                                                            localpool: localpoolr)
    end

    let(:result_valid_org) do
      Transactions::Admin::Contract::Localpool::CreatePowerTakerAssign.new.(resource: resource,
                                                                            params: assign_request_org,
                                                                            localpool: localpoolr)
    end

    it 'does not assign an invalid id' do
      localpool.reload
      expect {result_invalid}.to raise_error(Buzzn::ValidationError, '{:customer=>{:id=>"object does not exist"}}')
    end

    context 'person' do
      it 'does create and assign with a valid id' do
        expect(result_valid_person).to be_success
        expect(result_valid_person.value!).to be_a Contract::LocalpoolPowerTakerResource
        expect(result_valid_person.value!.customer.id).to eq power_taker_person.id
      end
    end

    context 'organization' do
      it 'does create and assign with a valid id' do
        expect(result_valid_org).to be_success
        expect(result_valid_org.value!).to be_a Contract::LocalpoolPowerTakerResource
        expect(result_valid_org.value!.customer.id).to eq power_taker_org.id
      end
    end

  end

end

describe Transactions::Admin::Contract::Localpool::CreatePowerTakerWithPerson, order: :defined do

  let!(:localpool) { create(:group, :localpool) }
  let(:operator) { create(:account, :buzzn_operator) }
  let!(:localpoolr) { Admin::LocalpoolResource.all(operator).retrieve(localpool.id) }

  let(:resource) do
    localpool.save
    localpoolr.localpool_power_taker_contracts
  end

  # params

  let(:power_taker_person) { build(:person) }

  let(:power_taker_person_address_param) do
    build_address_json(power_taker_person.address)
  end

  let(:power_taker_person_param) do
    build_person_json(power_taker_person, power_taker_person_address_param)
  end

  let(:create_person_request) do
    { customer: power_taker_person_param,
      begin_date: Date.today.as_json,
      register_meta: { name: 'Secret Room', label: 'CONSUMPTION'} }
  end

  context 'invalid state' do
    it_behaves_like 'without processing contract', Transactions::Admin::Contract::Localpool::CreatePowerTakerWithPerson.new do
      let(:params) { create_person_request }
      let(:lp) { localpoolr }
      let(:r) { resource }
    end
  end

  context 'valid state' do

    let!(:contract) do
      create(:contract, :localpool_processing,
             customer: localpool.owner,
             contractor: Organization::Market.buzzn,
             localpool: localpool)
    end

    let(:result) do
      Transactions::Admin::Contract::Localpool::CreatePowerTakerWithPerson.new.(resource: resource,
                                                                                params: create_person_request,
                                                                                localpool: localpoolr)
    end

    it 'creates the contract and creates the powertaker' do
      localpool.reload
      expect(result).to be_success
      expect(result.value!).to be_a Contract::LocalpoolPowerTakerResource
    end

  end

end

describe Transactions::Admin::Contract::Localpool::CreatePowerTakerWithOrganization, order: :defined do

  let!(:localpool) { create(:group, :localpool) }
  let(:operator) { create(:account, :buzzn_operator) }
  let!(:localpoolr) { Admin::LocalpoolResource.all(operator).retrieve(localpool.id) }

  let(:resource) do
    localpool.save
    localpoolr.localpool_power_taker_contracts
  end

  # params

  let(:power_taker_person) { build(:person) }

  let(:address) { build(:address) }

  let(:person) do
    build(:person, :with_bank_account, address: address)
  end

  let(:organization) do
    build(:organization, :with_bank_account,
          address: address,
          contact: person,
          legal_representation: person)
  end

  let(:address_params) do
    build_address_json(address)
  end

  let(:person_params) do
    build_person_json(person, address_params)
  end

  let(:legal_representation_params) do
    build_person_json(person, address_params)
  end

  let(:organization_params) do
    build_organization_json(organization: organization,
                            address_json: address_params,
                            contact_json: person_params,
                            legal_representation_json: legal_representation_params)
  end

  let(:create_org_request) do
    { customer: organization_params,
      begin_date: Date.today.as_json,
      share_register_publicly: false,
      share_register_with_group: true,
      register_meta: { name: 'Secret Room', label: 'CONSUMPTION'} }
  end

  context 'invalid state' do
    it_behaves_like 'without processing contract', Transactions::Admin::Contract::Localpool::CreatePowerTakerWithOrganization.new do
      let(:params) { create_org_request }
      let(:lp) { localpoolr }
      let(:r) { resource }
    end
  end

  context 'valid state' do

    let!(:contract) do
      create(:contract, :localpool_processing,
             customer: localpool.owner,
             contractor: Organization::Market.buzzn,
             localpool: localpool)
    end

    let(:result) do
      Transactions::Admin::Contract::Localpool::CreatePowerTakerWithOrganization.new.(resource: resource,
                                                                                      params: create_org_request,
                                                                                      localpool: localpoolr)
    end

    it 'creates the contract and creates the powertaker' do
      localpool.reload
      expect(result).to be_success
      expect(result.value!).to be_a Contract::LocalpoolPowerTakerResource
    end

  end

end
