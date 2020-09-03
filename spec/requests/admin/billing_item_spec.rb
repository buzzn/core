require_relative 'test_admin_localpool_roda'

describe Admin::BillingItemRoda, :request_helper do

  def app
    TestAdminLocalpoolRoda
  end

  before(:all) do
    create(:vat, amount: 0.19, begin_date: Date.new(2000, 1, 1))
  end

  let(:vat) do
    Vat.find(Date.new(2000, 01, 01))
  end

  let(:localpool) { create(:group, :localpool) }
  let(:billing_cycle) { create(:billing_cycle, localpool: localpool) }
  let(:contract) { create(:contract, :localpool_powertaker, :with_tariff, localpool: localpool) }
  let(:billing) do
    billing = create(:billing, contract: contract)
    billing_cycle.billings << billing
    billing
  end

  let!(:billing_item) do
    create(:billing_item,
           billing: billing,
           tariff: billing.contract.tariffs.first,
           vat: vat)

  end

  let(:begin_reading) do
    create(:reading, register: billing.contract.register_meta.registers.first, date: billing.begin_date)
  end

  let(:end_reading) do
    create(:reading, register: billing.contract.register_meta.registers.first, date: billing.end_date)
  end

  let(:params) do
    {
      begin_reading_id: begin_reading.id,
      end_reading_id: end_reading.id,
      updated_at: billing_item.updated_at.to_json
    }
  end

  context 'PATCH' do

    let(:path) { "/localpools/#{localpool.id}/contracts/#{contract.id}/billings/#{billing.id}/items/#{billing_item.id}" }
    # TODO implement second path
    #let(:path) { "/localpools/#{localpool.id}/billing-cycles/#{billing_cycle.id}/billings/#{billing.id}/items/#{billing_item.id}" }

    context 'unauthenticated' do

      it '403' do
        PATCH path
        expect(response).to have_http_status(403)
      end

    end

    context 'authenticated' do

      it '200' do
        PATCH path, $admin, params
        expect(response).to have_http_status(200)
        billing_item.reload
        expect(billing_item.begin_reading_id).to eql begin_reading.id
        expect(billing_item.end_reading_id).to   eql   end_reading.id
      end

    end

  end

end
