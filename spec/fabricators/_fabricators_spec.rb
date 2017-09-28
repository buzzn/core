describe "Fabricators produce valid records" do

  matcher :have_association do |association_accessor, association_klass|
    match do |actual|
      actual.send(association_accessor).instance_of?(association_klass)
    end
  end

  context "Address" do
    subject { Fabricate(:new_address) }
    it { is_expected.to be_valid }
  end

  context "Energy classification" do
    subject { Fabricate(:new_energy_classification) }
    it { is_expected.to be_valid }
  end

  context "Bank account" do
    subject { Fabricate(:new_bank_account) }
    it { is_expected.to be_valid }
    it { is_expected.to have_association(:contracting_party, Person) }
  end

  context "Device" do
    subject { Fabricate(:new_device) }
    it { is_expected.to be_valid }
    it { is_expected.to have_association(:register, Register::Input) }
  end

  context "FormulaPart" do
    subject { Fabricate(:new_formula_part) }
    it { is_expected.to be_valid }
    it { is_expected.to have_association(:register, Register::Input) }
    it { is_expected.to have_association(:operand, Register::Input) }
  end

  context "Localpool" do
    subject { Fabricate(:new_localpool) }
    it { is_expected.to be_valid }
  end

  context "Meter::Real" do
    subject { Fabricate(:new_meter_real) }
    it { is_expected.to be_valid }
    it { is_expected.to have_association(:group, Group::Localpool) }
    it "has a register" do
      expect(subject.registers.first).to be_instance_of(Register::Input)
    end
    it "can override registers" do
      register = Fabricate(:new_register_input)
      meter    = Fabricate(:new_meter_real, registers: [register])
      expect(meter.registers).to eq([register])
      expect(meter).to be_valid
    end
  end

  context "Person" do
    subject { Fabricate(:new_person) }
    it { is_expected.to be_valid }
    it { is_expected.to have_association(:address, Address) }
  end

  context "Reading" do
    subject { Fabricate(:new_reading) }
    it { is_expected.to be_valid }
  end

  context "Register::Input" do
    subject { Fabricate(:new_register_input) }
    it { is_expected.to be_valid }
    it { is_expected.to have_association(:group, Group::Localpool) }
    it { is_expected.to have_association(:meter, Meter::Real) }
    it "can override meter" do
      meter    = Fabricate(:new_meter_real)
      register = Fabricate(:new_register_input, meter: meter)
      expect(register.meter).to eq(meter)
      expect(register).to be_valid
      meter.reload
      expect(meter.registers.size).to eq(2)
    end
  end
end