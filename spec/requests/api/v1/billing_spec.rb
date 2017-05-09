describe "billings" do

  entity(:group) { Fabricate(:localpool, registers: [Fabricate(:input_meter).input_register, Fabricate(:input_meter).input_register]) }
  entity(:billing_cycle) { Fabricate(:billing_cycle, localpool: group) }
  entity!(:billing) { Fabricate(:billing,
                        billing_cycle: billing_cycle,
                        localpool_power_taker_contract: Fabricate(:localpool_power_taker_contract,
                                                                  register: group.registers.by_label(Register::Base::CONSUMPTION).first)) }
  entity!(:other_billing) { Fabricate(:billing,
                        billing_cycle: billing_cycle,
                        localpool_power_taker_contract: Fabricate(:localpool_power_taker_contract,
                                                                  register: group.registers.by_label(Register::Base::CONSUMPTION)[1])) }
  entity(:full_access_token) { Fabricate(:full_access_token)}

  entity :update_response do
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
      "invoice_number"=>"--invoice_number--",
      "status"=>"open",
      "updatable"=>true,
      "deletable"=>true
    }
  end

  it 'updates a billing' do
    manager_user          = User.find(full_access_token.resource_owner_id)
    manager_user.remove_role(:manager, group)

    PATCH "/api/v1/billings/#{billing.id}", full_access_token, invoice_number: '123-abc'
    expect(response).to have_http_status(403)

    manager_user.add_role(:manager, group)
    PATCH "/api/v1/billings/#{billing.id}", full_access_token, invoice_number: '123-abc'
    expect(response).to have_http_status(200)
    update_response['invoice_number'] = update_response['invoice_number'].sub! /--invoice_number--/, billing.reload.invoice_number
    expect(json).to eq update_response
    expect(billing.invoice_number).to eq '123-abc'
  end

  it 'deletes a billing' do
    manager_user          = User.find(full_access_token.resource_owner_id)
    manager_user.remove_role(:manager, group)

    DELETE "/api/v1/billings/#{other_billing.id}", full_access_token
    expect(response).to have_http_status(403)

    manager_user.add_role(:manager, group)
    DELETE "/api/v1/billings/#{other_billing.id}", full_access_token
    expect(response).to have_http_status(204)
  end
end