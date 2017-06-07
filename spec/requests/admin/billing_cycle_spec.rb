describe Admin::LocalpoolRoda do

  def app
    Admin::LocalpoolRoda # this defines the active application for this test
  end

  context 'billing_cycles' do

    entity(:user) { Fabricate(:user_token) }
    entity(:admin) { Fabricate(:admin_token) }
    entity(:group) { Fabricate(:localpool) }
    entity(:billing_cycle) { Fabricate(:billing_cycle, localpool: group) }
    entity!(:other_billing_cycle) { Fabricate(:billing_cycle, localpool: group) }
    entity(:regular_token) do
      Fabricate(:user_token)
    end
    entity(:manager_token) do
      token = Fabricate(:user_token)
      user = User.find(token.resource_owner_id)
      user.add_role(:manager, group)
      token
    end
    entity!(:billing) { Fabricate(:billing,
                                  billing_cycle: billing_cycle,
                                  localpool_power_taker_contract: Fabricate(:localpool_power_taker_contract,
                                                                            register: Fabricate.build(:input_register, group: group))) }
    entity!(:other_billing) { Fabricate(:billing,
                                        billing_cycle: billing_cycle,
                                        localpool_power_taker_contract: Fabricate(:localpool_power_taker_contract,
                                                                                  register: Fabricate.build(:input_register, group: group))) }

    let(:wrong_json) do
      {
        "errors"=>[
          {"parameter"=>"begin_date", "detail"=>"must be a date"},
          {"parameter"=>"end_date", "detail"=>"must be a date"}
        ]
      }
    end

    let(:not_found_json) do
      {
        "errors" => [
          {
            "detail"=>"BillingCycle: bla-blub not found by User: #{admin.resource_owner_id}"
          }
        ]
      }
    end

    context 'GET' do

      let(:denied_json) do
        {
          "errors" => [
            {
              "detail"=>"retrieve BillingCycleResource: permission denied for User: #{user.resource_owner_id}"
            }
          ]
        }
      end

      let(:cycles_json) do
        BillingCycle.all.collect do |cycle|
          {
            "id"=>cycle.id,
            "type"=>"billing_cycle",
            "name"=>cycle.name,
            "begin_date"=>cycle.begin_date.iso8601(3),
            "end_date"=>cycle.end_date.iso8601(3),
            "billings"=>{
              'array'=> cycle.billings.collect do |billing|
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
            }
          }
        end
      end

      it '403' do
        #TODO need an user which can retrieve localpool but not the billing-cycle
        #      GET "/#{group.id}/billing-cycles/#{billing_cycle.id}", user
        #      expect(response).to have_http_status(403)
        #      expect(json).to eq denied_json
      end

      it '404' do
        GET "/#{group.id}/billing-cycles/bla-blub", admin
        expect(response).to have_http_status(404)
        expect(json).to eq not_found_json
      end

      it '200 all' do
        GET "/#{group.id}/billing-cycles?include=billings", admin
        expect(response).to have_http_status(200)
        expect(sort(json['array']).to_yaml).to eq sort(cycles_json).to_yaml
      end
    end

    context 'POST' do

      let(:missing_json) do
        {
          "errors"=>[
            {"parameter"=>"name", "detail"=>"is missing"},
            {"parameter"=>"begin_date", "detail"=>"is missing"},
            {"parameter"=>"end_date", "detail"=>"is missing"}
          ]
        }
      end

      let(:begin_date) { Time.find_zone('Berlin').local(2016,1,1) }
      let(:end_date) { Time.find_zone('Berlin').local(2017,1,1) }
      let(:created_json) do
        {
          "type"=>"billing_cycle",
          "name"=>"mine",
          "begin_date"=>begin_date.iso8601(3),
          "end_date"=>end_date.iso8601(3),
          "billings"=>[]
        }
      end

      it '403' do
        # TODO needs read perms on localpools but no create perms on billing-cycles
      end

      it '422 missing' do
        POST "/#{group.id}/billing-cycles", admin
        expect(response).to have_http_status(422)
        expect(json.to_yaml).to eq missing_json.to_yaml
      end

      it '422 wrong' do
        # TODO missing length constraints on name
        POST "/#{group.id}/billing-cycles", admin, begin_date: 'blablu', end_date: 'blubla', name: 'something'*10
        expect(response).to have_http_status(422)
        expect(json.to_yaml).to eq wrong_json.to_yaml
      end

      it '201' do
        POST "/#{group.id}/billing-cycles", admin, begin_date: begin_date, end_date: end_date, name: 'mine'
        expect(response).to have_http_status(201)
        result = json
        id = result.delete('id')
        expect(BillingCycle.find(id)).not_to be_nil
        expect(result.to_yaml).to eq created_json.to_yaml
      end
    end

    context 'PATCH' do
      
      entity :update_json do
        {
          "id"=>billing_cycle.id,
          "type"=>"billing_cycle",
          "name"=>"abcd",
          "begin_date"=>billing_cycle.begin_date.iso8601(3),
          "end_date"=>billing_cycle.end_date.iso8601(3),
          "billings"=>billing_cycle.billings.collect do |billing|
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
        }
      end

      it '403' do
        # TODO needs read perms on billing-cycles but no update perms on billings
      end

      it '404' do
        PATCH "/#{group.id}/billing-cycles/bla-blub", admin
        expect(response).to have_http_status(404)
        expect(json).to eq not_found_json
      end

      it '422 wrong' do
        # TODO missing length constraints on name
        PATCH "/#{group.id}/billing-cycles/#{billing_cycle.id}", admin, begin_date: 'blablu', end_date: 'blubla'
        expect(response).to have_http_status(422)
        expect(json).to eq wrong_json
      end

      it '200' do
        old = billing_cycle.name
        PATCH "/#{group.id}/billing-cycles/#{billing_cycle.id}", admin, name: 'abcd'
        expect(response).to have_http_status(200)
        expect(json.to_yaml).to eq update_json.to_yaml
        expect(billing_cycle.reload.name).to eq 'abcd'

        billing_cycle.update(name: old)
      end

    end

    context 'DELETE' do

      it '403' do
        # TODO needs read perms on billing-cycles but no delete perms on billings
      end

      it '204' do
        size = BillingCycle.all.size

        DELETE "/#{group.id}/billing-cycles/#{other_billing_cycle.id}", admin
        expect(response).to have_http_status(204)
        expect(BillingCycle.all.size).to eq size - 1

        # recreate deleted
        BillingCycle.create other_billing_cycle.attributes
      end
    end
  end
end
