require_relative 'test_admin_localpool_roda'
require_relative 'resource_shared'

describe Admin::BillingCycleResource do

  def app
    TestAdminLocalpoolRoda
  end

  entity(:register)         { create(:register, :consumption) }
  entity!(:market_location) { create(:market_location, :with_contract, register: register) }
  entity(:localpool)        { market_location.group }
  entity!(:billing_cycle)   { create(:billing_cycle, localpool: localpool, begin_date: Date.parse('2000-1-1'), end_date: Date.today) }
  entity(:contract) { market_location.contracts.first }

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
                'billing_id' => nil,
                'contract_type' => 'power_taker',
                'begin_date' => contract.begin_date.as_json,
                'end_date' => billing_cycle.end_date.as_json,
                'status' => 'open',
                'consumed_energy_kwh' => nil,
                'price_cents' => nil,
                'errors' => {
                  'billing' => ['billing must be filled'],
                  'tariff' => ['tariff must be filled'],
                  'contract' => ['contract must be filled']
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
