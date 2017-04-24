# coding: utf-8
require 'buzzn/contract_factory'

describe Buzzn::ContractFactory do

  before do
    if Bank.count == 0
      Bank.update_from(File.read("db/banks/BLZ_20160606.txt"))
    end

    if ZipKa.count == 0
      csv_dir = 'db/csv'
      zip_vnb = File.read(File.join(csv_dir, "plz_vnb_test.csv"))
      zip_ka = File.read(File.join(csv_dir, "plz_ka_test.csv"))
      nne_vnb = File.read(File.join(csv_dir, "nne_vnb.csv"))
      ZipKa.from_csv(zip_ka)
      ZipVnb.from_csv(zip_vnb)
      NneVnb.from_csv(nne_vnb)
    end
  end
  
  describe 'power taker' do

    let(:address) { { address: Fabricate.build(:address).attributes
                        .merge!({zip: 86916}) } }

    let(:other_address) { { other_address: Fabricate.build(:address).attributes
                              .merge!({zip: 37181}) } }

    let(:contracting_party) { { provider_permission: FFaker::Boolean.maybe } }

    let(:company) do
      orga = Fabricate.build(:metering_service_provider)
      { provider_permission: FFaker::Boolean.maybe,
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
      { register: Fabricate.build(:input_register).attributes }
    end

    let(:first_contract) do
      { contract: { terms_accepted: true,
                    power_of_attorney: true,
                    begin_date: FFaker::Time.date,
                    forecast_kwh_pa: 1000 } }
    end

    let(:second_contract) do
      second = first_contract.dup
      second[:contract][:begin_date] = nil
      second
    end

    let(:contract_with_metering_operator) do
      other = first_contract.dup
      other[:contract][:metering_point_operator_name] = FFaker::Name.name
      other
    end

    let(:old_contract) do
      { old_supplier_name: FFaker::Name.name,
        old_customer_number: FFaker::Product.letters(10),
        old_account_number: FFaker::Product.letters(16) }
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

    it 'creates minimal first contract, natural_person, same address for existing user' do
      expect { subject.create_power_taker_contract(user, {user: {}}) }.to raise_error Buzzn::ValidationError
      expect { subject.create_power_taker_contract(user, {profile: {}}) }.to raise_error Buzzn::ValidationError

      params = {}
      expect { subject.create_power_taker_contract(user, params) }.to raise_error Buzzn::ValidationError

      params.merge!(address)
      expect { subject.create_power_taker_contract(user, params) }.to raise_error Buzzn::ValidationError

      params.merge!(meter)
      params.merge!(register)
      expect { subject.create_power_taker_contract(user, params) }.to raise_error Buzzn::ValidationError

      params.merge!(contracting_party)
      params.merge!(bank_account)
      expect { subject.create_power_taker_contract(user, params) }.to raise_error Buzzn::ValidationError

      params.merge!(first_contract)
      contract = subject.create_power_taker_contract(user, params)

      expect(contract.valid?).to be true
      expect(contract.register).not_to be_nil
      expect(contract.register.address).not_to be_nil
      expect(contract.register.meter).not_to be_nil
      expect(contract.old_supplier_name).to be_nil
      expect(contract.old_customer_number).to be_nil
      expect(contract.old_account_number).to be_nil
      expect(contract.forecast_kwh_pa).to eq 1000

      customer = contract.customer
      expect(customer).to eq user
      expect(customer.provider_permission.nil?).to eq false
      expect(customer.address).to eq contract.register.address
      expect(customer.bank_account).not_to be_nil

      contractor = contract.contractor
      expect(contractor).to eq(Organization.buzzn_energy)

      tariff = contract.tariffs.first
      expect(tariff.energyprice_cents_per_kwh).to eq 2560.0
      expect(tariff.baseprice_cents_per_month).to eq 1170

      payment = contract.payments.first
      expect(payment.price_cents).to eq 3303
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

    it 'creates minimal first contract, natural_person, same address for existing user with metering_point_operator' do
      params = {}
      params.merge!(address)
      params.merge!(meter)
      params.merge!(register)
      params.merge!(contracting_party)
      params.merge!(contract_with_metering_operator)
      params.merge!(bank_account)
      contract = subject.create_power_taker_contract(user, params)
      expect(contract.valid?).to be true

      contracts = contract.register.contracts - [contract]
      expect(contracts.size).to eq 1
      expect(contracts.first.class).to eq Contract::MeteringPointOperator
      expect(contracts.first.contractor).to eq Organization.dummy_energy
    end

    it 'does not create with mismatched old contract and begin_date' do
      params = {}
      params.merge!(address)
      params.merge!(meter)
      params.merge!(register)
      params.merge!(contracting_party)
      params.merge!(first_contract)
      params.merge!(bank_account)

      params[:contract][:begin_date] = FFaker::Time.date
      expect(subject.create_power_taker_contract(user, params).valid?).to eq true

      params[:contract].merge!(old_contract)
      expect { subject.create_power_taker_contract(user, params) }.to raise_error Buzzn::ValidationError

      params[:contract].delete_if{ |k,v| k.to_s =~ /old/ }
      params[:contract][:begin_date] = nil
      expect { subject.create_power_taker_contract(user, params) }.to raise_error Buzzn::ValidationError

      params[:contract][:begin_date] = nil
      params[:contract].merge!(old_contract)
      params[:meter]['manufacturer_product_serialnumber'] = '123321'
      params[:register].delete('uid')
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
      expect(contract.register).not_to be_nil
      expect(contract.register.address).not_to be_nil
      expect(contract.register.meter).not_to be_nil
      expect(contract.old_supplier_name).to be_nil
      expect(contract.old_customer_number).to be_nil
      expect(contract.old_account_number).to be_nil
      expect(contract.forecast_kwh_pa).to eq 1000

      customer = contract.customer
      expect(customer).to eq user
      expect(customer.provider_permission.nil?).to eq false
      expect(customer.address).not_to eq contract.register.address
      expect(customer.bank_account).not_to be_nil

      contractor = contract.contractor
      expect(contractor).to eq(Organization.buzzn_energy)

      tariff = contract.tariffs.first
      expect(tariff.energyprice_cents_per_kwh).to eq 2630.0
      expect(tariff.baseprice_cents_per_month).to eq 1150

      payment = contract.payments.first
      expect(payment.price_cents).to eq 3342
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
      expect(contract.register).not_to be_nil
      expect(contract.register.address).not_to be_nil
      expect(contract.register.meter).not_to be_nil
      expect(contract.old_supplier_name).to be_nil
      expect(contract.old_customer_number).to be_nil
      expect(contract.old_account_number).to be_nil
      expect(contract.forecast_kwh_pa).to eq 1000

      customer = contract.customer
      expect(customer.provider_permission.nil?).to eq false
      expect(customer.address).to eq contract.register.address
      expect(customer.class).to eq Organization
      expect(customer.bank_account).not_to be_nil

      contractor = contract.contractor
      expect(contractor).to eq(Organization.buzzn_energy)

      tariff = contract.tariffs.first
      expect(tariff.energyprice_cents_per_kwh).to eq 2560.0
      expect(tariff.baseprice_cents_per_month).to eq 1170

      payment = contract.payments.first
      expect(payment.price_cents).to eq 3303
    end


    it 'creates old contract, natural_person, same address for existing user' do
      params = {}
      params.merge!(address)
      params.merge!(meter)
      params.merge!(register)
      params.merge!(contracting_party)
      params.merge!(bank_account)
      expect { subject.create_power_taker_contract(user, params) }.to raise_error Buzzn::ValidationError

      first_contract[:contract].merge!(old_contract)
      expect { subject.create_power_taker_contract(user, params.merge(first_contract)) }.to raise_error Buzzn::ValidationError

      params.merge!(second_contract)
      params[:contract].merge!(old_contract)
      contract = subject.create_power_taker_contract(user, params)

      expect(contract.valid?).to be true
      expect(contract.register).not_to be_nil
      expect(contract.register.address).not_to be_nil
      expect(contract.register.meter).not_to be_nil
      expect(contract.old_supplier_name).not_to be_nil
      expect(contract.old_customer_number).not_to be_nil
      expect(contract.old_account_number).not_to be_nil
      expect(contract.forecast_kwh_pa).to eq 1000

      customer = contract.customer
      expect(customer).to eq user
      expect(customer.provider_permission.nil?).to eq false
      expect(customer.address).to eq contract.register.address
      expect(customer.bank_account).not_to be_nil

      contractor = contract.contractor
      expect(contractor).to eq(Organization.buzzn_energy)

      tariff = contract.tariffs.first
      expect(tariff.energyprice_cents_per_kwh).to eq 2560.0
      expect(tariff.baseprice_cents_per_month).to eq 1170

      payment = contract.payments.first
      expect(payment.price_cents).to eq 3303
    end

  end
end
