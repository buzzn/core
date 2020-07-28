require 'buzzn/schemas/invariants/billing'

describe 'Schemas::Invariants::Billing' do

  let(:localpool) { create(:group, :localpool) }
  let(:contract) { create(:contract, :localpool_powertaker, localpool: localpool) }
  let(:billing) { create(:billing, contract: contract) }

  context 'without billing-cycle' do

    subject { billing.invariant.errors[:localpool] }

    it { is_expected.to be_nil }

    context 'with billing-cycle' do

      let!(:cycle) { create(:billing_cycle, localpool: localpool) }
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
        it { is_expected.to eq(['group and deep nested group must match']) }
      end
    end
  end

  context 'without billing items' do

    subject { billing.invariant.errors[:items_present] }
    context 'not void' do
      it { is_expected.to eq(['there must be at least one billing item present']) }
    end

    context 'void' do
      before do
        billing.status = :void
        billing.save
      end

      it { is_expected.to be_nil }
    end

    context 'with one billing item' do
      subject { billing.invariant.errors[:items] }
      let!(:item) do
        item = create(:billing_item, billing: billing, begin_date: billing.begin_date - 2.day, end_date: billing.end_date + 1.day)
        billing.reload
        item
      end
      it { is_expected.to eq(["all billing items must begin after #{billing.begin_date}"]) }
      context 'covers begin' do
        before { billing.items.first.update(begin_date: billing.begin_date) }
        it { is_expected.to eq(["all billing items must end before #{billing.end_date}"]) }

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
