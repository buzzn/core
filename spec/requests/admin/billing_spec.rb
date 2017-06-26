describe Admin::LocalpoolRoda do

  def app
    Admin::LocalpoolRoda # this defines the active application for this test
  end

  context 'billings' do

    entity(:user) { Fabricate(:user_token) }
    entity(:admin) { Fabricate(:admin_token) }
    entity(:group) { Fabricate(:localpool, registers: [Fabricate(:input_meter).input_register, Fabricate(:input_meter).input_register]) }
    entity(:billing_cycle) { Fabricate(:billing_cycle, localpool: group) }
    entity!(:billing) do
      Fabricate(:billing,
                billing_cycle: billing_cycle,
                localpool_power_taker_contract: Fabricate(:localpool_power_taker_contract,
                                                          register: group.registers.by_label(Register::Base::CONSUMPTION).first))
    end
    entity!(:other_billing) { Fabricate(:billing,
                                        billing_cycle: billing_cycle,
                                        localpool_power_taker_contract: Fabricate(:localpool_power_taker_contract,
                                                                                  register: group.registers.by_label(Register::Base::CONSUMPTION)[1])) }

    context 'GET' do
      let(:billings_json) do
        Billing.all.reload.collect do |billing|
          {
            "id"=>billing.id,
            "type"=>"billing",
            "start_reading_id"=>billing.start_reading_id,
            "end_reading_id"=>billing.end_reading_id,
            "device_change_reading_1_id"=>nil,
            "device_change_reading_2_id"=>nil,
            "total_energy_consumption_kWh"=>1000,
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

      let(:not_found_json) do
        {
          "errors" => [
            {
              "detail"=>"Billing: bla-blub not found by User: #{admin.resource_owner_id}"
            }
          ]
        }
      end

      it '403' do
        # TODO needs read perms on billing-cycles but no create perms on billings
      end

      it '404' do
        GET "/#{group.id}/billing-cycles/#{billing_cycle.id}/billings/bla-blub", admin
        expect(response).to have_http_status(404)
        expect(json).to eq not_found_json
      end

      it '200 all' do
        GET "/#{group.id}/billing-cycles/#{billing_cycle.id}/billings", admin
        expect(response).to have_http_status(200)
        expect(sort(json['array']).to_yaml).to eq sort(billings_json).to_yaml
      end
    end

    context 'POST' do

      let(:missing_json) do
        {
          "errors"=>[
            {
              "parameter"=>"accounting_year", "detail"=>"is missing"
            }
          ]
        }
      end

      let(:wrong_json) do
        {
          "errors"=>[
            {
              "parameter"=>"accounting_year", "detail"=>"must be an integer"
            }
          ]
        }
      end

      let(:billings_json) do
        Billing.all.reload.collect do |billing|
          {
            "id"=>billing.id,
            "type"=>"billing",
            "start_reading_id"=>billing.start_reading_id,
            "end_reading_id"=>billing.end_reading_id,
            "device_change_reading_1_id"=>nil,
            "device_change_reading_2_id"=>nil,
            "total_energy_consumption_kWh"=>1000,
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

      it '403' do
        # TODO needs read perms on billing-cycles but no create perms on billings
      end

      it '422 missing' do
        POST "/#{group.id}/billing-cycles/#{billing_cycle.id}/billings/regular", admin
        expect(response).to have_http_status(422)
        expect(json.to_yaml).to eq missing_json.to_yaml
      end

      it '422 wrong' do
        POST "/#{group.id}/billing-cycles/#{billing_cycle.id}/billings/regular", admin, accounting_year: 'blablu'
        expect(response).to have_http_status(422)
        expect(json.to_yaml).to eq wrong_json.to_yaml
      end

      it '201 all' do
        begin
          BillingCycle.billings(Billing.all)

          POST "/#{group.id}/billing-cycles/#{billing_cycle.id}/billings/regular", admin, accounting_year: 2016
          expect(response).to have_http_status(201)
          expect(sort(json['array']).to_yaml).to eq sort(billings_json).to_yaml

        ensure
          BillingCycle.billings(nil)
        end
      end
    end

    context 'PATCH' do
      
      entity :update_json do
        {
          "id"=>billing.id,
          "type"=>"billing",
          "start_reading_id"=>billing.start_reading_id,
          "end_reading_id"=>billing.end_reading_id,
          "device_change_reading_1_id"=>nil,
          "device_change_reading_2_id"=>nil,
          "total_energy_consumption_kWh"=>1000,
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
            {"parameter"=>"receivables_cents", "detail"=>"must be an integer"},
            {"parameter"=>"status", "detail"=>"must be one of: open, calculated, delivered, settled, closed"}
          ]
        }
      end

      it '403' do
        # TODO needs read perms on billing-cycles but no delete perms on billings
      end

      it '422 wrong' do
        # TODO missing length constraints on invoice_number
        PATCH "/#{group.id}/billing-cycles/#{billing_cycle.id}/billings/#{billing.id}", admin, status: 'bla', receivables_cents: 'something', invoice_number: 'the-number-of-the-???' * 20
        expect(response).to have_http_status(422)
        expect(json).to eq wrong_json
      end

      it '200' do
        old = billing.invoice_number
        PATCH "/#{group.id}/billing-cycles/#{billing_cycle.id}/billings/#{billing.id}", admin, invoice_number: '123-abc'
        expect(response).to have_http_status(200)
        expect(json).to eq update_json
        expect(billing.reload.invoice_number).to eq '123-abc'
        billing.update(invoice_number: old)
      end

    end

    context 'DELETE' do

      it '403' do
        # TODO needs read perms on billing-cycles but no delete perms on billings
      end

      it '204' do
        size = Billing.all.size

        DELETE "/#{group.id}/billing-cycles/#{billing_cycle.id}/billings/#{other_billing.id}", admin
        expect(response).to have_http_status(204)
        expect(Billing.all.size).to eq size - 1

        # recreate deleted
        Billing.create other_billing.attributes
      end
    end
  end
end
