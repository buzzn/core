require_relative 'test_admin_localpool_roda'
require_relative 'shared_crud'

describe Admin::BillingRoda, :request_helper do

  def app
    TestAdminLocalpoolRoda # this defines the active application for this test
  end

  before(:all) do
    create(:vat, amount: 0.19, begin_date: Date.new(2000, 1, 1))
  end

  let(:vat) do
    Vat.find(Date.new(2000, 01, 01))
  end

  let(:path) { "/localpools/#{localpool.id}/billing-cycles/#{billing_cycle.id}/billings/#{billing.id}" }

  context 'localpools/<id>/billing-cycles/<id>/billings' do

    context 'GET' do

      let(:localpool) { create(:group, :localpool) }
      let(:billing_cycle) { create(:billing_cycle, localpool: localpool) }
      let(:billing) do
        billing = create(:billing, contract: create(:contract, :localpool_powertaker, :with_tariff, localpool: localpool))
        billing_cycle.billings << billing
        billing
      end
      let!(:billing_item) do
        create(:billing_item, :with_readings,
               billing: billing,
               tariff: billing.contract.tariffs.first,
               vat: vat)

      end

      let(:expected_json) do
        {
          'id'=>billing.id,
          'invoice_number'=>billing.invoice_number,
          'invoice_number_addition'=>billing.invoice_number_addition,
          'full_invoice_number'=>billing.full_invoice_number,
          'type'=>'billing',
          'created_at'=>billing.created_at.as_json,
          'updated_at'=>billing.updated_at.as_json,
          'begin_date'=>billing.begin_date.as_json,
          'allowed_actions' => {
            'update' => {
              'status' => {
                'calculated' => true,
                'open' => true,
                'void' => true,
              },
            },
          },
          'end_date'=>billing.end_date.as_json,
          'last_date'=>billing.last_date.as_json,
          'status'=>billing.status
        }
      end

      it_behaves_like 'single', :billing, path: :path, expected: :expected_json
      it_behaves_like 'all', path: :path, expected: :expected_json

      it 'nested objects' do
        GET path, $admin, include: 'contract:[customer],items:[meter, tariff]'

        expect(json).to has_nested_json(:contract, :customer, :id)
        expect(json).to has_nested_json(:items, :array, :meter, :id)
        expect(json).to has_nested_json(:items, :array, :tariff, :id)
      end
    end
  end

  context 'localpools/<id>/contracts/<id>/billings' do

    context 'POST' do
      entity(:localpool) { create(:group, :localpool) }

      entity(:lpc) do
        create(:contract, :localpool_processing,
               customer: localpool.owner,
               contractor: Organization::Market.buzzn,
               localpool: localpool)
      end

      entity(:person) do
        create(:person, :with_bank_account)
      end

      entity(:meter) do
        create(:meter, :real, :connected_to_discovergy, :one_way, group: localpool)
      end

      entity!(:install_reading) do
        create(:reading, :setup, raw_value: 0, register: meter.registers.first, date: lpc.begin_date - 2.day)
      end

      entity(:contract) do
        create(:contract, :localpool_powertaker, :with_tariff,
               customer: person,
               register_meta: meter.registers.first.meta,
               contractor: Organization::Market.buzzn,
               localpool: localpool)
      end

      let(:path) do
        "/localpools/#{localpool.id}/contracts/#{contract.id}/billings"
      end

      let(:begin_date) { contract.begin_date }
      let(:last_date)  { begin_date + 90 }

      let(:params) do
        {
          :begin_date => begin_date,
          :last_date  => last_date
        }
      end

      context 'unauthenticated' do
        it '403' do
          POST path
          expect(response).to have_http_status(403)
        end
      end

      context 'authenticated' do
        it '200' do
          POST path, $admin, params
          expect(response).to have_http_status(201)
        end
      end

    end
  end
end
