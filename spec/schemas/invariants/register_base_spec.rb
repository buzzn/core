require 'buzzn/schemas/invariants/register/substitute'

describe 'Schemas::Invariants::Register::Base' do

  entity(:register) { create(:register, :real, :with_market_location) }
  entity!(:localpool) { register.group }

  subject { register.reload.invariant.errors[:group] }

  context 'success' do
    before { register.market_location.update(group: localpool) }
    it { is_expected.to be_nil }
  end
  context 'failure' do
    before { register.market_location.update(group: create(:localpool)) }
    it { is_expected.to eq(['BUG: group and deep nested group must match']) }
  end

end
