require_relative 'test_admin_localpool_roda'
describe Admin::LocalpoolRoda do

  def app
    TestAdminLocalpoolRoda # this defines the active application for this test
  end

  context 'billings' do

    entity(:group) { Fabricate(:localpool, registers: [Fabricate(:input_meter).input_register, Fabricate(:input_meter).input_register]) }
    entity(:billing_cycle) { Fabricate(:billing_cycle, localpool: group) }
    entity!(:billing) do
      Fabricate(:billing,
                billing_cycle: billing_cycle,
                localpool_power_taker_contract: Fabricate(:localpool_power_taker_contract,
                                                          register: group.registers.consumption.first))
    end

    entity!(:other_billing) { Fabricate(:billing,
                                        billing_cycle: billing_cycle,
                                        localpool_power_taker_contract: Fabricate(:localpool_power_taker_contract,
                                                                                  register: group.registers.consumption[1])) }

    context 'GET' do
      let(:billings_json) do
        Billing.all.reload.collect do |billing|
          {
            "id"=>billing.id,
            "type"=>"billing",
            'updated_at'=>billing.updated_at.as_json,
            "start_reading_id"=>billing.start_reading_id,
            "end_reading_id"=>billing.end_reading_id,
            "device_change_reading_1_id"=>nil,
            "device_change_reading_2_id"=>nil,
            "total_energy_consumption_kwh"=>1000,
            "total_price_cents"=>30000,
            "prepayments_cents"=>29000,
            "receivables_cents"=>1000,
            "invoice_number"=>billing.invoice_number,
            "status"=>"open",
            "updatable"=>true,
            "deletable"=>true
          }
        end
      end

      it '401' do
        GET "/test/#{group.id}/billing-cycles/#{billing_cycle.id}/billings", $admin
        Timecop.travel(Time.now + 6 * 60 * 60) do
          GET "/test/#{group.id}/billing-cycles/#{billing_cycle.id}/billings", $admin
          expect(response).to be_session_expired_json(401)
        end
      end

      it '403' do
        # TODO needs read perms on billing-cycles but no create perms on billings
      end

      it '404' do
        GET "/test/#{group.id}/billing-cycles/#{billing_cycle.id}/billings/bla-blub", $admin
        expect(response).to be_not_found_json(404, Billing)
      end

      it '200 all' do
        GET "/test/#{group.id}/billing-cycles/#{billing_cycle.id}/billings", $admin
        expect(response).to have_http_status(200)
        expect(sort(json['array']).to_yaml).to eq sort(billings_json).to_yaml
      end
    end

    context 'POST' do

      let(:wrong_json) do
        {
          "errors"=>[
            {"parameter"=>"accounting_year", "detail"=>"must be an integer"}
          ]
        }
      end

      let(:billings_json) do
        Billing.all.reload.collect do |billing|
          {
            "id"=>billing.id,
            "type"=>"billing",
            'updated_at'=>billing.updated_at.as_json,
            "start_reading_id"=>billing.start_reading_id,
            "end_reading_id"=>billing.end_reading_id,
            "device_change_reading_1_id"=>nil,
            "device_change_reading_2_id"=>nil,
            "total_energy_consumption_kwh"=>1000,
            "total_price_cents"=>30000,
            "prepayments_cents"=>29000,
            "receivables_cents"=>1000,
            "invoice_number"=>billing.invoice_number,
            "status"=>"open",
            "updatable"=>true,
            "deletable"=>true
          }
        end
      end

      it '401' do
        GET "/test/#{group.id}/billing-cycles/#{billing_cycle.id}/billings", $admin
        Timecop.travel(Time.now + 6 * 60 * 60) do
          POST "/test/#{group.id}/billing-cycles/#{billing_cycle.id}/billings/regular", $admin
          expect(response).to be_session_expired_json(401)
        end
      end

      it '403' do
        # TODO needs read perms on billing-cycles but no create perms on billings
      end

      it '422' do
        POST "/test/#{group.id}/billing-cycles/#{billing_cycle.id}/billings/regular", $admin, accounting_year: 'blablu'
        expect(response).to have_http_status(422)
        expect(json.to_yaml).to eq wrong_json.to_yaml
      end

      it '201 all' do
        begin
          BillingCycle.billings(Billing.all)

          POST "/test/#{group.id}/billing-cycles/#{billing_cycle.id}/billings/regular", $admin, accounting_year: 2016
          expect(response).to have_http_status(201)
          expect(sort(json['array']).to_yaml).to eq sort(billings_json).to_yaml

        ensure
          BillingCycle.billings(nil)
        end
      end
    end

    context 'PATCH' do

      entity :updated_json do
        {
          "id"=>billing.id,
          "type"=>"billing",
          "start_reading_id"=>billing.start_reading_id,
          "end_reading_id"=>billing.end_reading_id,
          "device_change_reading_1_id"=>nil,
          "device_change_reading_2_id"=>nil,
          "total_energy_consumption_kwh"=>1000,
          "total_price_cents"=>30000,
          "prepayments_cents"=>29000,
          "receivables_cents"=>1000,
          "invoice_number"=>"123-abc",
          "status"=>"open",
          "updatable"=>true,
          "deletable"=>true
        }
      end

      let(:wrong_json) do
        {
          "errors"=>[
            {"parameter"=>"updated_at",
             "detail"=>"is missing"},
            {"parameter"=>"receivables_cents",
             "detail"=>"must be an integer"},
            {"parameter"=>"invoice_number",
             "detail"=>"size cannot be greater than 64"},
            {"parameter"=>"status",
             "detail"=>"must be one of: open, calculated, delivered, settled, closed"}
          ]
        }
      end

      it '401' do
        GET "/test/#{group.id}/billing-cycles/#{billing_cycle.id}/billings", $admin
        Timecop.travel(Time.now + 6 * 60 * 60) do
          PATCH "/test/#{group.id}/billing-cycles/#{billing_cycle.id}/billings/#{billing.id}", $admin
          expect(response).to be_session_expired_json(401)
        end
      end

      it '409' do
        PATCH "/test/#{group.id}/billing-cycles/#{billing_cycle.id}/billings/#{billing.id}", $admin, updated_at: DateTime.now
        expect(response).to be_stale_json(409, billing)
      end

      it '422' do
        PATCH "/test/#{group.id}/billing-cycles/#{billing_cycle.id}/billings/#{billing.id}", $admin, status: 'bla', receivables_cents: 'something', invoice_number: 'the-number-of-the-???' * 20
        expect(response).to have_http_status(422)
        expect(json.to_yaml).to eq wrong_json.to_yaml
      end

      it '200' do
        old = billing_cycle.updated_at
        PATCH "/test/#{group.id}/billing-cycles/#{billing_cycle.id}/billings/#{billing.id}", $admin, updated_at: billing.updated_at, invoice_number: '123-abc'
        expect(response).to have_http_status(200)
        billing.reload
        expect(billing.invoice_number).to eq '123-abc'

        result = json
        # TODO fix it: our time setup does not allow
        #expect(result.delete('updated_at')).to be > old.as_json
        expect(result.delete('updated_at')).not_to eq old.as_json
        expect(result.to_yaml).to eq updated_json.to_yaml
      end

    end

    context 'DELETE' do

      it '401' do
        GET "/test/#{group.id}/billing-cycles/#{billing_cycle.id}/billings", $admin
        Timecop.travel(Time.now + 6 * 60 * 60) do
          DELETE "/test/#{group.id}/billing-cycles/#{billing_cycle.id}/billings/#{billing.id}", $admin
          expect(response).to be_session_expired_json(401)
        end
      end

      it '403' do
        # TODO needs read perms on billing-cycles but no delete perms on billings
      end

      it '204' do
        size = Billing.all.size

        DELETE "/test/#{group.id}/billing-cycles/#{billing_cycle.id}/billings/#{other_billing.id}", $admin
        expect(response).to have_http_status(204)
        expect(Billing.all.size).to eq size - 1

        # recreate deleted
        Billing.create other_billing.attributes
      end
    end
  end
end
