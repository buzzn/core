describe Admin::LocalpoolRoda do

  def app
    Admin::LocalpoolRoda # this defines the active application for this test
  end

  context 'prices' do

    entity(:user) { Fabricate(:user_token) }
    entity(:admin) { Fabricate(:admin_token) }
    entity(:localpool) { Fabricate(:localpool) }
    entity(:price) { Fabricate(:price, localpool: localpool)}
    
    let(:denied_json) do
      {
        "errors" => [
          {
            "detail"=>"retrieve PriceResource: permission denied for User: #{user.resource_owner_id}" }
        ]
      }
    end

    let(:not_found_json) do
      {
        "errors" => [
          {
            "detail"=>"Price: bla-bla-blub not found by User: #{admin.resource_owner_id}" }
        ]
      }
    end

    let(:wrong_json) do
      {
        "errors"=>[
          {"parameter"=>"begin_date", "detail"=>"must be a date"},
          {"parameter"=>"energyprice_cents_per_kilowatt_hour", "detail"=>"must be a float"},
          {"parameter"=>"baseprice_cents_per_month", "detail"=>"must be an integer"}
        ]
      }
    end

    context 'POST' do

      it '422' do
        POST "/#{localpool.id}/prices", admin,
             name: 'Max Mueller' * 10,
             begin_date: 'heute-hier-morgen-dort',
             energyprice_cents_per_kilowatt_hour: 'not so much',
             baseprice_cents_per_month: 'limitless'
        expect(json.to_yaml).to eq wrong_json.to_yaml
        expect(response).to have_http_status(422)
      end

      let(:created_json) do
        {
          "type"=>'price',
          "name"=>"special",
          "begin_date"=>Date.new(2016, 2, 1).to_s,
          "energyprice_cents_per_kilowatt_hour"=>23.66,
          "baseprice_cents_per_month"=>500,
          'updatable'=>true,
          'deletable'=>true
        }
      end

      let(:new_price) do
        json = created_json.dup
        json.delete('type')
        json.delete('updatable')
        json.delete('deletable')
        json
      end

      it '201' do
        POST "/#{localpool.id}/prices", admin, new_price

        expect(response).to have_http_status(201)
        result = json
        id = result.delete('id')
        expect(result.delete('updated_at')).not_to be_nil
        expect(Price.find(id)).not_to be_nil
        expect(result.to_yaml).to eq created_json.to_yaml
      end
    end

    context 'GET' do

      entity!(:prices) do
        [Fabricate(:price, localpool: localpool, begin_date: Date.new(2016, 1, 1)),
         price]
      end

      let(:prices_json) do
        localpool.prices.collect do |price|
          {
            "id"=>price.id,
            "type"=>"price",
            'updated_at'=>price.updated_at.as_json,
            "name"=>price.name,
            "begin_date"=>price.begin_date.to_s,
            "energyprice_cents_per_kilowatt_hour"=>price.energyprice_cents_per_kilowatt_hour,
            "baseprice_cents_per_month"=>price.baseprice_cents_per_month,
            "updatable"=>true,
            "deletable"=>true
          }
        end
      end

      it '200 all' do
        GET "/#{localpool.id}/prices", admin

        expect(response).to have_http_status(200)
        expect(json['array'].to_yaml).to eq(prices_json.to_yaml)
      end
    end

    context 'PATCH' do

      let(:wrong_json) do
        {
          "errors"=>[
            {"parameter"=>"updated_at",
             "detail"=>"is missing"},
            {"parameter"=>"begin_date",
             "detail"=>"must be a date"},
            {"parameter"=>"energyprice_cents_per_kilowatt_hour",
             "detail"=>"must be a float"},
            {"parameter"=>"baseprice_cents_per_month",
             "detail"=>"must be an integer"}
          ]
        }
      end

      let(:stale_json) do
        {
          "errors" => [
            {"detail"=>"Price: #{price.id} was updated at: #{price.updated_at}"}]
        }
      end

      let(:updated_json) do
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

      it '404' do
        PATCH "/#{localpool.id}/prices/bla-bla-blub", admin
        expect(response).to have_http_status(404)
        expect(json).to eq not_found_json
      end

      it '409' do
        PATCH "/#{localpool.id}/prices/#{price.id}", admin,
              updated_at: DateTime.now

        expect(response).to have_http_status(409)
        expect(json.to_yaml).to eq stale_json.to_yaml
      end

      it '422' do
        PATCH "/#{localpool.id}/prices/#{price.id}", admin,
              name: 'Max Mueller' * 10,
              begin_date: 'today',
              energyprice_cents_per_kilowatt_hour: '2.4 Euro',
              baseprice_cents_per_month: 'blablub'

        expect(response).to have_http_status(422)
        expect(json.to_yaml).to eq wrong_json.to_yaml
      end

      it '200' do
        old = price.updated_at
        PATCH "/#{localpool.id}/prices/#{price.id}", admin,
              updated_at: price.updated_at,
              name: 'abcd',
              begin_date: Date.new(2015, 1, 1),
              energyprice_cents_per_kilowatt_hour: 22.66,
              baseprice_cents_per_month: 400
        
        expect(response).to have_http_status(200)
        price.reload
        expect(price.name).to eq 'abcd'
        expect(price.begin_date).to eq Date.new(2015, 1, 1)
        expect(price.energyprice_cents_per_kilowatt_hour).to eq 22.66
        expect(price.baseprice_cents_per_month).to eq 400

        result = json
        # TODO fix it: our time setup does not allow
        #expect(result.delete('updated_at')).to be > old.as_json
        expect(result.delete('updated_at')).not_to eq old.as_json
        expect(result.to_yaml).to eq updated_json.to_yaml
       end
    end
  end
end
