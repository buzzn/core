require 'buzzn/transactions/admin/billing_cycle/read_billings'

describe Transactions::Admin::BillingCycle::ReadBillings do

  entity(:register)       { create(:register, :consumption) }
  entity(:localpool)      { register.meter.group }
  entity!(:billing_cycle) { create(:billing_cycle, localpool: localpool, date_range: Date.parse('2000-1-1')...Date.today) }
  entity(:operator)       { create(:person, :with_account, :with_self_role, roles: { Role::BUZZN_OPERATOR => nil }) }
  entity(:account)        { Account::Base.where(person_id: operator).first }

  entity(:billing_cycle_resource) { Admin::LocalpoolResource.all(account).first.billing_cycles.first }
  entity(:transaction) { Transactions::Admin::BillingCycle::ReadBillings.for(billing_cycle_resource) }

  context 'result' do
    subject { transaction.call(billing_cycle_resource) }

    context 'without market_location' do
      it { is_expected.to be_success }
      it { expect(subject.value[:array]).to be_empty }
    end

    context 'with market_location' do
      entity(:market_location) { create(:market_location, group: localpool, register: register) }
      let(:first_location)     { subject.value[:array].first }

      context 'without billing' do
        it { is_expected.to be_success }
        it { expect(first_location.keys).to eq(%i(id type name bars)) }
      end

      context 'with billing' do

        entity!(:contract) { create(:contract, :localpool_powertaker, market_location: market_location) }
        entity!(:billing)  { create(:billing, contract: contract, billing_cycle: billing_cycle) }
        entity!(:billing_item)  { create(:billing_item, billing: billing, contract_type: :power_taker) }

        let(:expected_bar_keys) do
          %w(billing_id contract_type begin_date end_date status consumed_energy_kwh price_cents errors)
        end
        it { is_expected.to be_success }
        it { expect(first_location.keys).to eq(%i(id type name bars)) }

        it { expect(first_location[:bars][:array].first.keys).to eq(expected_bar_keys) }

        context 'with errors' do
          it 'JSON has all errors and messages' do
            errors = first_location[:bars][:array].first['errors']
            expect(errors).to eq(
              'begin_reading' => ['begin_reading must be filled'],
              'end_reading' => ['end_reading must be filled'],
              'tariff' => ['tariff must be filled']
            )
          end
        end

      end
    end
  end
end
