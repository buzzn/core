FactoryGirl.definition_file_paths = %w(db/factories)

describe 'Factories produce valid records' do

  matcher :have_association do |association_accessor, association_klass|
    match do |actual|
      actual.send(association_accessor).is_a?(association_klass)
    end
    failure_message do |actual|
      "Expected #{actual.class}##{association_accessor} to contain a #{association_klass}, but it's #{actual.send(association_accessor).inspect}."
    end
  end

  shared_examples 'has valid invariants' do
    it { expect(subject.invariant).to be_success }
  end

  context 'Account' do
    subject { create(:account, password: 'Helloworld') }
    it { is_expected.to be_valid }
    it 'has the same email as the person it belongs to' do
      expect(subject.email).to eq(subject.person.email)
    end
    it 'has set the password correctly' do
      password_record = Account::PasswordHash.find_by(account: subject)
      actual          = BCrypt::Password.new(password_record.password_hash)
      expect(actual).to eq('Helloworld')
    end
  end

  context 'Address' do
    subject { create(:address) }
    it { is_expected.to be_valid }
  end

  context 'Energy classification' do
    subject { create(:energy_classification) }
    it { is_expected.to be_valid }
    it { is_expected.to have_association(:organization, Organization) }
  end

  context 'Bank account' do
    subject { create(:bank_account) }
    it { is_expected.to be_valid }
    it { is_expected.to have_association(:owner, Person) }
    it "sets the holder to the name of the owner's account" do
      expect(subject.holder).to eq(subject.owner.name)
    end
  end

  context 'Contract' do
    subject { create(:contract) }
    it { is_expected.to be_valid }
    it { is_expected.to have_association(:localpool, Group::Localpool) }
    it { is_expected.to have_association(:contractor, Organization) }
    it 'has bank account' do
      is_expected.to have_association(:contractor_bank_account, BankAccount)
    end
    it { is_expected.to have_association(:customer, Person) }
    it { is_expected.to have_association(:customer_bank_account, BankAccount) }
    it 'has correctly generated contract numbers' do
      expect(subject.contract_number).to be >= 90_000
      expect(subject.contract_number).to be <= 100_000
    end
    context 'localpool powertaker contract' do
       subject { create(:contract, :localpool_powertaker) }
      describe 'customer' do
        it 'has a customer named Powertaker' do
          expect(subject.customer.last_name).to match(/^Powertaker/)
        end
        it 'has a customer with a bank_account' do
          expect(subject.customer.bank_accounts.size).to be >= 1
        end
      end
      describe 'market_location' do
        it { is_expected.to have_association(:market_location, MarketLocation) }
      end
      include_examples 'has valid invariants'
     end
    context 'localpool thirdparty' do
      subject { create(:contract, :localpool_third_party) }
      describe 'customer' do
        it 'has no customer' do
          expect(subject.customer).to be_nil
        end
        it 'has no contractor' do
          expect(subject.contractor).to be_nil
        end
      end
      describe 'market_location' do
        it { is_expected.to have_association(:market_location, MarketLocation) }
      end
      include_examples 'has valid invariants'
    end
  end

  context 'Device' do
    subject { create(:device) }
    it { is_expected.to be_valid }
    it { is_expected.to have_association(:localpool, Group::Localpool) }
  end

  context 'FormulaPart' do
    subject { create(:formula_part) }
    it { is_expected.to be_valid }
    it { is_expected.to have_association(:register, Register::Input) }
    it { is_expected.to have_association(:operand, Register::Input) }
  end

  context 'Localpool' do
    subject { create(:group, :localpool) }
    it { is_expected.to have_valid_invariants }
    it { is_expected.to be_valid }
    it { is_expected.not_to have_association(:address, Address) }
    context 'with address' do
      subject { create(:group, :localpool, :with_address) }
      it { is_expected.to have_association(:address, Address) }
    end
  end

  context 'Broker' do
    subject { create(:broker, meter: create(:meter, :real)) }
    it { is_expected.to be_valid }
    it { is_expected.to have_association(:meter, Meter::Real) }
  end

  context 'Meter::Real' do
    subject { create(:meter, :real) }
    it { is_expected.to be_valid }
    it { is_expected.to have_association(:group, Group::Localpool) }
    it 'has a register' do
      expect(subject.registers.first).to be_instance_of(Register::Input)
    end
    it 'can override registers' do
      register = create(:register, :input)
      meter    = create(:meter, :real, registers: [register])
      expect(meter.registers).to eq([register])
      expect(meter).to be_valid
    end
  end

  context 'Organization' do
    subject { create(:organization) }
    it { is_expected.to be_valid }
    it { is_expected.to have_association(:contact, Person) }
    context 'Trait with address' do
      subject { create(:organization, :with_address) }
      it { is_expected.to have_association(:address, Address) }
    end
    context 'Trait with bank_account' do
      subject { create(:organization, :with_bank_account) }
      it 'has a bank_account' do
        expect(subject.bank_accounts.size).to eq(1)
      end
    end
  end

  context 'OrganizationMarketFunction' do
    subject { create(:organization_market_function) }
    it { is_expected.to be_valid }
  end

  context 'Payment' do
    subject { create(:payment) }
    it { is_expected.to be_valid }
  end

  context 'Person' do
    subject { create(:person) }
    it { is_expected.to be_valid }
    it { is_expected.to have_association(:address, Address) }
    it { expect(subject.bank_accounts).to be_empty }
    context 'Trait with address' do
      subject { create(:person, :with_address) }
      it { is_expected.to have_association(:address, Address) }
    end

    context 'Trait with bank_account' do
      subject { create(:person, :with_bank_account) }
      it 'has a bank_account' do
        expect(subject.bank_accounts.size).to eq(1)
      end
    end
  end

  context 'Tariff' do
    subject { create(:tariff) }
    it { is_expected.to be_valid }
    it { is_expected.to have_association(:group, Group::Localpool) }
  end

  context 'Reading' do
    subject { create(:reading) }
    it { is_expected.to be_valid }
  end

  context 'Register' do

    shared_examples 'a valid register' do |expected_meter_class|
      it { is_expected.to be_valid }
      it { is_expected.to have_association(:meter, expected_meter_class.constantize) }
       it 'has a valid and persisted meter' do
        expect(subject.meter).to be_valid
        expect(subject.meter).to be_persisted
      end
    end

    context 'Input' do
      subject { create(:register, :input) }
      include_examples 'a valid register', 'Meter::Real'
      it 'can override meter' do
        # it is not possible to rewire meter and registers and
        # meters and registers can only exists in combination
        meter    = create(:meter, :real)
        register = create(:register, :output, meter: meter)
        expect(register.meter).to eq(meter)
        expect(register).to be_valid
        meter.reload
        expect(meter.registers.size).to eq(2)
      end
    end

    context 'Virtual input' do
      subject { create(:register, :virtual_input) }
      include_examples 'a valid register', 'Meter::Virtual'
    end
  end

  context 'Tariff' do
    subject { create(:tariff) }
    it { is_expected.to be_valid }
    it 'can override group' do
      group    = create(:group, :localpool)
      tariff   = create(:tariff, group: group)
      expect(tariff.group).to eq(group)
      expect(tariff).to be_valid
    end
  end

  context 'BillingItem' do
    context 'item has billing' do
      subject { build(:billing_item) }
      it { is_expected.to be_valid }
      it 'has the same begin and end dates as the billing' do
        expect(subject.begin_date).to eq(subject.billing.begin_date)
        expect(subject.end_date).to eq(subject.billing.end_date)
      end
    end
    context 'item has no billing' do
      subject { build(:billing_item, billing: nil) }
      it { is_expected.to be_valid }
      it 'has a begin and end date' do
        expect(subject.begin_date).to be_instance_of(Date)
        expect(subject.end_date).to be_instance_of(Date)
      end
    end
  end
end
