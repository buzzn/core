require 'buzzn/schemas/invariants/billing'

describe 'Schemas::Invariants::Billing' do

  entity(:localpool) { create(:localpool) }
  entity(:contract) { create(:contract, :localpool_powertaker, localpool: localpool) }
  entity(:billing) { create(:billing, contract: contract) }

  subject { billing.invariant.errors[:localpool] }

  context 'without billing-cycle' do

    it { is_expected.to be_nil }

    context 'with billing-cycle' do

      entity!(:cycle) { create(:billing_cycle, localpool: localpool) }
      before { cycle.billings << billing }
      context 'group matches' do
        before do
          contract.update(localpool: cycle.localpool)
          billing.contract.reload
        end
        it { is_expected.to be_nil }
      end
      context 'group mismatch' do
        before do
          contract.update(localpool: create(:localpool))
          billing.contract.reload
        end
        it { is_expected.to eq(['BUG: group and deep nested group must match']) }
      end
    end
  end
end
