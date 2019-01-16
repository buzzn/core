require 'buzzn/schemas/invariants/reading/single'

describe 'Schemas::Invariants::Reading::Single' do

  let(:register) { create(:register, :real, :consumption) }
  let(:today) { Date.today }
  #let(:reading_1) { create(:reading, register: register, date: today) }

  context 'value' do

    let(:item) { create(:reading, register: register, date: today, value: 777) }
    subject { item.invariant.errors[:value] }

    context 'has no previous' do
      it { is_expected.to be_nil }
    end

    context 'has a previous' do

      context 'which is equal' do
        let!(:previous_item) { create(:reading, register: register, date: today-1, value: 777) }
        it do
          item.reload
          is_expected.to be_nil
        end
      end

      context 'which is lower' do
        let!(:previous_item) { create(:reading, register: register, date: today-1, value: 555) }
        it do
          item.reload
          is_expected.to be_nil
        end
      end

      context 'which is higher' do
        let!(:previous_item) { create(:reading, register: register, date: today-1, value: 999) }
        it do
          item.reload
          is_expected.to eql ['reading must be higher than previous']
        end
      end
    end

  end

end
