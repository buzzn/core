require 'buzzn/transactions/admin/billing_cycle/create'

describe Transactions::Admin::BillingCycle::Create do

  let(:localpool) { create(:group, :localpool, start_date: Date.parse('2017-11-11')) }
  let(:tariff) do
    tariff = create(:tariff, begin_date: localpool.start_date - 10, group: localpool)
    localpool.gap_contract_tariffs << tariff
    tariff
  end

  let!(:localpool_without_start_date) do
    localpool = create(:group, :localpool)
    localpool.start_date = nil
    localpool.save
    localpool
  end

  let(:account)            { Account::Base.where(person_id: user).first }
  let(:localpool_resource) { Admin::LocalpoolResource.all(account).retrieve(localpool.id) }
  let(:localpool_without_start_date_resource) { Admin::LocalpoolResource.all(account).retrieve(localpool_without_start_date.id) }

  3.times do |i|
    let!("contract_#{i+1}".to_sym) do
      create(:contract, :localpool_powertaker, localpool: localpool, tariffs: [tariff], begin_date: localpool.start_date + (i*13).days)
    end

    let!("install_reading_#{i+1}".to_sym) do
      contract = send("contract_#{i+1}")
      create(:reading, :setup, raw_value: 0, register: contract.register_meta.registers.first, date: contract.begin_date - 2.day)
    end
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
      expect { subject.call(params: future_input, resource: localpool_resource) }.to raise_error Buzzn::ValidationError
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
        result = subject.call(params: input, resource: localpool_resource)
        expect(result).to be_success
        expect(result.value!).to be_a Admin::BillingCycleResource
        expect(result.value!.object).to eq(localpool.billing_cycles.first)
        expect(result.value!.begin_date).to eq(localpool.start_date)
        expect(result.value!.object.billings.count).to eq 3
      end

      context 'second call' do

        it 'fails' do
          result = subject.call(params: input, resource: localpool_resource)
          expect(result).to be_success
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
