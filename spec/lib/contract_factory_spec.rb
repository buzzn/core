# coding: utf-8
require 'buzzn/contract_factory'

describe Buzzn::ContractFactory do

  describe 'power taker' do

    let(:address) { { address: Fabricate.build(:address).attributes
                        .merge!({zip: 86916}) } }

    let(:other_address) { { other_address: Fabricate.build(:address).attributes
                              .merge!({zip: 37181}) } }

    let(:contracting_party) { { contracting_party:
                               { legal_entity: 'natural_person' } } }#,
                                 #provide_permission: FFaker::Boolean.maybe } } }

    let(:company) do
      orga = Fabricate.build(:metering_service_provider)
      { contracting_party: { legal_entity: 'company' },
                             #provide_permission: FFaker::Boolean.maybe },
        company: { authorization: FFaker::Boolean.maybe,
                   organization: { name: orga.name,
                                   phone: orga.phone,
                                   mode: 'other',
                                   email: orga.email} } }
    end

    let(:user) { user = Fabricate(:user) }

    let(:meter) do
      meter = { meter: Fabricate.build(:meter).attributes }
      meter[:meter]['metering_type'] = 'single_tarif_meter'
      meter
    end

    let(:register) do
      { register: Fabricate.build(:register).attributes }
    end

    let(:first_contract) do
      { contract: { move_in: true,
                    beginning: FFaker::Time.date,
                    yearly_kilowatt_hour: 1000 } }
    end

    let(:second_contract) do
      second = first_contract.dup
      second[:contract][:move_in] = false
      second[:contract][:beginning] = nil
      second[:register_operator_name] = FFaker::Name.name
      second
    end

    let(:old_contract) do
      { old_contract: { old_electricity_supplier_name: FFaker::Name.name,
                        customer_number: FFaker::Product.letters(10),
                        contract_number: FFaker::Product.letters(16) } }
    end

    let(:bank_account) do
      { bank_account: { holder: FFaker::Name.name,
                        iban: 'DE23100000001234567890',
                        direct_debit: FFaker::Boolean.maybe } }
    end

    let(:new_user) do
      { user: { email:    FFaker::Internet.email,
                password: '12345678' } }
    end

    let(:profile) { { profile: Fabricate.build(:profile).attributes } }

    subject { Buzzn::ContractFactory }

    before(:all) do
      Bank.update_from(File.read("db/banks/BLZ_20160606.txt"))
      Fabricate(:buzzn_energy)
      dummy = Fabricate(:dummy_energy)
      #TODO remove me once we have a contracting_party at each orga on creation
      Fabricate(:company_contracting_party, organization: dummy)

      csv_dir = 'db/csv'
      zip_vnb = File.read(File.join(csv_dir, "plz_vnb_test.csv"))
      zip_ka = File.read(File.join(csv_dir, "plz_ka_test.csv"))
      nne_vnb = File.read(File.join(csv_dir, "nne_vnb.csv"))
      ZipKa.from_csv(zip_ka)
      ZipVnb.from_csv(zip_vnb)
      NneVnb.from_csv(nne_vnb)
    end

    it 'creates minimal first contract, natural_person, same address for existing user' do
      expect { subject.create_power_taker_contract(user, {user: {}}) }.to raise_error Buzzn::ValidationError
      expect { subject.create_power_taker_contract(user, {profile: {}}) }.to raise_error Buzzn::ValidationError

      params = {}
      expect { subject.create_power_taker_contract(user, params) }.to raise_error Buzzn::NestedValidationError

      params.merge!(address)
      expect { subject.create_power_taker_contract(user, params) }.to raise_error Buzzn::NestedValidationError

      params.merge!(meter)
      expect { subject.create_power_taker_contract(user, params) }.to raise_error Buzzn::ValidationError

      params.merge!(register)
      expect { subject.create_power_taker_contract(user, params) }.to raise_error Buzzn::ValidationError

      params.merge!(contracting_party)
      params.merge!(bank_account)
      expect { subject.create_power_taker_contract(user, params) }.to raise_error Buzzn::ValidationError

      params.merge!(first_contract)
      contract = subject.create_power_taker_contract(user, params)

      expect(contract.valid?).to be true
      expect(user.reload.contracting_parties.size).to eq 1
      party = contract.contract_beneficiary
      expect(user.contracting_parties.include?(party)).to be true
      expect(party.legal_entity).to eq 'natural_person'
      expect(party.organization).to be_nil
      expect(party.bank_account).not_to be_nil
      expect(contract.register).not_to be_nil
      expect(contract.register.address).not_to be_nil
      expect(contract.register.meter).not_to be_nil
      expect(contract.register.address).to eq party.address
      expect(contract.organization).to be_nil
      expect(contract.address).to be_nil
      expect(contract.bank_account).not_to be_nil
      owner = contract.contract_owner
      expect(owner.organization).to eq(Organization.buzzn_energy)
      expect(contract.price_cents_per_kwh).to eq 2560.0
      expect(contract.price_cents_per_month).to eq 1170
      expect(contract.price_cents).to eq 3303
      expect(contract.forecast_watt_hour_pa).to eq 1000000
    end

    it 'creates minimal first contract, natural_person, same address for non-existing user' do
      params = {}
      expect { subject.create_power_taker_contract(nil, params) }.to raise_error Buzzn::NestedValidationError

      params.merge!(new_user)
      expect { subject.create_power_taker_contract(nil, params) }.to raise_error Buzzn::ValidationError

      # now we have am user and merge the rest and get a valid contract
      params.merge!(profile)
      params.merge!(address)
      params.merge!(meter)
      params.merge!(register)
      params.merge!(contracting_party)
      params.merge!(first_contract)
      params.merge!(bank_account)
      contract = subject.create_power_taker_contract(nil, params)
      expect(contract.valid?).to be true
    end

    it 'does not create minimal first contract, natural_person, same address for existing user' do
      params = {}
      params.merge!(address)
      params.merge!(meter)
      params.merge!(register)
      params.merge!(contracting_party)
      params.merge!(first_contract)
      params.merge!(bank_account)

      params[:contract][:beginning] = nil
      params[:contract][:move_in] = true
      expect { subject.create_power_taker_contract(user, params) }.to raise_error Buzzn::ValidationError

      params[:contract][:move_in] = false
      expect { subject.create_power_taker_contract(user, params) }.to raise_error Buzzn::ValidationError

      params[:contract][:beginning] = FFaker::Time.date
      params[:contract][:move_in] = false
      expect { subject.create_power_taker_contract(user, params) }.to raise_error Buzzn::ValidationError

      params[:contract][:move_in] = true
      expect(subject.create_power_taker_contract(user, params).valid?).to eq true
    end

    it 'does not create with old contract, natural_person, same address for existing user' do
      params = {}
      params.merge!(address)
      params.merge!(meter)
      params.merge!(register)
      params.merge!(contracting_party)
      params.merge!(first_contract)
      params.merge!(bank_account)
      params.merge!(old_contract)

      params[:contract][:beginning] = FFaker::Time.date
      params[:contract][:move_in] = true
      expect { subject.create_power_taker_contract(user, params) }.to raise_error Buzzn::ValidationError

      params[:contract][:move_in] = false
      expect { subject.create_power_taker_contract(user, params) }.to raise_error Buzzn::ValidationError

      params[:contract][:beginning] = nil
      params[:contract][:move_in] = true
      expect { subject.create_power_taker_contract(user, params) }.to raise_error Buzzn::ValidationError

      params[:contract][:move_in] = false
      expect(subject.create_power_taker_contract(user, params).valid?).to eq true
    end

    
    it 'creates first contract, natural_person, other address for existing user' do
      params = {}
      params.merge!(address)
      params.merge!(meter)
      params.merge!(register)
      params.merge!(contracting_party)
      params.merge!(other_address)
      params.merge!(first_contract)
      params.merge!(bank_account)
      contract = subject.create_power_taker_contract(user, params)
      expect(contract.valid?).to be true
      expect(user.reload.contracting_parties.size).to eq 1
      party = contract.contract_beneficiary
      expect(user.contracting_parties.include?(party)).to be true
      expect(party.legal_entity).to eq 'natural_person'
      expect(party.organization).to be_nil
      expect(party.bank_account).not_to be_nil
      expect(contract.register).not_to be_nil
      expect(contract.register.address).not_to be_nil
      expect(contract.register.meter).not_to be_nil
      expect(contract.register.address).not_to eq contract.address
      owner = contract.contract_owner
      expect(owner.organization).to eq(Organization.buzzn_energy)
      expect(contract.price_cents_per_kwh).to eq 2630.0
      expect(contract.price_cents_per_month).to eq 1150
      expect(contract.price_cents).to eq 3342
      expect(contract.forecast_watt_hour_pa).to eq 1000000
    end
    
    it 'creates first contract, company, same address for existing user' do
      params = {}
      params.merge!(address)
      params.merge!(meter)
      params.merge!(register)
      params.merge!(company)
      expect { subject.create_power_taker_contract(nil, params) }.to raise_error Buzzn::NestedValidationError
      params.merge!(first_contract)
      params.merge!(bank_account)
      contract = subject.create_power_taker_contract(user, params)
      expect(contract.valid?).to be true
      expect(user.reload.contracting_parties.size).to eq 1
      party = contract.contract_beneficiary
      expect(user.contracting_parties.include?(party)).to be true
      expect(party.legal_entity).to eq 'company'
      expect(party.organization).not_to be_nil
      expect(party.bank_account).not_to be_nil
      expect(contract.register).not_to be_nil
      expect(contract.register.address).not_to be_nil
      expect(contract.register.meter).not_to be_nil
      expect(contract.register.address).not_to eq contract.address
      owner = contract.contract_owner
      expect(owner.organization).to eq(Organization.buzzn_energy)
      expect(contract.price_cents_per_kwh).to eq 2560.0
      expect(contract.price_cents_per_month).to eq 1170
      expect(contract.price_cents).to eq 3303
      expect(contract.forecast_watt_hour_pa).to eq 1000000
    end
    
    
    it 'creates old contract, natural_person, same address for existing user' do
      params = {}
      params.merge!(address)
      params.merge!(meter)
      params.merge!(register)
      params.merge!(contracting_party)
      params.merge!(old_contract)
      expect { subject.create_power_taker_contract(user, params) }.to raise_error Buzzn::ValidationError
      params.merge!(bank_account)
      expect { subject.create_power_taker_contract(user, params) }.to raise_error Buzzn::ValidationError

      expect { subject.create_power_taker_contract(user, params.merge(first_contract)) }.to raise_error Buzzn::ValidationError

      params.merge!(second_contract)
      contract = subject.create_power_taker_contract(user, params)
      expect(contract.valid?).to be true
      expect(user.reload.contracting_parties.size).to eq 1
      party = contract.contract_beneficiary
      expect(user.contracting_parties.include?(party)).to be true
      expect(party.legal_entity).to eq 'natural_person'
      expect(party.organization).to be_nil
      expect(party.bank_account).not_to be_nil
      expect(contract.register).not_to be_nil
      expect(contract.register.address).not_to be_nil
      expect(contract.register.meter).not_to be_nil
      expect(contract.register.address).not_to eq contract.address
      owner = contract.contract_owner
      expect(owner.organization).to eq(Organization.buzzn_energy)
      expect(contract.price_cents_per_kwh).to eq 2560.0
      expect(contract.price_cents_per_month).to eq 1170
      expect(contract.price_cents).to eq 3303
      expect(contract.forecast_watt_hour_pa).to eq 1000000
      expect(contract.other_contract).to eq true
    end
    
  end
end
