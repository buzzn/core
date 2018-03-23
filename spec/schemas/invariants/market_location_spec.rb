require 'buzzn/schemas/invariants/register/substitute'

describe 'Schemas::Invariants::MarketLocation' do

  entity(:market_location) { create(:market_location, register: :consumption) }
  entity!(:localpool) { market_location.group }

  subject { market_location.invariant.errors[:group] }

  context 'success' do
    before { market_location.update(group: localpool) }
    it { is_expected.to be_nil }
  end
  context 'failure' do
    before { market_location.update(group: create(:localpool)) }
    it { is_expected.to eq(['BUG: group and deep nested group must match']) }
  end

end
