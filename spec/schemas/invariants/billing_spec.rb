require 'buzzn/schemas/invariants/billing'

describe 'Schemas::Invariants::Billing' do

  entity(:localpool) { create(:group, :localpool) }
  entity(:contract) { create(:contract, :localpool_powertaker, localpool: localpool) }
  entity(:billing) { create(:billing, contract: contract) }

  context 'without billing-cycle' do

    subject { billing.invariant.errors[:localpool] }

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
          contract.update(localpool: create(:group, :localpool))
          billing.contract.reload
        end
        it { is_expected.to eq(['BUG: group and deep nested group must match']) }
      end
    end
  end

  context 'without billing items' do

    subject { billing.invariant.errors[:items] }

    it { is_expected.to eq(['size cannot be less than 1']) }

    context 'with one billing item' do
      entity!(:item) do
        item = create(:billing_item, billing: billing, begin_date: billing.begin_date - 2.day, end_date: billing.end_date + 1.day)
        billing.reload
        item
      end
      it { is_expected.to eq(["must be after #{billing.begin_date}"]) }
      context 'covers begin' do
        before { billing.items.first.update(begin_date: billing.begin_date) }
        it { is_expected.to eq(["must be before #{billing.end_date}"]) }

        context 'covers end' do
          before { billing.items.first.update(end_date: billing.end_date) }
          it { is_expected.to be_nil }
        end
      end
      context 'billing_items' do
        subject { billing.invariant.errors[:completeness] }
        it 'is incomplete' do
          expect(billing.status).to eql 'open'
          expect(item.begin_reading).to be_nil
          it { is_expected.to eq(['billing_items are not complete and state is not open'])}
        end
      end
    end
  end
end
