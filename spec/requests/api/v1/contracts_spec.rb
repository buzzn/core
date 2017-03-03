describe "/contracts" do


  it 'gets the related customer for the metering_point_operator_contract only with full token' do
    group  = Fabricate(:localpool_forstenried)
    contract = group.metering_point_operator_contract
    customer = contract.customer
    full_access_token = Fabricate(:full_access_token)
    get_with_token "/api/v1/contracts/#{contract.id}/customer", full_access_token.token
    expect(response).to have_http_status(403)

    manager_access_token = Fabricate(:full_access_token)
    manager_user         = User.find(manager_access_token.resource_owner_id)
    manager_user.add_role(:manager, group)
    get_with_token "/api/v1/contracts/#{contract.id}/customer", manager_access_token.token
    expect(response).to have_http_status(200)
    expect(json['data']['id']).to eq(customer.id)
  end


  it 'gets the related contractor for the metering_point_operator_contract only with full token' do
    group  = Fabricate(:localpool_forstenried)
    contract = group.metering_point_operator_contract
    contractor = contract.contractor
    full_access_token = Fabricate(:full_access_token)
    get_with_token "/api/v1/contracts/#{contract.id}/contractor", full_access_token.token
    expect(response).to have_http_status(403)

    manager_access_token = Fabricate(:full_access_token)
    manager_user         = User.find(manager_access_token.resource_owner_id)
    manager_user.add_role(:manager, group)
    get_with_token "/api/v1/contracts/#{contract.id}/contractor", manager_access_token.token
    expect(response).to have_http_status(200)
    expect(json['data']['id']).to eq(contractor.id)
  end


end
