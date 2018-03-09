require 'buzzn/schemas/invariants/register/substitute'

describe 'Schemas::Invariants::Register::Substitute' do

  entity(:group) { create(:localpool) }
  entity(:first) { create(:register, :substitute) }

  subject { register.invariant.errors[:group] }

  context 'success' do
    context 'without market_location' do
      let(:register) { first }
      it { is_expected.to be_nil }
      context 'with market_location' do
        before { create(:market_location, register: register) }
        it { is_expected.to be_nil }
        context 'failure' do
          before { create(:register, :substitute, meter: build(:meter, :virtual, group: register.meter.group)) }
          it {is_expected.to eq(['there can be only one substitute register per group']) }
        end
      end
    end
  end
end
