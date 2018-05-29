require 'buzzn/schemas/invariants/billing'

describe 'Schemas::Invariants::BillingItem' do

  entity(:localpool) { create(:group, :localpool) }
  entity(:contract) { create(:contract, :localpool_powertaker, localpool: localpool) }
  entity(:billing) { create(:billing, contract: contract) }
  entity(:register) { create(:register, :consumption) }
  entity(:reading) { create(:reading, register: register) }

  entity!(:item) do
    create(:billing_item, billing: billing, date_range: (billing.begin_date + 1.day)...(billing.end_date - 1.day))
  end

  context 'contract' do

    subject { item.invariant.errors[:contract] }

    it { is_expected.to be_nil }

    context 'ends before billing item' do
      before { item.contract.update(end_date: item.end_date - 1.day) }
      it { is_expected.to eq(['must inside period']) }

      context 'begins after billing item' do
        before { item.contract.update(end_date: item.end_date, begin_date: item.begin_date + 1.day) }
        it { is_expected.to eq(['must inside period']) }

        context 'inside billing item' do
          before { item.contract.update(end_date: item.end_date + 1.day, begin_date: item.begin_date - 1.day) }
          it { is_expected.to be_nil }

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
      it { is_expected.to eq(['must be in contract tariffs']) }

      context 'filled' do
        entity!(:tariff) do
          tariff = create(:tariff, group: localpool)
          contract.tariffs = [tariff]
          tariff
        end
        before { item.update(tariff: tariff) }
        it { is_expected.to be_nil }

        context 'ends before billing item' do
          before { item.tariff.update_columns(end_date: item.end_date - 1.day) }
          it { is_expected.to eq(['must inside period']) }

          context 'begins after billing item' do
            before { item.tariff.update_columns(end_date: item.end_date, begin_date: item.begin_date + 1.day) }
            it { is_expected.to eq(['must inside period']) }

            context 'inside billing item' do
              before { item.tariff.update_columns(end_date: item.end_date + 1.day, begin_date: item.begin_date - 1.day) }
              it { is_expected.to be_nil }
            end
          end
        end
      end
    end
  end

  context 'register' do

    subject { item.invariant.errors[:register] }

    it { is_expected.to be_nil }

    context 'not from contract' do
      before { item.update(register: register) }

      it { is_expected.to eq(['must belong to contract']) }

      context 'from contract' do
        before { item.update(register: billing.contract.market_location.register) }

        it { is_expected.to be_nil }
      end
    end
  end

  context 'begin reading' do

    subject { item.invariant.errors[:begin_reading] }

    it { is_expected.to be_nil }
    it('not set') { expect(item.begin_reading).to be_nil }

    context 'mismatching register' do
      before { reading.update_columns(register_id: register.id) }
      before { item.update(begin_reading: reading) }

      it { is_expected.to eq(['must match register']) }

      context 'matching register' do
        before { reading.update_columns(register_id: item.register.id) }

        it { is_expected.to be_nil }

      end
    end
  end

  context 'end reading' do

    subject { item.invariant.errors[:end_reading] }

    it { is_expected.to be_nil }
    it('not set') { expect(item.end_reading).to be_nil }

    context 'mismatching register' do
      before { reading.update_columns(register_id: register.id) }
      before { item.update(end_reading: reading) }

      it { is_expected.to eq(['must match register']) }

      context 'matching register' do
        before { reading.update_columns(register_id: item.register.id) }

        it { is_expected.to be_nil }

      end
    end
  end
end
