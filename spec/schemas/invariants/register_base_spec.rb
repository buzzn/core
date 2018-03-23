require 'buzzn/schemas/invariants/register/substitute'

describe 'Schemas::Invariants::Register::Base' do

  entity(:register) { create(:register, :real, :with_market_location) }
  entity!(:localpool) { register.group }

  context 'group' do

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

  context 'readings' do

    subject { register.reload.invariant.errors[:readings] }

    it { is_expected.to be_nil }

    context 'monoton increasing' do
      entity!(:reading) do
        create(:reading, register: register, date: Date.new(2017, 1, 1), value: 100)
        create(:reading, register: register, date: Date.new(2017, 2, 1), value: 200)
        create(:reading, register: register, date: Date.new(2017, 3, 1), value: 300)
      end

      it { is_expected.to be_nil }

      context 'not monoton increasing' do
        before { reading.update_columns(date: Date.new(2016, 12, 1)) }

        it { is_expected.to eq(['must grow in time']) }
      end
    end
  end
end