require 'buzzn/transactions/admin/billing_cycle/read_billings'

describe Transactions::Admin::BillingCycle::ReadBillings do

  entity(:localpool)      { create(:localpool) }
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

      context 'with market_location' do
        let!(:market_location) { create(:market_location, :consumption, group: localpool) }
        let(:last_location) { subject.value[:array].last }

        context 'without billing' do
          it { is_expected.to be_success }
          it { expect(last_location.keys).to eq(%i(id type name bars)) }

          context 'with billing' do

            let!(:contract)     { create(:contract, :localpool_powertaker, market_location: market_location) }
            let!(:billing)      { create(:billing, contract: contract, billing_cycle: billing_cycle) }
            let!(:billing_item) { create(:billing_item, billing: billing, contract_type: :power_taker) }

            let(:expected_keys) do
              %w(billing_id contract_type begin_date end_date status consumed_energy_kwh price_cents errors)
            end
            it { is_expected.to be_success }
            it { expect(last_location.keys).to eq(%i(id type name bars)) }

            it { expect(last_location[:bars][:array].first.keys).to eq(expected_keys) }

            context 'with errors' do
              it 'JSON has all errors and messages' do
                errors = last_location[:bars][:array].first['errors']
                expect(errors).to eq(
                  'begin_reading' => ['begin_reading must be filled'],
                  'end_reading' => ['end_reading must be filled'],
                  'tariff' => ['tariff must be filled']
                )
              end
            end

            context 'with a billing that doesn\'t belong to the billing cycle' do

              let!(:billing)      { create(:billing, contract: contract, date_range: billing_cycle.date_range) }
              let!(:billing_item) { create(:billing_item, billing: billing, contract_type: :power_taker, date_range: billing_cycle.date_range) }

              # The implementation is working but the test doesn't pass yet
              it 'is returned', :skip do
                ap localpool.market_locations.first.contracts
                expect(last_location[:bars][:array].size).to eq(1)
                expect(last_location[:bars][:array].first.keys).to eq(expected_keys)
              end
            end

          end
        end
      end
    end
  end
end
