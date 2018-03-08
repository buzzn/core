require_relative 'test_admin_localpool_roda'
require_relative 'resource_shared'

describe Admin::BillingCycleResource do

  def app
    TestAdminLocalpoolRoda
  end

  entity(:localpool)        { create(:localpool) }
  entity(:register)         { create(:register, :consumption) }
  entity!(:billing_cycle)   { create(:billing_cycle, localpool: localpool, begin_date: Date.parse('2000-1-1'), end_date: Date.today) }
  entity!(:market_location) { create(:market_location, :with_contract, group: localpool, register: register) }
  entity(:contract) { market_location.contracts.first }

  context 'localpools/<id>/billing-cycles/<id>/bricks' do

    context 'GET' do
      let(:path) { "/localpools/#{localpool.id}/billing-cycles/#{billing_cycle.id}/bricks" }

      let(:expected_json) do
        {
          'id' => market_location.id,
          'type' => 'market_location',
          'name' => market_location.name,
          'bricks' => {
            'array' => [
              {
                'contract_type' => 'power_taker',
                'begin_date' => contract.begin_date.as_json,
                'end_date' => billing_cycle.end_date.as_json,
                'status' => 'open',
                'consumed_energy_kwh' => nil,
                'energy_price_cents' => nil,
                'base_price_cents' => nil,
                'errors' => {
                  'begin_reading' => ['No reading for begin date'],
                  'end_reading' => ['No reading for end date'],
                  'tariff' => ['No tariff']
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
