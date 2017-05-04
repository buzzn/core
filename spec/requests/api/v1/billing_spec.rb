describe "billings" do

  let(:group) { Fabricate(:localpool_sulz_with_registers_and_readings) }
  let(:billing_cycle) { Fabricate(:billing_cycle, localpool: group) }
  let(:billing) { Fabricate(:billing,
                        billing_cycle: billing_cycle,
                        localpool_power_taker_contract: Fabricate(:localpool_power_taker_contract,
                                                                  register: group.registers.by_label(Register::Base::CONSUMPTION).first)) }

  let :update_response do
    {
      "data"=>{
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
          "invoice-number"=>"--invoice_number--",
          "status"=>"open",
          "updatable"=>true,
          "deletable"=>true
        }
      }
    }
  end

  xit 'updates a billing' do
    full_access_token = Fabricate(:full_access_token)
    PATCH "/api/v1/billings/#{billing.id}", full_access_token, invoice_number: '123-abc'
    expect(response).to have_http_status(403)

    manager_access_token = Fabricate(:full_access_token)
    manager_user          = User.find(manager_access_token.resource_owner_id)
    manager_user.add_role(:manager, group)
    PATCH "/api/v1/billings/#{billing.id}", manager_access_token, invoice_number: '123-abc'
    expect(response).to have_http_status(200)
    expect(json).to eq update_response['data']['attributes']['invoice-number'].sub! /--invoice_number--/, '123-abc'
    expect(billing.reload.invoice_number).to eq '123-abc'
  end

  it 'deletes a billing' do
    billing
    full_access_token = Fabricate(:full_access_token)
    DELETE "/api/v1/billings/#{billing.id}", full_access_token
    expect(response).to have_http_status(403)

    manager_access_token = Fabricate(:full_access_token)
    manager_user          = User.find(manager_access_token.resource_owner_id)
    manager_user.add_role(:manager, group)
    DELETE "/api/v1/billings/#{billing.id}", manager_access_token
    expect(response).to have_http_status(200)
    update_response['data']['attributes']['invoice-number'].sub! /--invoice_number--/, billing.invoice_number
    expect(json).to eq update_response
  end
end