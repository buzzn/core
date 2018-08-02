require 'buzzn/transactions/admin/billing_cycle/create'

describe Transactions::Admin::BillingCycle::Create do

  entity!(:localpool) { create(:group, :localpool) }

  let(:account)            { Account::Base.where(person_id: user).first }
  let(:localpool_resource) { Admin::LocalpoolResource.all(account).first }

  entity(:member)   { create(:person, :with_account, :with_self_role, roles: { Role::GROUP_MEMBER => localpool }) }
  entity(:operator) { create(:person, :with_account, :with_self_role, roles: { Role::BUZZN_OPERATOR => nil }) }

  let(:input) { {name: 'route-66', last_date: Date.today - 5.day} }
  let(:future_input) { {name: 'fail0r', last_date: Date.today + 24.day} }

  describe 'authorization' do

    let(:user) { member }

    it 'fails' do
      expect { subject.call(params: input, resource: localpool_resource) }.to raise_error Buzzn::PermissionDenied
    end
  end

  describe 'invalid inputs' do

    let(:user) { operator }

    it 'fails' do
      before_count = localpool.billing_cycles.count
      expect { subject.call(params: future_input, resource: localpool_resource) }.to raise_error Buzzn::ValidationError
      expect(localpool.billing_cycles.count).to eq before_count
    end
  end

  describe 'repeated calls' do
    context 'first call' do

      let(:user) { operator }

      it 'succeeds' do
        result = subject.call(params: input, resource: localpool_resource)
        expect(result).to be_success
        expect(result.value!).to be_a Admin::BillingCycleResource
        expect(result.value!.object).to eq(localpool.billing_cycles.first)
        expect(result.value!.begin_date).to eq(localpool.start_date)
      end

      context 'second call' do

        it 'fails' do
          expect { subject.call(params: input, resource: localpool_resource) }.to raise_error Buzzn::ValidationError
        end

        context 'when last date is different' do
          let(:new_input) { input.merge(last_date: Date.today - 1.day) }

          it 'succeeds' do
            result = subject.call(params: new_input, resource: localpool_resource)
            expect(result).to be_success
            expect(result.value!).to be_a Admin::BillingCycleResource
            billing_cycle_model = result.value!.object
            expect(billing_cycle_model).to eq(localpool.billing_cycles.last)
            expect(billing_cycle_model.date_range).to eq(localpool.billing_cycles.last.date_range)
          end
        end
      end
    end
  end

  describe 'generating bars' do
    let(:user)      { operator }
    let!(:contract) { create(:contract, :localpool_powertaker, begin_date: (Date.today - 10.years), localpool: localpool) }

    before     { BillingCycle.destroy_all }
    after      { BillingCycle.destroy_all }

    it 'works', :skip do
      result = subject.call(params: input, resource: resource)
      expect(result).to be_success
      billing_cycle = result.value!.object
      billings      = result.value!.object.billings

      expect(billings.count).to eq(1)
      expect(billings.first).to have_attributes(
        date_range: billing_cycle.date_range,
        status:     'open',
        contract:   contract
      )
    end

  end

end
