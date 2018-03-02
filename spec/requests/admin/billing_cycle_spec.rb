require_relative 'test_admin_localpool_roda'
require_relative 'resource_shared'

describe Admin::BillingCycleResource do

  def app
    TestAdminLocalpoolRoda # this defines the active application for this test
  end

  entity(:group) { create(:localpool) }
  entity(:billing_cycle) { create(:billing_cycle, localpool: group) }

  context 'localpools/<id>/billing-cycles' do

    let(:path) { "/localpools/#{group.id}/billing-cycles/#{billing_cycle.id}" }

    let(:expected_json) do
      {
        'id'=>billing_cycle.id,
        'type'=>'billing_cycle',
        'updated_at'=>billing_cycle.updated_at.as_json,
        'name'=>billing_cycle.name,
        'begin_date'=>billing_cycle.begin_date.as_json,
        'last_date'=>billing_cycle.last_date.as_json
      }
    end

    it_behaves_like 'GET resource', :billing_cycle
    it_behaves_like 'GET resources', :billing_cycle
  end

  context 'POST' do

    let(:wrong_json) do
      {
        'errors'=>[
          {'parameter'=>'name', 'detail'=>'size cannot be greater than 64'},
          {'parameter'=>'last_date', 'detail'=>'must be a date'}
        ]
      }
    end

    let(:end_date) { Date.parse('2018-02-01') }
    let(:created_json) do
      {
        'type'=>'billing_cycle',
        'name'=>'mine',
        'begin_date'=> billing_cycle.end_date.as_json,
        'last_date'=> end_date.as_json
      }
    end

    it '401' do
      GET "/localpools/#{group.id}/billing-cycles/#{billing_cycle.id}", $admin
      expire_admin_session do
        POST "/localpools/#{group.id}/billing-cycles", $admin
        expect(response).to be_session_expired_json(401)
      end
    end

    it '422' do
      POST "/localpools/#{group.id}/billing-cycles", $admin, last_date: 'blubla', name: 'something'*10
      expect(response).to have_http_status(422)
      expect(json.to_yaml).to eq wrong_json.to_yaml
    end

    it '201', :pending do
      POST "/localpools/#{group.id}/billing-cycles", $admin,
           last_date: end_date,
           name: 'mine'
      expect(response).to have_http_status(201)
      result = json
      id = result.delete('id')
      expect(result.delete('updated_at')).not_to eq nil
      expect(BillingCycle.find(id)).not_to be_nil
      expect(result.to_yaml).to eq created_json.to_yaml

      BillingCycle.delete(id)
    end
  end

  context 'PATCH' do

    let(:wrong_json) do
      {
        'errors'=>[
          {'parameter'=>'updated_at', 'detail'=>'is missing'},
          {'parameter'=>'name', 'detail'=>'size cannot be greater than 64'},
          {'parameter'=>'last_date', 'detail'=>'must be a date'}
        ]
      }
    end

    entity :updated_json do
      {
        'id'=>billing_cycle.id,
        'type'=>'billing_cycle',
        'name'=>'abcd',
        'begin_date'=>billing_cycle.begin_date.to_s,
        'last_date'=>billing_cycle.last_date.to_s
      }
    end

    it '401' do
      GET "/localpools/#{group.id}/billing-cycles/#{billing_cycle.id}", $admin
      expire_admin_session do
        PATCH "/localpools/#{group.id}/billing-cycles/#{billing_cycle.id}", $admin
        expect(response).to be_session_expired_json(401)
      end
    end

    it '404' do
      PATCH "/localpools/#{group.id}/billing-cycles/bla-blub", $admin
      expect(response).to be_not_found_json(404, BillingCycle)
    end

    it '409' do
      PATCH "/localpools/#{group.id}/billing-cycles/#{billing_cycle.id}", $admin,
            updated_at: DateTime.now
      expect(response).to be_stale_json(409, billing_cycle)
    end

    it '422' do
      PATCH "/localpools/#{group.id}/billing-cycles/#{billing_cycle.id}", $admin,
            last_date: 'blubla',
            name: 'hello mister' * 20
      expect(response).to have_http_status(422)
      expect(json.to_yaml).to eq wrong_json.to_yaml
    end

    it '200' do
      old = billing_cycle.updated_at
      PATCH "/localpools/#{group.id}/billing-cycles/#{billing_cycle.id}", $admin,
            updated_at: billing_cycle.updated_at,
            name: 'abcd',
            last_date: '2018-2-1'

      expect(response).to have_http_status(200)
      billing_cycle.reload
      expect(billing_cycle.name).to eq 'abcd'
      expect(billing_cycle.last_date).to eq Date.parse('2018-2-1')

      result = json
      # TODO fix it: our time setup does not allow
      #expect(result.delete('updated_at')).to be > old.as_json
      expect(result.delete('updated_at')).not_to eq old.as_json
      expect(result.to_yaml).to eq updated_json.to_yaml
    end
  end

  context 'DELETE' do

    entity!(:other_billing_cycle) { create(:billing_cycle, localpool: group) }

    it '401' do
      GET "/localpools/#{group.id}/billing-cycles/#{billing_cycle.id}", $admin
      expire_admin_session do
        DELETE "/localpools/#{group.id}/billing-cycles/#{billing_cycle.id}", $admin
        expect(response).to be_session_expired_json(401)
      end
    end

    it '204' do
      size = BillingCycle.all.size

      DELETE "/localpools/#{group.id}/billing-cycles/#{other_billing_cycle.id}", $admin
      expect(response).to have_http_status(204)
      expect(BillingCycle.all.size).to eq size - 1
    end
  end
end
