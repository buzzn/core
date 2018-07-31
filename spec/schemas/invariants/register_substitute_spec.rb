require 'buzzn/schemas/invariants/register/substitute'

describe 'Schemas::Invariants::Register::Substitute' do

  entity(:group) { create(:group, :localpool) }
  entity(:first) { create(:register, :substitute) }

  subject { register.invariant.errors[:group] }

  context 'success' do
    let(:register) { first }
    it { is_expected.to be_nil }
    context 'failure' do
      before { create(:register, :substitute, meter: build(:meter, :virtual, group: register.meter.group)) }
      it {is_expected.to eq(['there can be only one substitute register per group']) }
    end
  end
end
