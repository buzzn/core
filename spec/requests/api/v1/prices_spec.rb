describe "Prices API" do

  let(:update_response) do
    {
      "data"=> {
        "id"=>"SOME_ID",
        "type"=>"prices",
        "attributes"=> {
          "type"=>"price",
          "name"=>"abcd",
          "begin-date"=>"2015-01-01",
          "energyprice-cents-per-kilowatt-hour"=>22.66,
          "baseprice-cents-per-month"=>400,
          "updatable"=>true,
          "deletable"=>true
        }
      }
    }
  end

  it 'updates a price' do
    group = Fabricate(:localpool)
    price = Fabricate(:price, localpool: group)

    request_params = {
      id: price.id,
      name: 'abcd',
      begin_date: Date.new(2015, 1, 1),
      energyprice_cents_per_kilowatt_hour: 22.66,
      baseprice_cents_per_month: 400
    }

    full_access_token = Fabricate(:full_access_token)
    PATCH "/api/v1/prices/#{price.id}", full_access_token, request_params
    expect(response).to have_http_status(403)

    manager_access_token = Fabricate(:full_access_token)
    manager_user         = User.find(manager_access_token.resource_owner_id)
    manager_user.add_role(:manager, group)
    PATCH "/api/v1/prices/#{price.id}", manager_access_token, request_params
    expect(response).to have_http_status(200)
    update_response['data']['id'] = price.id
    expect(json).to eq update_response
  end
end
