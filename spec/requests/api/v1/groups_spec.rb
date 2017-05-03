describe "groups" do

  entity(:admin) { Fabricate(:admin_token) }

  entity(:user) { Fabricate(:user_token) }

  entity(:other) { Fabricate(:user_token) }

  let(:anonymous_denied_json) do
    {
      "errors" => [
        { "title"=>"Permission Denied",
          "detail"=>"retrieve Group::Base: permission denied for User: --anonymous--" }
      ]
    }
  end

  let(:denied_json) do
    json = anonymous_denied_json.dup
    json['errors'][0]['detail'].sub! /--anonymous--/, user.resource_owner_id
    json
  end

  let(:anonymous_not_found_json) do
    {
      "errors" => [
        { "title"=>"Record Not Found",
          "detail"=>"Group::Base: bla-blub not found" }
      ]
    }
  end

  let(:not_found_json) do
    json = anonymous_not_found_json.dup
    json['errors'][0]['detail'] = "Group::Base: bla-blub not found by User: #{admin.resource_owner_id}"
    json
  end

  entity!(:tribe) { Fabricate(:tribe) }

  entity!(:localpool) { Fabricate(:localpool) }

  entity!(:group) do
    group = Fabricate(:localpool)
    User.find(user.resource_owner_id).add_role(:manager, group)
    group
  end

  context 'GET' do

    let(:group_json) do
      {
        "id"=>group.id,
        "type"=>"group_localpool",
        "name"=>group.name,
        "description"=>group.description,
        "readable"=>group.readable,
        "updatable"=>true,
        "deletable"=>true,
        "registers"=>[],
        "meters"=>group.meters.collect do |meter|
          json = {
            "id"=>meter.id,
            'type'=>'meter_virtual',
            "manufacturer_name"=>meter.manufacturer_name,
            "manufacturer_product_name"=>meter.manufacturer_product_name,
            "manufacturer_product_serialnumber"=>meter.manufacturer_product_serialnumber,
            "metering_type"=>meter.metering_type,
            "meter_size"=>meter.meter_size,
            "ownership"=>meter.ownership,
            "direction_label"=>meter.direction,
            "build_year"=>meter.build_year ? meter.build_year.to_s : nil,
            "updatable"=>false,
            "deletable"=>false,
          }
          json['smart'] = true if meter.is_a? Meter::Real
          json
        end,
        "managers"=>group.managers.collect do |manager|
          {
            "id"=>manager.id,
            "type"=>"user",
            "updatable"=>false,
            "deletable"=>false,
          }
        end,
        "energy_producers"=>[],
        "energy_consumers"=>[],
        "localpool_processing_contract"=>nil,
        "metering_point_operator_contract"=>nil
      }
    end

    let(:admin_group_json) do
      json = group_json.dup
      json['updatable']=true
      json['deletable']=true
      json
    end

    let(:empty_json) do
      []
    end

    let(:groups_json) do
      group_data = group_json.dup
      group_data['updatable'] = false
      group_data['deletable'] = false
      group_data['readable'] = 'member'
      group_data['managers'] = []
      [
        group_data
      ]
    end

    let(:filtered_admin_groups_json) do      
      group_data = admin_group_json.dup
      group_data['updatable'] = false
      group_data['deletable'] = false
      group_data['readable'] = 'member'
      group_data['managers'] = []
      [
        group_data
      ]
    end

    let(:admin_groups_json) do  
      Group::Base.all.collect do |group|
        rel = {}
        if group.is_a? Group::Tribe
          type = :tribe
        else
          type = :localpool
          rel["localpool_processing_contract"] = nil
          rel["metering_point_operator_contract"] = nil
        end
        json = {
          "id"=>group.id,
          "type"=>"group_#{type}",
          "name"=>group.name,
          "description"=>group.description,
          "readable"=>group.readable,
          "updatable"=>false,
          "deletable"=>false,
          "registers"=>[],
          "meters"=>group.meters.collect do |meter|
            json = {
              "id"=>meter.id,
              'type'=>meter.class.to_s.downcase.sub('::', '_'),
              "manufacturer_name"=>meter.manufacturer_name,
              "manufacturer_product_name"=>meter.manufacturer_product_name,
              "manufacturer_product_serialnumber"=>meter.manufacturer_product_serialnumber,
              "metering_type"=>meter.metering_type,
              "meter_size"=>meter.meter_size,
              "ownership"=>meter.ownership,
              "direction_label"=>meter.direction,
              "build_year"=>meter.build_year ? meter.build_year.to_s : nil,
              "updatable"=>false,
              "deletable"=>false,
            }
            json['smart'] = meter.smart if meter.is_a? Meter::Real
            json
          end,
          "managers"=>[],
          "energy_producers"=>[],
          "energy_consumers"=>[]
        }.merge(rel)
      end
    end

    it '403' do
      begin
        localpool.update(readable: :member)
        GET "/api/v1/groups/#{localpool.id}"
        expect(response).to have_http_status(403)
        expect(json).to eq anonymous_denied_json

        tribe.update(readable: :member)
        GET "/api/v1/groups/#{tribe.id}", user
        expect(response).to have_http_status(403)
        expect(json).to eq denied_json
      ensure
        localpool.update(readable: :world)
        tribe.update(readable: :world)
      end
    end

    it '404' do
      GET "/api/v1/groups/bla-blub"
      expect(response).to have_http_status(404)
      expect(json).to eq anonymous_not_found_json

      GET "/api/v1/groups/bla-blub", admin
      expect(response).to have_http_status(404)
      expect(json).to eq not_found_json
    end

    it '200' do
      GET "/api/v1/groups/#{group.id}", user
      expect(response).to have_http_status(200)
      expect(json.to_yaml).to eq group_json.to_yaml

      GET "/api/v1/groups/#{group.id}", admin
      expect(response).to have_http_status(200)
      expect(json).to eq admin_group_json
    end

    it '200 all' do
      begin
        Group::Base.update_all(readable: :member)

        GET "/api/v1/groups"
        expect(response).to have_http_status(200)
        expect(json.to_yaml).to eq empty_json.to_yaml

        GET "/api/v1/groups", user
        expect(response).to have_http_status(200)
        expect(json.to_yaml).to eq groups_json.to_yaml

        GET "/api/v1/groups", admin
        expect(response).to have_http_status(200)
        expect(json.sort {|n,m| n['id'] <=> m['id']}.to_yaml).to eq admin_groups_json.sort {|n,m| n['id'] <=> m['id']}.to_yaml
      ensure
        Group::Base.update_all(readable: :world)
      end
    end

    it '200 all filtered' do
      begin
        Group::Base.update_all(readable: :member)

        GET "/api/v1/groups"
        expect(response).to have_http_status(200)
        expect(json.to_yaml).to eq empty_json.to_yaml

        GET "/api/v1/groups", user, filter: 'blabla'
        expect(response).to have_http_status(200)
        expect(json.to_yaml).to eq empty_json.to_yaml

        GET "/api/v1/groups", other, filter: group.name
        expect(response).to have_http_status(200)
        expect(json.to_yaml).to eq empty_json.to_yaml

        GET "/api/v1/groups", user, filter: group.name
        expect(response).to have_http_status(200)
        expect(json.to_yaml).to eq groups_json.to_yaml

        GET "/api/v1/groups", admin, filter: 'blabla'
        expect(response).to have_http_status(200)
        expect(json.to_yaml).to eq empty_json.to_yaml

        GET "/api/v1/groups", admin, filter: group.name
        expect(response).to have_http_status(200)
        expect(json.to_yaml).to eq filtered_admin_groups_json.to_yaml
      ensure
        Group::Base.update_all(readable: :world)
      end
    end
  end

  context 'meters' do

    context 'GET' do
      it '403' do
        begin
          localpool.update(readable: :member)
          GET "/api/v1/groups/#{localpool.id}/meters"
          expect(response).to have_http_status(403)
          expect(json).to eq anonymous_denied_json

          tribe.update(readable: :member)
          GET "/api/v1/groups/#{tribe.id}/meters", user
          expect(response).to have_http_status(403)
          expect(json).to eq denied_json
        ensure
          localpool.update(readable: :world)
          tribe.update(readable: :world)
        end
      end

      it '404' do
        GET "/api/v1/groups/bla-blub/meters", admin
        expect(response).to have_http_status(404)
        expect(json).to eq not_found_json
      end

      [:tribe, :localpool].each do |type|
        context "as #{type}" do

          let(:group) { send type }

          let!(:meters) do
            2.times.collect do
              meter = Fabricate(:meter)
              meter.registers.each do |r|
                r.group = group
                r.save
              end
              meter
            end
            group.meters
          end

          let(:meter_json) do
            meters.collect do |meter|
              json =
                {
                  "id"=>meter.id,
                  "type"=>"meter_#{meter.is_a?(Meter::Virtual) ? 'virtual': 'real'}",
                  "manufacturer_name"=>meter.manufacturer_name,
                  "manufacturer_product_name"=>meter.manufacturer_product_name,
                  "manufacturer_product_serialnumber"=>meter.manufacturer_product_serialnumber,
                  "metering_type"=>meter.metering_type,
                  "meter_size"=>meter.meter_size,
                  "ownership"=>meter.ownership,
                  "direction_label"=>meter.direction,
                  "build_year"=>meter.build_year ? meter.build_year.to_s : nil,
                  "updatable"=>false,
                  "deletable"=>false
                }
              if meter.is_a? Meter::Real
                json['smart'] = false
                # NOTE not sure why it renders empty array here
                json["registers"]=[]
              else
                json["register"]={
                  "id"=>meter.register.id,
                  "type"=>'register_virtual',
                  "direction"=>meter.register.direction.to_s,
                  "name"=>meter.register.name,
                  "pre_decimal"=>nil,
                  "decimal"=>nil,
                  "converter_constant"=>1,
                  "low_power"=>nil,
                  "last_reading"=>0
                }
              end
              json
            end
          end

          it '200' do
            GET "/api/v1/groups/#{group.id}/meters", admin

            expect(response).to have_http_status(200)
            expect(json.to_yaml).to eq(meter_json.to_yaml)
          end
        end
      end
    end
  end


  xit 'gets all prices for the localpool only with full token' do
    group = Fabricate(:localpool)
    price_1 = Fabricate(:price, localpool: group, begin_date: Date.new(2016, 1, 1))
    price_2 = Fabricate(:price, localpool: group)

    full_access_token = Fabricate(:full_access_token)
    get_with_token "/api/v1/groups/localpools/#{group.id}/prices", full_access_token.token
    # TODO: should this request return a 403 instead of an empty array?
    expect(response).to have_http_status(200)
    expect(json['data']).to eq []

    manager_access_token = Fabricate(:full_access_token)
    manager_user          = User.find(manager_access_token.resource_owner_id)
    manager_user.add_role(:manager, group)
    get_with_token "/api/v1/groups/localpools/#{group.id}/prices", manager_access_token.token
    expect(response).to have_http_status(200)

    expect(json['data'][0]['id']).to eq(price_1.id)
    expect(json['data'][0]['type']).to eq('prices')
    expect(json['data'][1]['id']).to eq(price_2.id)
    expect(json['data'][1]['type']).to eq('prices')
  end

  xit 'creates new price for localpool only with full token' do
    group = Fabricate(:localpool)

    request_params = {
      name: "special",
      begin_date: Date.new(2016, 1, 1),
      energyprice_cents_per_kilowatt_hour: 23.66,
      baseprice_cents_per_month: 500
    }.to_json

    full_access_token = Fabricate(:full_access_token)
    POST "/api/v1/groups/localpools/#{group.id}/price", full_access_token, request_params
    expect(response).to have_http_status(403)

    manager_access_token = Fabricate(:full_access_token)
    manager_user          = User.find(manager_access_token.resource_owner_id)
    manager_user.add_role(:manager, group)
    POST "/api/v1/groups/localpools/#{group.id}/price", manager_access_token, request_params
    expect(response).to have_http_status(201)
    expect(json['data']['id']).not_to eq nil
  end
end
