require_relative 'test_admin_localpool_roda'
describe Admin::LocalpoolRoda do

  def app
    TestAdminLocalpoolRoda # this defines the active application for this test
  end

  context 'billing_cycles' do

    entity(:group) { Fabricate(:localpool) }
    entity(:billing_cycle) { Fabricate(:billing_cycle, localpool: group) }
    entity!(:other_billing_cycle) { Fabricate(:billing_cycle, localpool: group) }
    entity!(:billing) do Fabricate(:billing,
                                   billing_cycle: billing_cycle,
                                   localpool_power_taker_contract: create(:contract, :localpool_powertaker,
                                                                          market_location: create(:market_location, register: Fabricate.create(:input_meter, group: group).input_register))) end
    entity!(:other_billing) do Fabricate(:billing,
                                         billing_cycle: billing_cycle,
                                         localpool_power_taker_contract: create(:contract, :localpool_powertaker,
                                                                                market_location: create(:market_location, register:Fabricate.create(:input_meter, group: group).input_register))) end

    let(:wrong_json) do
      {
        'errors'=>[
          {'parameter'=>'name', 'detail'=>'size cannot be greater than 64'},
          {'parameter'=>'begin_date', 'detail'=>'must be a date'},
          {'parameter'=>'end_date', 'detail'=>'must be a date'}
        ]
      }
    end

    context 'GET' do

      let(:cycles_json) do
        BillingCycle.all.collect do |cycle|
          {
            'id'=>cycle.id,
            'type'=>'billing_cycle',
            'updated_at'=>cycle.updated_at.as_json,
            'name'=>cycle.name,
            'begin_date'=>cycle.begin_date.as_json,
            'end_date'=>cycle.end_date.as_json,
            'billings'=>{
              'array'=> cycle.billings.collect do |billing|
                {
                  'id'=>billing.id,
                  'type'=>'billing',
                  'updated_at'=>billing.updated_at.as_json,
                  'start_reading_id'=>billing.start_reading_id,
                  'end_reading_id'=>billing.end_reading_id,
                  'device_change_reading_1_id'=>nil,
                  'device_change_reading_2_id'=>nil,
                  'total_energy_consumption_kwh'=>1000,
                  'total_price_cents'=>30000,
                  'prepayments_cents'=>29000,
                  'receivables_cents'=>1000,
                  'invoice_number'=>billing.invoice_number,
                  'status'=>'open',
                  'updatable'=>true,
                  'deletable'=>true
                }
              end
            }
          }
        end
      end

      it '401' do
        GET "/test/#{group.id}/billing-cycles/#{other_billing_cycle.id}", $admin
        Timecop.travel(Time.now + 30 * 60) do
          GET "/test/#{group.id}/billing-cycles/#{other_billing_cycle.id}", $admin
          expect(response).to be_session_expired_json(401)

          GET "/test/#{group.id}/billing-cycles", $admin
          expect(response).to be_session_expired_json(401)
        end
      end

      it '404' do
        GET "/test/#{group.id}/billing-cycles/bla-blub", $admin
        expect(response).to be_not_found_json(404, BillingCycle)
      end

      it '200 all' do
        GET "/test/#{group.id}/billing-cycles?include=billings", $admin
        expect(response).to have_http_status(200)
        expect(sort(json['array']).to_yaml).to eq sort(cycles_json).to_yaml
      end
    end

    context 'POST' do

      let(:begin_date) { Time.find_zone('Berlin').local(2016, 1, 1).to_datetime }
      let(:end_date) { Time.find_zone('Berlin').local(2017, 1, 1) }
      let(:created_json) do
        {
          'type'=>'billing_cycle',
          'name'=>'mine',
          'begin_date'=>'2016-01-01',
          'end_date'=>'2017-01-01',
          'billings'=>{'array'=>[]}
        }
      end

      it '401' do
        GET "/test/#{group.id}/billing-cycles/#{other_billing_cycle.id}", $admin
        expire_admin_session do
          POST "/test/#{group.id}/billing-cycles", $admin
          expect(response).to be_session_expired_json(401)
        end
      end

      it '422' do
        POST "/test/#{group.id}/billing-cycles", $admin, begin_date: 'blablu', end_date: 'blubla', name: 'something'*10
        expect(response).to have_http_status(422)
        expect(json.to_yaml).to eq wrong_json.to_yaml
      end

      it '201' do
        POST "/test/#{group.id}/billing-cycles", $admin, begin_date: begin_date, end_date: end_date, name: 'mine', include: :billings
        expect(response).to have_http_status(201)
        result = json
        id = result.delete('id')
        expect(result.delete('updated_at')).not_to eq nil
        expect(BillingCycle.find(id)).not_to be_nil
        expect(result.to_yaml).to eq created_json.to_yaml
      end
    end

    context 'PATCH' do

      let(:wrong_json) do
        {
          'errors'=>[
            {'parameter'=>'updated_at', 'detail'=>'is missing'},
            {'parameter'=>'name', 'detail'=>'size cannot be greater than 64'},
            {'parameter'=>'begin_date', 'detail'=>'must be a date'},
            {'parameter'=>'end_date', 'detail'=>'must be a date'}
          ]
        }
      end

      entity :updated_json do
        {
          'id'=>billing_cycle.id,
          'type'=>'billing_cycle',
          'name'=>'abcd',
          'begin_date'=>billing_cycle.begin_date.to_s,
          'end_date'=>billing_cycle.end_date.to_s,
          'billings'=>{
            'array'=> billing_cycle.billings.collect do |billing|
              {
                'id'=>billing.id,
                'type'=>'billing',
                'updated_at'=>billing.updated_at.as_json,
                'start_reading_id'=>billing.start_reading_id,
                'end_reading_id'=>billing.end_reading_id,
                'device_change_reading_1_id'=>nil,
                'device_change_reading_2_id'=>nil,
                'total_energy_consumption_kwh'=>1000,
                'total_price_cents'=>30000,
                'prepayments_cents'=>29000,
                'receivables_cents'=>1000,
                'invoice_number'=>billing.invoice_number,
                'status'=>'open',
                'updatable'=>true,
                'deletable'=>true
              }
            end
          }
        }
      end

      it '401' do
        GET "/test/#{group.id}/billing-cycles/#{other_billing_cycle.id}", $admin
        expire_admin_session do
          PATCH "/test/#{group.id}/billing-cycles/#{other_billing_cycle.id}", $admin
          expect(response).to be_session_expired_json(401)
        end
      end

      it '404' do
        PATCH "/test/#{group.id}/billing-cycles/bla-blub", $admin
        expect(response).to be_not_found_json(404, BillingCycle)
      end

      it '409' do
        PATCH "/test/#{group.id}/billing-cycles/#{billing_cycle.id}", $admin,
              updated_at: DateTime.now
        expect(response).to be_stale_json(409, billing_cycle)
      end

      it '422' do
        PATCH "/test/#{group.id}/billing-cycles/#{billing_cycle.id}", $admin,
              begin_date: 'blablu',
              end_date: 'blubla',
              name: 'hello mister' * 20
        expect(response).to have_http_status(422)
        expect(json).to eq wrong_json
      end

      it '200' do
        old = billing_cycle.updated_at
        PATCH "/test/#{group.id}/billing-cycles/#{billing_cycle.id}", $admin,
              updated_at: billing_cycle.updated_at,
              name: 'abcd',
              begin_date: Date.today,
              end_date: Date.today + 1.month,
              include: :billings

        expect(response).to have_http_status(200)
        billing_cycle.reload
        expect(billing_cycle.name).to eq 'abcd'
        expect(billing_cycle.begin_date).to eq Date.today
        expect(billing_cycle.end_date).to eq Date.today + 1.month

        result = json
        # TODO fix it: our time setup does not allow
        #expect(result.delete('updated_at')).to be > old.as_json
        expect(result.delete('updated_at')).not_to eq old.as_json
        expect(result.to_yaml).to eq updated_json.to_yaml
      end
    end

    context 'DELETE' do

      it '401' do
        GET "/test/#{group.id}/billing-cycles/#{other_billing_cycle.id}", $admin
        expire_admin_session do
          DELETE "/test/#{group.id}/billing-cycles/#{other_billing_cycle.id}", $admin
          expect(response).to be_session_expired_json(401)
        end
      end

      it '204' do
        size = BillingCycle.all.size

        DELETE "/test/#{group.id}/billing-cycles/#{other_billing_cycle.id}", $admin
        expect(response).to have_http_status(204)
        expect(BillingCycle.all.size).to eq size - 1

        # recreate deleted
        BillingCycle.create other_billing_cycle.attributes
      end
    end
  end
end
