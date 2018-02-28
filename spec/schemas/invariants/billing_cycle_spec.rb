require 'buzzn/schemas/invariants/billing_cycle'

describe 'Schemas::Invariants::BillingCycle' do

  entity(:cycle) { BillingCycle.new(name: 'first', begin_date: Date.parse('2011-1-1')) }

  subject { cycle.invariant.errors[:last_date] }

  context 'last_date' do
    context 'valid' do
      before { cycle.end_date = Date.parse('2012-1-1') }
      it { is_expected.to be_nil }
    end
    context 'before begin_date' do
      before { cycle.end_date = cycle.begin_date }
      it { expect(cycle.begin_date).to be > cycle.last_date }
      it { is_expected.to eq(['must be after begin_date']) }
    end
    context 'equals begin_date' do
      before { cycle.end_date = cycle.begin_date + 1.day }
      it { expect(cycle.begin_date).to eq(cycle.last_date) }
      it { is_expected.to be_nil }
    end
    context 'today' do
      before { cycle.end_date = Date.today }
      it { is_expected.to be_nil }
    end
    context 'after today' do
      before { cycle.end_date = Date.today + 1.day }
      it { is_expected.to eq(['must not be in the future']) }
    end
  end
end
