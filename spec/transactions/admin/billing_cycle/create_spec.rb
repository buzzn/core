require 'buzzn/transactions/admin/billing_cycle/create'

describe Transactions::Admin::BillingCycle::Create do

  entity!(:localpool) { create(:localpool) }

  let(:account)            { Account::Base.where(person_id: user).first }
  let(:localpool_resource) { Admin::LocalpoolResource.all(account).first }

  entity(:member)   { create(:person, :with_account, :with_self_role, roles: { Role::GROUP_MEMBER => localpool }) }
  entity(:operator) { create(:person, :with_account, :with_self_role, roles: { Role::BUZZN_OPERATOR => nil }) }

  let(:input) { {name: 'route-66', last_date: Date.today - 5.day} }

  subject(:transaction) { Transactions::Admin::BillingCycle::Create.for(localpool_resource) }

  context 'authorize' do

    let(:user) { member }

    it 'fails' do
      expect { transaction.call(input) }.to raise_error Buzzn::PermissionDenied
    end

  end

  context 'first call' do

    let(:user) { operator }

    it 'succeeds' do
      result = transaction.call(input)
      expect(result).to be_a Dry::Monads::Either::Right
      expect(result.value).to be_a Admin::BillingCycleResource
      expect(result.value.object).to eq(localpool.billing_cycles.first)
      expect(result.value.begin_date).to eq(localpool.start_date)
    end

    context 'second call' do

      it 'fails' do
        expect { transaction.call(input) }.to raise_error Buzzn::ValidationError
      end

      context 'when last date is different' do
        let(:new_input) { input.merge(last_date: Date.today - 1.day) }

        it 'succeeds' do
          result = transaction.call(new_input)
          expect(result).to be_a Dry::Monads::Either::Right
          expect(result.value).to be_a Admin::BillingCycleResource
          expect(result.value.object).to eq(localpool.billing_cycles.last)
          expect(result.value.begin_date).to eq(localpool.billing_cycles.first.end_date)
        end
      end
    end
  end
end
