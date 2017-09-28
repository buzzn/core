describe "Fabricators produce valid records" do

  context "Device" do
    subject { Fabricate(:new_device) }
    it { is_expected.to be_valid }
  end

  context "Localpool" do
    subject { Fabricate(:new_localpool) }
    it { is_expected.to be_valid }
  end
end