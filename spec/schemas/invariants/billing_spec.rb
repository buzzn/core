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

    it { is_expected.to eq(['must cover begin date']) }

    context 'with one billing item' do
      entity!(:item) do
        create(:billing_item, billing: billing, begin_date: billing.begin_date + 1.day, end_date: billing.end_date - 1.day)
        billing.reload
      end
      it { is_expected.to eq(['must cover begin date']) }
      context 'covers begin' do
        before { billing.items.first.update(begin_date: billing.begin_date) }
        it { is_expected.to eq(['must cover end date']) }

        context 'covers end' do
          before { billing.items.first.update(end_date: billing.end_date) }
          it { is_expected.to be_nil }

          context 'with two billing items' do
            entity!(:second_item) do
              create(:billing_item, billing: billing, begin_date: billing.begin_date + 1.day, end_date: billing.end_date - 1.day)
              billing.reload
            end
            it { is_expected.to eq(['must line up']) }
            context 'lineup' do
              before do
                billing.items.first.update(end_date: billing.begin_date + 1.month)
                billing.items.last.update(begin_date: billing.begin_date + 1.month, end_date: billing.end_date)
              end
              it { is_expected.to be_nil }
              context 'with three billing items' do
                entity!(:second_item) do
                  billings.item.last.update(end_date: billing.end_date - 1.month)
                  create(:billing_item, billing: billing, begin_date: billing.end_date - 1.month, end_date: billing.end_date)
                  billing.reload
                end
                it { is_expected.to be_nil }
              end
            end
          end
        end
      end
    end
  end
end
