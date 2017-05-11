describe "prices" do

  def app
    CoreRoda # this defines the active application for this test
  end

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

  context 'POST' do
    let(:validation_json) do
      {
        "errors"=>[
          {"parameter"=>"begin_date", "detail"=>"is missing"},
          {"parameter"=>"energyprice_cents_per_kilowatt_hour", "detail"=>"is missing"},
          {"parameter"=>"baseprice_cents_per_month", "detail"=>"is missing"}
        ]
      }
    end

    # TODO not sure whether we needs this again. see when tests switch
    #      to a more modular approach

    # it '403' do
    #   begin
    #     localpool.update(readable: :member)

    #     POST "/api/v1/groups/localpools/#{localpool.id}/prices"
    #     expect(response).to have_http_status(403)
    #     expect(json).to eq anonymous_denied_json

    #     POST "/api/v1/groups/localpools/#{localpool.id}/prices", user
    #     expect(response).to have_http_status(403)
    #     expect(json).to eq denied_json

    #   ensure
    #     localpool.update(readable: :world)
    #   end
    # end

    # it '404' do
    #   POST "/api/v1/groups/localpools/bla-blub/prices", admin
    #   expect(response).to have_http_status(404)
    #   expect(json).to eq not_found_json
    # end

    it '422' do
      # TODO add all possible validation errors, i.e. iban
      POST "/api/v1/groups/localpools/#{localpool.id}/prices", admin,
           name: 'Max Mueller' * 10
      expect(json.to_yaml).to eq validation_json.to_yaml
      expect(response).to have_http_status(422)
    end

    let(:new_price_json) do
      {
        "type"=>'price',
        "name"=>"special",
        "begin_date"=>Date.new(2016, 2, 1).to_s,
        "energyprice_cents_per_kilowatt_hour"=>23.66,
        "baseprice_cents_per_month"=>500,
        'updatable'=>false,
        'deletable'=>false
      }
    end

    let(:new_price) do
      json = new_price_json.dup
      json.delete('type')
      json.delete('updatable')
      json.delete('deletable')
      json
    end

    it '201' do
      POST "/api/v1/groups/localpools/#{localpool.id}/prices", admin, new_price

      expect(response).to have_http_status(201)
      result = json
      id = result.delete('id')
      expect(Price.find(id)).not_to be_nil
      expect(result.to_yaml).to eq new_price_json.to_yaml
    end
  end

  context 'GET' do
    # TODO not sure whether we needs this again. see when tests switch
    #      to a more modular approach

    # it '403' do
    #   begin
    #     localpool.update(readable: :member)

    #     GET "/api/v1/groups/localpools/#{localpool.id}/prices"
    #     expect(response).to have_http_status(403)
    #     expect(json).to eq anonymous_denied_json

    #     GET "/api/v1/groups/localpools/#{localpool.id}/prices", user
    #     expect(response).to have_http_status(403)
    #     expect(json).to eq denied_json

    #   ensure
    #     localpool.update(readable: :world)
    #   end
    # end

    # it '404' do
    #   GET "/api/v1/groups/localpools/bla-blub/prices", admin
    #   expect(response).to have_http_status(404)
    #   expect(json).to eq not_found_json
    # end

    entity!(:prices) do
      [Fabricate(:price, localpool: localpool, begin_date: Date.new(2016, 1, 1)),
       price]
    end

    let(:prices_json) do
      Price.all.collect do |price|
        {
          "id"=>price.id,
          "type"=>"price",
          "name"=>price.name,
          "begin_date"=>price.begin_date.to_s,
          "energyprice_cents_per_kilowatt_hour"=>price.energyprice_cents_per_kilowatt_hour,
          "baseprice_cents_per_month"=>price.baseprice_cents_per_month,
          "updatable"=>false,
          "deletable"=>false
        }
      end
    end

    it '200 all' do
      GET "/api/v1/groups/localpools/#{localpool.id}/prices", admin

      expect(response).to have_http_status(200)
      expect(json.to_yaml).to eq(prices_json.to_yaml)
    end
  end

  context 'PATCH' do

    let(:validation_json) do
      {
        "errors"=>[
          {"parameter"=>"begin_date",
           "detail"=>"must be a date"},
          {"parameter"=>"energyprice_cents_per_kilowatt_hour",
           "detail"=>"must be a float"},
          {"parameter"=>"baseprice_cents_per_month",
           "detail"=>"must be an integer"}
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
      PATCH "/api/v1/groups/localpools/#{localpool.id}/prices/#{price.id}"
      expect(response).to have_http_status(403)
      expect(json).to eq anonymous_denied_json

      PATCH "/api/v1/groups/localpools/#{localpool.id}/prices/#{price.id}", user
      expect(response).to have_http_status(403)
      expect(json).to eq denied_json
    end

    it '404' do
      PATCH "/api/v1/groups/localpools/#{localpool.id}/prices/bla-bla-blub", admin
      expect(response).to have_http_status(404)
      expect(json).to eq not_found_json
    end

    it '422' do
      PATCH "/api/v1/groups/localpools/#{localpool.id}/prices/#{price.id}", admin,
            name: 'Max Mueller' * 10,
            begin_date: 'today',
            energyprice_cents_per_kilowatt_hour: '2.4 Euro',
            baseprice_cents_per_month: 'blablub'

      # TODO fix the lendth constraint of name

      expect(response).to have_http_status(422)
      expect(json).to eq validation_json
    end

    it '200' do
      PATCH "/api/v1/groups/localpools/#{localpool.id}/prices/#{price.id}", admin, name: 'abcd',
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
