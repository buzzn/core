require 'buzzn/transactions/admin/billing_cycle/create'
require_relative 'shared_entities'

describe Transactions::Admin::BillingCycle::Create do

  include_context 'billing cycle entities'

  before(:all) do
    create(:vat, amount: 0.19, begin_date: Date.new(2000, 1, 1))
  end

  let(:vat) do
    Vat.find(Date.new(2000, 01, 01))
  end

  let(:member)   { create(:person, :with_account, :with_self_role, roles: { Role::GROUP_MEMBER => localpool }) }
  let(:operator) { create(:person, :with_account, :with_self_role, roles: { Role::BUZZN_OPERATOR => nil }) }

  let(:input) { {name: 'route-66', last_date: '2018-12-31'} }
  let(:future_input) { {name: 'fail0r', last_date: Date.today + 24.day} }

  describe 'authorization' do

    let(:user) { member }

    it 'fails' do
      expect { subject.call(params: input, resource: localpool_resource) }.to raise_error Buzzn::PermissionDenied
    end
  end

  describe 'invalid inputs' do

    let(:user) { operator }

    it 'does not leave orphaned objects when failing' do
      before_count = localpool.billing_cycles.count
      expect { subject.call(params: future_input, resource: localpool_resource, vats: [vat]) }.to raise_error Buzzn::ValidationError
      expect(localpool.billing_cycles.count).to eq before_count
    end

    it 'does not allow creation with empty next_billing_cycle_begin_date' do
      expect(localpool_without_start_date_resource.next_billing_cycle_begin_date).to be_nil
      expect { subject.call(params: input, resource: localpool_without_start_date_resource) }.to raise_error Buzzn::ValidationError
    end

  end

  describe 'repeated calls' do

    context 'first call' do

      let(:user) { operator }

      before do
        3.times do |i|
          send("install_reading_#{i+1}".to_sym)
        end
      end

      it 'setups correctly' do
        expect(localpool.localpool_power_taker_contracts.count).to eql 3
      end

      it 'succeeds' do
        result = subject.call(params: input, resource: localpool_resource, vats: [vat])
        expect(result).to be_success
        expect(result.value!).to be_a Admin::BillingCycleResource
        expect(result.value!.object).to eq(localpool.billing_cycles.first)
        expect(result.value!.begin_date).to eq(localpool.start_date)
        expect(result.value!.object.billings.count).to eq 3
      end

      context 'second call' do

        it 'fails' do
          result = subject.call(params: input, resource: localpool_resource, vats: [vat])
          expect(result).to be_success
          expect { subject.call(params: input, resource: localpool_resource, vats: [vat]) }.to raise_error Buzzn::ValidationError
        end

        context 'when last date is different' do
          let(:new_input) { input.merge(last_date: Date.today - 1.day) }

          it 'succeeds' do
            result = subject.call(params: new_input, resource: localpool_resource, vats: [vat])
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
      result = subject.call(params: input, resource: resource, vats: [vat])
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
