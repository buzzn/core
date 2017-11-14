require_relative 'test_admin_localpool_roda'
describe Admin::LocalpoolRoda do

  def app
    TestAdminLocalpoolRoda # this defines the active application for this test
  end

  context 'tariffs' do

    entity!(:localpool) { Fabricate(:localpool) }
    entity!(:tariff) { Fabricate(:tariff, group: localpool)}

    let(:expired_json) do
      {"error" => "This session has expired, please login again."}
    end

    let(:not_found_json) do
      {
        "errors" => [
          {
            "detail"=>"Contract::Tariff: bla-bla-blub not found by User: #{$admin.id}" }
        ]
      }
    end

    let(:wrong_json) do
      {
        "errors"=>[
          {'parameter' => 'name', 'detail' => 'size cannot be greater than 64'},
          {"parameter"=>"begin_date", "detail"=>"must be a date"},
          {"parameter"=>"energyprice_cents_per_kwh", "detail"=>"must be a float"},
          {"parameter"=>"baseprice_cents_per_month", "detail"=>"must be an integer"}
        ]
      }
    end

    context 'POST' do

      it '401' do
        GET "/test/#{localpool.id}/tariffs", $admin
        Timecop.travel(Time.now + 30 * 60) do
          POST "/test/#{localpool.id}/tariffs", $admin

          expect(response).to have_http_status(401)
          expect(json).to eq(expired_json)
        end
      end

      it '422' do
        POST "/test/#{localpool.id}/tariffs", $admin,
             name: 'Max Mueller' * 10,
             begin_date: 'heute-hier-morgen-dort',
             energyprice_cents_per_kwh: 'not so much',
             baseprice_cents_per_month: 'limitless'
        expect(json.to_yaml).to eq wrong_json.to_yaml
        expect(response).to have_http_status(422)
      end

      let(:created_json) do
        {
          "type"=>'contract_tariff',
          "name"=>"special",
          "begin_date"=>Date.new(2016, 2, 1).to_s,
          "end_date" => nil,
          "energyprice_cents_per_kwh"=>23.66,
          "baseprice_cents_per_month"=>500,
          'updatable'=>false,
          'deletable'=>true
        }
      end

      let(:new_tariff) do
        json = created_json.dup
        json.delete('type')
        json.delete('updatable')
        json.delete('deletable')
        json
      end

      it '201' do
        POST "/test/#{localpool.id}/tariffs", $admin, new_tariff

        expect(response).to have_http_status(201)
        result = json
        id = result.delete('id')
        expect(result.delete('updated_at')).not_to be_nil
        expect(Contract::Tariff.find(id)).not_to be_nil
        expect(result.to_yaml).to eq created_json.to_yaml
      end
    end

    context 'GET' do

      entity!(:tariffs) do
        [Fabricate(:tariff, group: localpool, begin_date: Date.new(2016, 1, 1)),
         tariff]
      end

      let(:tariff_json) do
        {
          "id"=>tariff.id,
          "type"=>"contract_tariff",
          'updated_at' => tariff.updated_at.as_json,
          "name"=>tariff.name,
          "begin_date"=>tariff.begin_date.to_s,
          'end_date' => nil,
          "energyprice_cents_per_kwh"=>tariff.energyprice_cents_per_kwh,
          "baseprice_cents_per_month"=>tariff.baseprice_cents_per_month,
          "updatable"=>false,
          "deletable"=>true
        }
      end

      let(:tariffs_json) do
        localpool.tariffs.collect do |tariff|
          {
            "id"=>tariff.id,
            "type"=>"contract_tariff",
            'updated_at' => tariff.updated_at.as_json,
            "name"=>tariff.name,
            "begin_date"=>tariff.begin_date.to_s,
            'end_date' => nil,
            "energyprice_cents_per_kwh"=>tariff.energyprice_cents_per_kwh,
            "baseprice_cents_per_month"=>tariff.baseprice_cents_per_month,
            "updatable"=>false,
            "deletable"=>true
          }
        end
      end

      it '401' do
        GET "/test/#{localpool.id}/tariffs", $admin
        Timecop.travel(Time.now + 30 * 60) do
          GET "/test/#{localpool.id}/tariffs", $admin

          expect(response).to have_http_status(401)
          expect(json).to eq(expired_json)
          GET "/test/#{localpool.id}/tariffs/#{tariff.id}", $admin

          expect(response).to have_http_status(401)
          expect(json).to eq(expired_json)
        end
      end

      it '200' do
        GET "/test/#{localpool.id}/tariffs/#{tariff.id}", $admin

        expect(response).to have_http_status(200)
        expect(json.to_yaml).to eq(tariff_json.to_yaml)
      end
      it '200 all' do
        GET "/test/#{localpool.id}/tariffs", $admin

        expect(response).to have_http_status(200)
        expect(json['array'].to_yaml).to eq(tariffs_json.to_yaml)
      end
    end

    context 'DELETE' do

      #let(:tariff) { Fabricate(:tariff, group: localpool)}

      it '401' do
        GET "/test/#{localpool.id}/tariffs/#{tariff.id}", $admin
        Timecop.travel(Time.now + 30 * 60) do
          DELETE "/test/#{localpool.id}/tariffs/#{tariff.id}", $admin

          expect(response).to have_http_status(401)
          expect(json).to eq(expired_json)
        end
      end

      it '404' do
        DELETE "/test/#{localpool.id}/tariffs/bla-bla-blub", $admin
        expect(response).to have_http_status(404)
        expect(json).to eq not_found_json
      end

      it '204' do
        size = Contract::Tariff.all.size

        DELETE "/test/#{localpool.id}/tariffs/#{tariff.id}", $admin
        expect(response).to have_http_status(204)
        expect(Contract::Tariff.all.size).to eq size - 1

        # recreate deleted
        Contract::Tariff.create tariff.attributes
      end
    end
  end
end
