require_relative 'test_admin_localpool_roda'
require_relative 'resource_shared'

describe Admin::BillingResource, :request_helper do

  def app
    TestAdminLocalpoolRoda # this defines the active application for this test
  end

  let(:path) { "/localpools/#{localpool.id}/billing-cycles/#{billing_cycle.id}/billings/#{billing.id}" }

  context 'localpools/<id>/billing-cycles/<id>/billings' do

    context 'GET' do

      entity(:localpool) { create(:group, :localpool) }
      entity(:billing_cycle) { create(:billing_cycle, localpool: localpool) }
      entity(:billing) do
        billing = create(:billing, contract: create(:contract, :localpool_powertaker, :with_tariff, localpool: localpool))
        billing_cycle.billings << billing
        billing
      end
      entity!(:billing_item) do
        create(:billing_item, :with_readings,
               billing: billing,
               tariff: billing.contract.tariffs.first)

      end

      let(:expected_json) do
        {
          'id'=>billing.id,
          'type'=>'billing',
          'updated_at'=>billing.updated_at.as_json,
          'begin_date'=>billing.begin_date.as_json,
          'last_date'=>billing.last_date.as_json,
          'status'=>billing.status
        }
      end

      it_behaves_like 'single', :billing
      it_behaves_like 'all'

      it 'nested objects' do
        GET path, $admin, include: 'contract:[customer],items:[meter, tariff]'

        expect(json).to has_nested_json(:contract, :customer, :id)
        expect(json).to has_nested_json(:items, :array, :meter, :id)
        expect(json).to has_nested_json(:items, :array, :tariff, :id)
      end
    end
  end
end
