require_relative 'shared_entities'
require 'buzzn/transactions/admin/billing_cycle/generate_report'

describe Transactions::Admin::BillingCycle::GenerateReport, order: :defined do

  include_context 'billing cycle entities'

  let(:end_date) { Date.new(2019,01,01) }

  let(:input) { {name: 'foo', last_date: '2018-12-31'} }

  before(:all) do
    create(:vat, amount: 0.19, begin_date: Date.new(2000, 1, 1))
  end

  let(:vat) do
    Vat.find(Date.new(2000, 01, 01))
  end

  let(:create_result) do
    Transactions::Admin::BillingCycle::Create.new.(params: input,
                                                   resource: localpool_resource, vats:[vat])
  end

  let(:operator) { create(:person, :with_account, :with_self_role, roles: { Role::BUZZN_OPERATOR => nil }) }

  describe 'normal operation' do

    let(:user) { operator }

    3.times do |i|
      let!("begin_reading_#{i+1}") do
        contract = send("contract_#{i+1}")
        create(:reading, :regular, raw_value: 1000+500*i, register: contract.register_meta.registers.first, date: start_date)
      end

      let!("end_reading_#{i+1}") do
        contract = send("contract_#{i+1}")
        create(:reading, :regular, raw_value: 1000+900*i, register: contract.register_meta.registers.first, date: end_date)
      end

      let!("previous_payment_#{i+1}") do
        contract = send("contract_#{i+1}")
        create(:payment, price_cents: 5000, contract: contract)
      end
    end

    it 'generates' do
      expect(create_result).to be_success
      billing_cycle = create_result.value!.object
      # get billing_cycle at right point in tree
      billing_cycler = localpool_resource.billing_cycles.retrieve(billing_cycle.id)
      # document one billing
      billingr = billing_cycler.billings.first
      update_params = {
        status: 'calculated',
        updated_at: billingr.object.updated_at.to_json
      }
      res = Transactions::Admin::Billing::Update.new.(resource: billingr, params: update_params, vat:vat)
      expect(res).to be_success
      billingr.object.reload
      update_params = {
        status: 'documented',
        updated_at: billingr.object.updated_at.to_json
      }
      res = Transactions::Admin::Billing::Update.new.(resource: billingr, params: update_params, vat:vat)
      expect(res).to be_success
      # prep done, generate zip
      billing_cycler.object.reload
      res = Transactions::Admin::BillingCycle::GenerateReport.new.(resource: billing_cycler, params: {})
      expect(res).to be_success
    end

  end
end
