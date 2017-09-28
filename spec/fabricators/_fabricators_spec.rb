describe "Fabricators produce valid records" do

  context "Device" do
    subject { Fabricate(:new_device) }
    it { is_expected.to be_valid }
    it "has a register" do
      expect(subject.register).to be_instance_of(Register::Input)
    end
  end

  context "Localpool" do
    subject { Fabricate(:new_localpool) }
    it { is_expected.to be_valid }
  end

  context "Register::Input" do
    subject { Fabricate(:new_register_input) }
    it { is_expected.to be_valid }
    it "has a group" do
      expect(subject.group).to be_instance_of(Group::Localpool)
    end
    it "has a meter" do
      expect(subject.meter).to be_instance_of(Meter::Real)
    end
    it "can override meter" do
      meter    = Fabricate(:new_meter_real)
      register = Fabricate(:new_register_input, meter: meter)
      expect(register.meter).to eq(meter)
      expect(register).to be_valid
      meter.reload
      expect(meter.registers.size).to eq(2)
    end
  end

  context "Meter::Real" do
    subject { Fabricate(:new_meter_real) }
    it { is_expected.to be_valid }
    it "has a group" do
      expect(subject.group).to be_instance_of(Group::Localpool)
    end
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
end