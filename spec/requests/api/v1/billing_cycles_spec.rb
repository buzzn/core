describe "billing-cycles" do

  let(:group) { Fabricate(:localpool_sulz_with_registers_and_readings) }
  let(:billing_cycle) { Fabricate(:billing_cycle, localpool: group) }
  let(:token) do
    Fabricate(:user_token)
  end
  let(:billing) { Fabricate(:billing,
                            billing_cycle: billing_cycle,
                            localpool_power_taker_contract: group.registers.by_label(Register::Base::CONSUMPTION).first.contracts.localpool_power_takers.first) }
  let(:other_billing) { Fabricate(:billing,
                            billing_cycle: billing_cycle,
                            localpool_power_taker_contract: group.registers.by_label(Register::Base::CONSUMPTION)[1].contracts.localpool_power_takers.first) }

  let :create_response do
    {"data"=>[
      {
        "id"=>billing.id,
        "type"=>"billings",
        "attributes"=>{
          "type"=>"billing",
          "start-reading-id"=>billing.start_reading_id,
          "end-reading-id"=>billing.end_reading_id,
          "device-change-reading-1-id"=>nil,
          "device-change-reading-2-id"=>nil,
          "total-energy-consumption-k-wh"=>1000,
          "total-price-cents"=>30000,
          "prepayments-cents"=>29000,
          "receivables-cents"=>1000,
          "invoice-number"=>"12345678-987",
          "status"=>"open",
          "updatable"=>false, #TODO: why is this not updatable?!
          "deletable"=>false
        }
      },
      {
        "id"=>other_billing.id,
        "type"=>"billings",
        "attributes"=>{
          "type"=>"billing",
          "start-reading-id"=>other_billing.start_reading_id,
          "end-reading-id"=>other_billing.end_reading_id,
          "device-change-reading-1-id"=>nil,
          "device-change-reading-2-id"=>nil,
          "total-energy-consumption-k-wh"=>1000,
          "total-price-cents"=>30000,
          "prepayments-cents"=>29000,
          "receivables-cents"=>1000,
          "invoice-number"=>"12345678-987",
          "status"=>"open",
          "updatable"=>false, #TODO: why is this not updatable?!
          "deletable"=>false
        }
      }
    ]}
  end

  class BillingCycle
    def create_regular_billings(accounting_year)
      return Billing.all
    end
  end

  it 'creates all regular billings' do
    billing
    other_billing

    request_params = {
      accounting_year: 2016
    }.to_json

    POST "/api/v1/billing-cycles/#{billing_cycle.id}/create-regular-billings", token, request_params
    expect(response).to have_http_status(403)

    user = User.find(token.resource_owner_id)
    user.add_role(:manager, group)
    POST "/api/v1/billing-cycles/#{billing_cycle.id}/create-regular-billings", token, request_params
    expect(response).to have_http_status(201)
    expect(json).to eq create_response
  end

  #TODO: create endpoint
  xit 'gets all billings' do
    billing
    other_billing

    full_access_token = Fabricate(:full_access_token)
    GET "/api/v1/billing-cycles/#{billing_cycle.id}/billings", full_access_token
    # TODO: should this request return a 403 instead of an empty array?
    expect(response).to have_http_status(200)
    expect(json['data']).to eq []

    GET "/api/v1/billing-cycles/#{billing_cycle.id}/billings", token
    expect(response).to have_http_status(200)

    expect(json['data'][0]['id']).to eq(billing.id)
    expect(json['data'][0]['type']).to eq('billings')
    expect(json['data'][1]['id']).to eq(other_billing.id)
    expect(json['data'][1]['type']).to eq('billings')
  end
end