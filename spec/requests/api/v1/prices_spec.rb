describe "Prices API" do

  entity(:user) { Fabricate(:user_token) }
  entity(:manager) { Fabricate(:user_token) }
  entity(:admin) { Fabricate(:admin_token) }
  entity(:group) do
    localpool = Fabricate(:localpool)
    User.find(manager.resource_owner_id)
      .add_role(:manager, localpool)
    localpool
  end
  entity(:price) { Fabricate(:price, localpool: group)}

  let(:update_response) do
    {
      "id"=>price.id,
      "type"=>"price",
      "name"=>"abcd",
      "begin_date"=>"2015-01-01",
      "energyprice_cents_per_kilowatt_hour"=>22.66,
      "baseprice_cents_per_month"=>400,
      "updatable"=>true,
      "deletable"=>true
    }
  end

  it 'updates a price' do

    request_params = {
      id: price.id,
      name: 'abcd',
      begin_date: Date.new(2015, 1, 1),
      energyprice_cents_per_kilowatt_hour: 22.66,
      baseprice_cents_per_month: 400
    }

    PATCH "/api/v1/prices/#{price.id}", user, request_params
    expect(response).to have_http_status(403)

    manager_access_token = Fabricate(:full_access_token)
    manager_user         = User.find(manager_access_token.resource_owner_id)
    manager_user.add_role(:manager, group)
    PATCH "/api/v1/prices/#{price.id}", manager_access_token, request_params
    expect(response).to have_http_status(200)
    expect(json).to eq update_response
  end
end
