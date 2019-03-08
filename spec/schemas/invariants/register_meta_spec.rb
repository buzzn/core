require 'buzzn/schemas/invariants/register/base'

describe 'Schemas::Invariants::Register::Meta' do

  entity(:meta) { create(:meta) }
  subject { meta.invariant.errors }

  context 'valid' do

    it { is_expected.to be_empty }
  end

  context 'invalid' do

    before do
      meta.observer_max_threshold = 4
      meta.observer_min_threshold = 5
    end

    context 'not enabled' do
      before do
        meta.observer_enabled = false
      end

      it { is_expected.to be_empty }
    end

    context 'enabled' do
      before do
        meta.observer_enabled = true
      end

      it 'fails' do
        is_expected.to eql({:observer=>["must be greater than or equal to 5"]})
      end

    end
  end
end
