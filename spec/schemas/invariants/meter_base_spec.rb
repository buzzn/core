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

  subject { meter.invariant.errors[:group] }

  entity(:localpool) { create(:localpool) }

  context 'no meter group' do
    entity(:meter) { create(:meter, :real, group: nil) }
    context 'without market_location' do
      it { is_expected.to be_nil }
      context 'with market_location' do
        before { create(:market_location, register: meter.registers.first, group: localpool) }
        it { is_expected.to be_nil }
      end
    end
  end
  context 'with meter group' do
    entity(:meter) { create(:meter, :real) }
    context 'without market_location' do
      it { is_expected.to be_nil }

      context 'with market_location' do
        entity(:market_location) { create(:market_location, register: meter.registers.first, group: localpool) }

        context 'success' do
          before do
            market_location.update(group: meter.group)
            meter.registers.reload
          end
          it { is_expected.to be_nil }
        end
        context 'failure' do
          before do
            market_location.update(group: localpool)
            meter.registers.reload
          end
          it { is_expected.to eq(['BUG: group and deep nested group must match']) }
        end
      end
    end
  end

end
