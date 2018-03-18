require 'buzzn/transactions/admin/billing_cycle/create'

describe Transactions::Admin::BillingCycle::Create do

  entity!(:localpool) { create(:localpool) }

  let(:account)            { Account::Base.where(person_id: user).first }
  let(:localpool_resource) { Admin::LocalpoolResource.all(account).first }

  entity(:member)   { create(:person, :with_account, :with_self_role, roles: { Role::GROUP_MEMBER => localpool }) }
  entity(:operator) { create(:person, :with_account, :with_self_role, roles: { Role::BUZZN_OPERATOR => nil }) }

  let(:input) { {name: 'route-66', last_date: Date.today - 5.day} }

  subject(:transaction) { Transactions::Admin::BillingCycle::Create.for(localpool_resource) }

  describe 'authorization' do

    let(:user) { member }

    it 'fails' do
      expect { transaction.call(input) }.to raise_error Buzzn::PermissionDenied
    end
  end

  describe 'repeated calls' do
    context 'first call' do

      let(:user) { operator }

      it 'succeeds' do
        result = transaction.call(input)
        expect(result).to be_success
        expect(result.value).to be_a Admin::BillingCycleResource
        expect(result.value.object).to eq(localpool.billing_cycles.first)
        expect(result.value.begin_date).to eq(localpool.start_date)
      end

      context 'second call' do

        it 'fails', :skip do
          expect { transaction.call(input) }.to raise_error Buzzn::ValidationError
        end

        context 'when last date is different' do
          let(:new_input) { input.merge(last_date: Date.today - 1.day) }

          it 'succeeds' do
            result = transaction.call(new_input)
            expect(result).to be_success
            expect(result.value).to be_a Admin::BillingCycleResource
            billing_cycle_model = result.value.object
            expect(billing_cycle_model).to eq(localpool.billing_cycles.last)
            expect(billing_cycle_model.date_range).to eq(localpool.billing_cycles.last.date_range)
          end
        end
      end
    end
  end

  describe 'generating bricks' do
    let(:user)      { operator }
    let!(:contract) { create(:contract, :localpool_powertaker, begin_date: (Date.today - 10.years)) }

    before     { BillingCycle.destroy_all }
    before     { localpool.market_locations << contract.market_location }
    after      { BillingCycle.destroy_all }

    it 'works' do
      result = transaction.call(input)
      expect(result).to be_success
      billing_cycle = result.value.object
      billings      = result.value.object.billings

      expect(billings.count).to eq(1)
      expect(billings.first).to have_attributes(
        date_range: billing_cycle.date_range,
        status:     'open',
        contract:   contract
      )
    end

  end

end
