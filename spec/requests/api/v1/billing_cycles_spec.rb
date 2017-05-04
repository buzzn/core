describe "billing-cycles" do

  let(:group) { Fabricate(:localpool_sulz_with_registers_and_readings) }
  let(:billing_cycle) { Fabricate(:billing_cycle, localpool: group) }
  let(:regular_token) do
    Fabricate(:user_token)
  end
  let(:manager_token) do
    token = Fabricate(:user_token)
    user = User.find(token.resource_owner_id)
    user.add_role(:manager, group)
    token
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

  # TODO: comment in when merged with branch that fixes the DB cleaning issue
  xit 'creates all regular billings' do
    request_params = {
      accounting_year: 2016
    }.to_json

    POST "/api/v1/billing-cycles/#{billing_cycle.id}/create-regular-billings", regular_token, request_params
    expect(response).to have_http_status(403)

    POST "/api/v1/billing-cycles/#{billing_cycle.id}/create-regular-billings", manager_token, request_params
    expect(response).to have_http_status(201)
    expect(json).to eq create_response
  end

  # TODO: comment in when merged with branch that fixes the DB cleaning issue
  xit 'gets all billings' do
    GET "/api/v1/billing-cycles/#{billing_cycle.id}/billings", regular_token
    expect(response).to have_http_status(403)

    GET "/api/v1/billing-cycles/#{billing_cycle.id}/billings", manager_token
    expect(response).to have_http_status(200)
    expect(json['data'].sort{|a, b| a['id'] <=> b['id']}).to eq create_response['data'].sort{|a, b| a['id'] <=> b['id']}
  end

  # TODO: comment in when merged with branch that fixes the DB cleaning issue
  xit 'updates a billing cycle' do
    PATCH "/api/v1/billing-cycles/#{billing_cycle.id}", manager_token, name: 'abcd'
    expect(response).to have_http_status(200)
    expect(json['data']['attributes']['name']).to eq 'abcd'
  end

  # TODO: comment in when merged with branch that fixes the DB cleaning issue
  xit 'deletes a billing cycle' do
    billing_cycle
    size = BillingCycle.all.size
    DELETE "/api/v1/billing-cycles/#{billing_cycle.id}", manager_token
    expect(response).to have_http_status(200)
    expect(BillingCycle.all.size).to eq size - 1
  end
end