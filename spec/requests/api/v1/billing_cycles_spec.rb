describe "billing-cycles" do

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
  entity :create_response do
    [{
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
      "invoice_number"=>"12345678-987",
      "status"=>"open",
      "updatable"=>false, #TODO: why is this not updatable?!
      "deletable"=>false
    },
    {
      "id"=>other_billing.id,
      "type"=>"billing",
      "start_reading_id"=>other_billing.start_reading_id,
      "end_reading_id"=>other_billing.end_reading_id,
      "device_change_reading_1_id"=>nil,
      "device_change_reading_2_id"=>nil,
      "total_energy_consumption_kWh"=>1000,
      "total_price_cents"=>30000,
      "prepayments_cents"=>29000,
      "receivables_cents"=>1000,
      "invoice_number"=>"12345678-987",
      "status"=>"open",
      "updatable"=>false, #TODO: why is this not updatable?!
      "deletable"=>false
    }]
  end

  it 'creates all regular billings' do
    # overwrite BillingCycle.create_regular_billings
    BillingCycleResource.class_eval do
      def create_regular_billings(params = {})
        return Billing.all.collect{|b| BillingResource.new(b)}
      end
    end

    POST "/api/v1/billing-cycles/#{billing_cycle.id}/create-regular-billings", regular_token, accounting_year: 2016
    expect(response).to have_http_status(403)

    POST "/api/v1/billing-cycles/#{billing_cycle.id}/create-regular-billings", manager_token, accounting_year: 2016
    expect(response).to have_http_status(201)
    expect(json).to eq create_response

    # reload BillingCycle class definition to undo the method overwriting
    Object.send(:remove_const, :BillingCycleResource)
    load 'app/resources/billing_cycle_resource.rb'
  end

  it 'gets all billings' do
    GET "/api/v1/billing-cycles/#{billing_cycle.id}/billings", regular_token
    expect(response).to have_http_status(403)

    GET "/api/v1/billing-cycles/#{billing_cycle.id}/billings", manager_token
    expect(response).to have_http_status(200)
    expect(json).to match_array create_response
  end

  it 'updates a billing cycle' do
    PATCH "/api/v1/billing-cycles/#{billing_cycle.id}", regular_token, name: 'abcd'
    expect(response).to have_http_status(403)

    PATCH "/api/v1/billing-cycles/#{billing_cycle.id}", manager_token, name: 'abcd'
    expect(response).to have_http_status(200)
    expect(json['name']).to eq 'abcd'
    expect(billing_cycle.reload.name).to eq 'abcd'
  end

  it 'deletes a billing cycle' do
    size = BillingCycle.all.size
    DELETE "/api/v1/billing-cycles/#{other_billing_cycle.id}", regular_token
    expect(response).to have_http_status(403)

    DELETE "/api/v1/billing-cycles/#{other_billing_cycle.id}", manager_token
    expect(response).to have_http_status(204)
    expect(BillingCycle.all.size).to eq size - 1
  end
end