require 'buzzn/schemas/invariants/billing'

describe 'Schemas::Invariants::BillingItem' do

  let(:localpool) { create(:group, :localpool) }
  let(:contract) { create(:contract, :localpool_powertaker, localpool: localpool) }
  let(:billing) { create(:billing, contract: contract) }
  let(:register) { create(:register, :real, :consumption) }
  let(:reading_1) { create(:reading, register: register, date: item.begin_date) }
  let(:reading_2) { create(:reading, register: register, date: item.end_date) }

  let!(:item) do
    create(:billing_item, billing: billing, date_range: (billing.begin_date + 1.day)...(billing.end_date - 1.day))
  end

  context 'contract' do

    subject { item.invariant.errors[:contract] }

    it { is_expected.to be_nil }

    context 'ends before billing item' do
      before { item.contract.update(end_date: item.end_date - 1.day) }
      it { is_expected.to eq(['contract must be inside time period']) }

      context 'begins after billing item' do
        before { item.contract.update(end_date: item.end_date, begin_date: item.begin_date + 1.day) }
        it { is_expected.to eq(['contract must be inside time period']) }

        context 'inside billing item' do
          before { item.contract.update(end_date: item.end_date + 1.day, begin_date: item.begin_date - 1.day) }
          it do
            is_expected.to be_nil
          end

          context 'open end' do
            before { item.contract.update(end_date: nil, begin_date: item.begin_date - 1.day) }
            it { is_expected.to be_nil }
          end
        end
      end
    end
  end

  context 'tariff' do

    subject { item.invariant.errors[:tariff] }

    it { is_expected.to eq(['must be filled']) }

    context 'alien' do
      before { item.update(tariff: create(:tariff)) }
      it { is_expected.to eq(['tariff must be in contract tariffs']) }

      context 'filled' do
        let!(:tariff) do
          tariff = create(:tariff, group: localpool)
          contract.tariffs = [tariff]
          tariff
        end
        before { item.update(tariff: tariff) }
        it { is_expected.to be_nil }
      end
    end
  end

  context 'register' do

    subject { item.invariant.errors[:register] }

    it { is_expected.to be_nil }

    context 'not from contract' do
      before { item.update(register: register) }

      it { is_expected.to eq(['register must belong to contract']) }

      context 'from contract' do
        before { item.update(register: billing.contract.register_meta.register) }

        it { is_expected.to be_nil }
      end
    end
  end

  context 'begin reading' do

    subject { item.invariant.errors[:begin_reading] }

    it { is_expected.to be_nil }
    it('not set') { expect(item.begin_reading).to be_nil }

    context 'incorrect readings' do
      before do
        reading_1.update_columns(register_id: item.register.id)
        reading_2.update_columns(register_id: item.register.id)
        item.update(begin_reading: reading_1, end_reading: reading_2)
      end

      context 'begin_reading is higher than end_reading' do

        let(:reading_1) { create(:reading, register: register, date: item.begin_date, raw_value: 200) }
        let(:reading_2) { create(:reading, register: register, date: item.end_date,   raw_value: 100) }

        it { is_expected.to eq(['begin_reading needs to be lower than end_reading']) }
      end

    end

    context 'mismatching register' do
      before { reading_1.update_columns(register_id: register.id) }
      before { item.update(begin_reading: reading_1) }

      it { is_expected.to eq(['must match register']) }

      context 'matching register' do
        before { reading_1.update_columns(register_id: item.register.id) }

        it { is_expected.to be_nil }

      end
    end
  end

  context 'already_present' do

    #     |xxxxxxx|
    # |zzzzzzz|

    context 'overlaps partly I' do

      let!(:another_item) do
        build(:billing_item, billing: billing, date_range: (billing.begin_date - 10.day)...(billing.begin_date + 10.day))
      end

      it 'produces an error' do
        expect(another_item.invariant.errors[:no_other_billings_in_range]).to eq(['other billing items already exist in this time range'])
      end

    end

    #     |xxxxxxx|
    # |zzzzzzzzzzz|

    context 'overlaps partly II' do

      let!(:another_item) do
        build(:billing_item, billing: billing, date_range: (billing.begin_date - 10.day)...(billing.end_date - 1.day))
      end

      it 'produces an error' do
        expect(another_item.invariant.errors[:no_other_billings_in_range]).to eq(['other billing items already exist in this time range'])
      end

    end

    # |xxxxxxx|
    # |zzzzzzzzzzz|

    context 'overlaps partly III' do

      let!(:another_item) do
        build(:billing_item, billing: billing, date_range: (billing.begin_date + 1.day)...(billing.end_date - 10.day))
      end

      it 'produces an error' do
        expect(another_item.invariant.errors[:no_other_billings_in_range]).to eq(['other billing items already exist in this time range'])
      end

    end

    # |xxxxxxx|
    #     |zzzzzzzzzzz|

    context 'overlaps partly III' do

      let!(:another_item) do
        build(:billing_item, billing: billing, date_range: (billing.begin_date + 10.day)...(billing.end_date + 10.day))
      end

      it 'produces an error' do
        expect(another_item.invariant.errors[:no_other_billings_in_range]).to eq(['other billing items already exist in this time range'])
      end

    end

    # |xxxxxxx|
    # |zzzzzzz|

    context 'overlaps completely' do

      let!(:another_item) do
        build(:billing_item, billing: billing, date_range: (billing.begin_date + 1.day)...(billing.end_date - 1.day))
      end

      it 'produces an error' do
        expect(another_item.invariant.errors[:no_other_billings_in_range]).to eq(['other billing items already exist in this time range'])
      end

    end

    # |xxxxxx|
    #         |zzzzzzz|

    context 'does not overlap I' do
      let!(:another_item) do
        build(:billing_item, billing: billing, date_range: (billing.end_date)...(billing.end_date + 10.day))
      end

      it 'does not produce error' do
        expect(another_item.invariant.errors[:no_other_billings_in_range]).to be_nil
      end
    end

    #          |xxxxxx|
    # |zzzzzzz|

    context 'does not overlap I' do
      let!(:another_item) do
        build(:billing_item, billing: billing, date_range: (billing.begin_date - 10.day)...(billing.begin_date))
      end

      it 'does not produce error' do
        expect(another_item.invariant.errors[:no_other_billings_in_range]).to be_nil
      end
    end

  end

  context 'end reading' do

    subject { item.invariant.errors[:end_reading] }

    it { is_expected.to be_nil }
    it('not set') { expect(item.end_reading).to be_nil }

    context 'mismatching register' do
      before { reading_2.update_columns(register_id: register.id) }
      before { item.update(end_reading: reading_2) }

      it { is_expected.to eq(['must match register']) }

      context 'matching register' do
        before { reading_2.update_columns(register_id: item.register.id) }

        it { is_expected.to be_nil }

      end
    end
  end
end
