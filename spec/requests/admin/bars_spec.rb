require_relative 'test_admin_localpool_roda'
require_relative 'resource_shared'

describe Admin::BillingCycleResource do

  def app
    TestAdminLocalpoolRoda
  end

  entity(:register)         { create(:register, :consumption) }
  entity!(:market_location) { create(:market_location, :with_contract, register: register) }
  entity(:localpool)        { market_location.group }
  entity!(:billing_cycle)   { create(:billing_cycle, localpool: localpool, date_range: Date.new(2016, 1, 1)...Date.new(2017, 1, 1)) }
  entity(:contract)         { market_location.contracts.first }
  entity!(:billing) do
    item = FactoryGirl.build(:billing_item, :with_readings, date_range: billing_cycle.date_range)
    create(:billing, items: [item], billing_cycle: billing_cycle, contract: contract, date_range: billing_cycle.date_range)
  end
  entity(:bi)

  context 'localpools/<id>/billing-cycles/<id>/bars' do

    context 'GET' do
      let(:path) { "/localpools/#{localpool.id}/billing-cycles/#{billing_cycle.id}/bars" }

      let(:expected_json) do
        {
          'id' => market_location.id,
          'type' => 'market_location',
          'name' => market_location.name,
          'bars' => {
            'array' => [
              {
                'billing_id' => billing.id,
                'contract_type' => 'power_taker',
                'begin_date' => contract.begin_date.as_json,
                'end_date' => billing_cycle.end_date.as_json,
                'status' => 'open',
                'consumed_energy_kwh' => billing.items.first.consumed_energy_kwh,
                'price_cents' => nil,
                'errors' => {
                  'tariff' => ['tariff must be filled'],
                }
              }
            ]
          }
        }
      end

      it_behaves_like 'all'
    end
  end
end
