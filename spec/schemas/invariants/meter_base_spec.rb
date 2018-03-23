require 'buzzn/schemas/invariants/register/substitute'

describe 'Schemas::Invariants::Meter::Base' do

  entity(:localpool) { create(:localpool) }

  subject { meter.invariant.errors[:group] }

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
