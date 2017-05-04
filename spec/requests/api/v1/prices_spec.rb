describe "prices" do

  entity(:user) { Fabricate(:user_token) }
  entity(:admin) { Fabricate(:admin_token) }
  entity(:localpool) { Fabricate(:localpool) }
  entity(:price) { Fabricate(:price, localpool: localpool)}
  
  let(:anonymous_denied_json) do
    {
      "errors" => [
        {
          "detail"=>"retrieve Price: permission denied for User: --anonymous--" }
      ]
    }
  end

  let(:denied_json) do
    json = anonymous_denied_json.dup
    json['errors'][0]['detail'].sub! /--anonymous--/, user.resource_owner_id
    json
  end

  let(:not_found_json) do
    {
      "errors" => [
        {
          "detail"=>"Price: bla-bla-blub not found by User: #{admin.resource_owner_id}" }
      ]
    }
  end

  context 'PATCH' do

    let(:validation_json) do
      {
        "errors"=>[
          {"parameter"=>"begin_date",
           "detail"=>"begin_date is invalid"},
          {"parameter"=>"energyprice_cents_per_kilowatt_hour",
           "detail"=>"energyprice_cents_per_kilowatt_hour is invalid"}
        ]
      }
    end

    let(:update_json) do
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

    it '403' do
      PATCH "/api/v1/prices/#{price.id}"
      expect(response).to have_http_status(403)
      expect(json).to eq anonymous_denied_json

      PATCH "/api/v1/prices/#{price.id}", user
      expect(response).to have_http_status(403)
      expect(json).to eq denied_json
    end

    it '404' do
      PATCH "/api/v1/prices/bla-bla-blub", admin
      expect(response).to have_http_status(404)
      expect(json).to eq not_found_json
    end

    it '422' do
      PATCH "/api/v1/prices/#{price.id}", admin,
            name: 'Max Mueller' * 10,
            begin_date: 'today',
            energyprice_cents_per_kilowatt_hour: '2.4 Euro',
            baseprice_cents_per_month: 22.45
      
      expect(response).to have_http_status(422)
      expect(json).to eq validation_json
    end

    it '200' do
      PATCH "/api/v1/prices/#{price.id}", admin, name: 'abcd',
            begin_date: Date.new(2015, 1, 1),
            energyprice_cents_per_kilowatt_hour: 22.66,
            baseprice_cents_per_month: 400
      
      expect(response).to have_http_status(200)
      expect(json.to_yaml).to eq(update_json.to_yaml)
      price.reload
      expect(price.name).to eq 'abcd'
      expect(price.begin_date).to eq Date.new(2015, 1, 1)
      expect(price.energyprice_cents_per_kilowatt_hour).to eq 22.66
      expect(price.baseprice_cents_per_month).to eq 400
    end
  end

end
