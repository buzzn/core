FactoryGirl.definition_file_paths = %w(db/factories)

describe "Factories produce valid records" do

  matcher :have_association do |association_accessor, association_klass|
    match do |actual|
      actual.send(association_accessor).is_a?(association_klass)
    end
  end

  context "Account" do
    subject { create(:account, password: "Helloworld") }
    it { is_expected.to be_valid }
    it "has the same email as the person it belongs to" do
      expect(subject.email).to eq(subject.person.email)
    end
    it "has set the password correctly" do
      password_record = Account::PasswordHash.find_by(account: subject)
      actual          = BCrypt::Password.new(password_record.password_hash)
      expect(actual).to eq("Helloworld")
    end
  end

  context "Address" do
    subject { create(:address) }
    it { is_expected.to be_valid }
  end

  context "Energy classification" do
    subject { create(:energy_classification) }
    it { is_expected.to be_valid }
    it { is_expected.to have_association(:organization, Organization) }
  end

  context "Bank account" do
    subject { create(:bank_account) }
    it { is_expected.to be_valid }
    it { is_expected.to have_association(:contracting_party, Person) }
    it "sets the holder to the name of the contracting_party's account" do
      expect(subject.holder).to eq(subject.contracting_party.name)
    end
  end

  context "Contract" do
    subject { create(:contract) }
    it { is_expected.to be_valid }
    it { is_expected.to have_association(:localpool, Group::Localpool) }
    it { is_expected.to have_association(:contractor, Organization) }
    it { is_expected.to have_association(:contractor_bank_account, BankAccount) }
    it { is_expected.to have_association(:customer, Person) }
    it { is_expected.to have_association(:customer_bank_account, BankAccount) }
    it "has correctly generated contract numbers" do
      expect(subject.contract_number).to be >= 90_000
      expect(subject.contract_number).to be <= 100_000
    end
    context "powertaker contract" do
      subject { create(:contract, :localpool_powertaker) }
      describe "customer" do
        it "has a customer named Powertaker" do
          expect(subject.customer.last_name).to match(/^Powertaker/)
        end
        it "has a customer with a bank_account" do
          expect(subject.customer.bank_accounts.size).to be >= 1
        end
      end
      describe "register" do
        it { is_expected.to have_association(:register, Register::Input) }
      end
    end
  end

  context "Device" do
    subject { create(:device) }
    it { is_expected.to be_valid }
    it { is_expected.to have_association(:register, Register::Input) }
  end

  context "FormulaPart" do
    subject { create(:formula_part) }
    it { is_expected.to be_valid }
    it { is_expected.to have_association(:register, Register::Input) }
    it { is_expected.to have_association(:operand, Register::Input) }
  end

  context "Localpool" do
    subject { create(:localpool) }
    it { is_expected.to be_valid }
  end

  context "Meter::Real" do
    subject { create(:meter_real) }
    it { is_expected.to be_valid }
    it { is_expected.to have_association(:group, Group::Localpool) }
    it "has a register" do
      expect(subject.registers.first).to be_instance_of(Register::Input)
    end
    it "creates a register that belongs to the same group" do
      meter    = create(:meter_real)
      expect(meter.registers.first.group).to eq(meter.group)
    end
    it "can override registers" do
      register = create(:register, :input)
      meter    = create(:meter_real, registers: [register])
      expect(meter.registers).to eq([register])
      expect(meter).to be_valid
    end
  end

  context "Organization" do
    subject { create(:organization) }
    it { is_expected.to be_valid }
    it { is_expected.to have_association(:contact, Person) }
    context "Trait with bank_account" do
      subject { create(:organization, :with_bank_account) }
      it "has a bank_account" do
        expect(subject.bank_accounts.size).to eq(1)
      end
    end
  end

  context "Payment" do
    subject { create(:payment) }
    it { is_expected.to be_valid }
  end

  context "Person" do
    subject { create(:person) }
    it { is_expected.to be_valid }
    it { is_expected.to have_association(:address, Address) }
    it { expect(subject.bank_accounts).to be_empty }
    context "Trait with bank_account" do
      subject { create(:person, :with_bank_account) }
      it "has a bank_account" do
        expect(subject.bank_accounts.size).to eq(1)
      end
    end
  end

  context "Prices" do
    subject { create(:price) }
    it { is_expected.to be_valid }
    it { is_expected.to have_association(:localpool, Group::Localpool) }
  end

  context "Reading" do
    subject { create(:reading) }
    it { is_expected.to be_valid }
  end

  context "Register::Input" do
    subject { create(:register, :input) }
    it { is_expected.to be_valid }
    it { is_expected.to have_association(:group, Group::Localpool) }
    it { is_expected.to have_association(:meter, Meter::Real) }
    it "can override meter" do
      meter    = create(:meter_real)
      register = create(:register, :input, meter: meter)
      expect(register.meter).to eq(meter)
      expect(register).to be_valid
      meter.reload
      expect(meter.registers.size).to eq(2)
    end
  end

  context "Tariff" do
    subject { create(:tariff) }
    it { is_expected.to be_valid }
    it { is_expected.to have_association(:contracts, Contract::Base) }
  end
end