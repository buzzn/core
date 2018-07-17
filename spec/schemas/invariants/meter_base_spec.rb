require 'buzzn/schemas/invariants/register/substitute'

describe 'Schemas::Invariants::Meter::Base' do

  context 'discovergy' do
    entity(:meter) { create(:meter, :real, group: nil) }
    subject { meter.invariant.errors[:datasource] }
    before { meter.discovergy! }
    it do
      meter.easy_meter!
      meter.remote!
      is_expected.to be_nil
    end
    it do
      meter.manual!
      is_expected.to eq(['must be equal to standard_profile'])
    end
    context 'edifact_measurement_method' do
      subject { meter.invariant.errors[:edifact_measurement_method] }
      it do
        meter.manual!
        is_expected.to eq(['must be equal to AMR'])
      end
      it do
        meter.remote!
        is_expected.to be_nil
      end
    end
    context 'manufacturer_name' do
      subject { meter.invariant.errors[:manufacturer_name] }
      it do
        meter.other!
        is_expected.to eq(['must be equal to easy_meter'])
      end
      it do
        meter.easy_meter!
        is_expected.to be_nil
      end
    end
  end
  context 'standard_profile' do
    entity(:meter) { create(:meter, :real, group: nil) }
    subject { meter.invariant.errors[:datasource] }
    before { meter.standard_profile! }
    it do
      meter.easy_meter!
      is_expected.to be_nil
      meter.other!
      is_expected.to be_nil
    end
    context 'edifact_measurement_method' do
      subject { meter.invariant.errors[:edifact_measurement_method] }
      it do
        meter.remote!
        is_expected.to eq(['must be equal to MMR'])
      end
      it do
        meter.manual!
        is_expected.to be_nil
      end
    end
    context 'manufacturer_name' do
      subject { meter.invariant.errors[:manufacturer_name] }
      it do
        meter.easy_meter!
        is_expected.to be_nil
        meter.other!
        is_expected.to be_nil
      end
    end
  end

end
