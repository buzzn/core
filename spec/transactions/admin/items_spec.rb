require 'buzzn/transactions/admin/billing_cycle/items'

describe Transactions::Admin::BillingCycle::Items do

  entity(:localpool)      { create(:localpool) }
  entity(:register)       { create(:register, :consumption) }
  entity!(:billing_cycle) { create(:billing_cycle, localpool: localpool, begin_date: Date.parse('2000-1-1'), end_date: Date.today) }
  entity(:operator)       { create(:person, :with_account, :with_self_role, roles: { Role::BUZZN_OPERATOR => nil }) }
  entity(:account)        { Account::Base.where(person_id: operator).first }

  entity(:billing_cycle_resource) { Admin::LocalpoolResource.all(account).first.billing_cycles.first }
  entity(:transaction) { Transactions::Admin::BillingCycle::Items.for(billing_cycle_resource) }

  context 'result' do
    subject { transaction.call(billing_cycle_resource) }

    context 'without market_location' do

      it { is_expected.to be_a(Dry::Monads::Either::Right) }
      it { expect(subject.value[:array]).to be_empty }

      context 'with market_location without items' do

        let(:first_location) { subject.value[:array].first }

        entity!(:market_location) { create(:market_location, group: localpool, register: register) }
        it { is_expected.to be_a(Dry::Monads::Either::Right) }
        it { expect(first_location.keys).to eq(%i(id type name items)) }

        context 'with item' do

          entity!(:contract) { create(:contract, :localpool_powertaker, market_location: market_location) }
          let(:expected_item_keys) do
            %w(contract_type begin_date end_date status consumed_energy_kwh price_cents errors)
          end
          it { is_expected.to be_a(Dry::Monads::Either::Right) }
          it { expect(first_location.keys).to eq(%i(id type name items)) }

          it { expect(first_location[:items][:array].first.keys).to eq(expected_item_keys) }

          context 'with errors' do
            it 'JSON has all errors and messages' do
              errors = first_location[:items][:array].first['errors']
              expect(errors).to eq(
                'begin_reading' => ['must be filled'],
                'end_reading' => ['must be filled'],
                'tariff' => ['must be filled']
              )
            end
          end

        end
      end
    end
  end
end