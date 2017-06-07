describe "groups" do

  def app
    CoreRoda # this defines the active application for this test
  end

  entity!(:admin) { Fabricate(:admin_token) }

  entity!(:user) { Fabricate(:user_token) }

  entity!(:other) { Fabricate(:user_token) }

  let(:denied_json) do
    {
      "errors" => [
        {
          "detail"=>"retrieve Group::Base: permission denied for User: #{user.resource_owner_id}" }
      ]
    }
  end

  let(:not_found_json) do
    {
      "errors" => [
        {
          "detail"=>"Group::Base: bla-blub not found by User: #{admin.resource_owner_id}"
        }
      ]
    }
  end

  entity!(:tribe) { Fabricate(:tribe) }

  entity!(:localpool) { Fabricate(:localpool) }

  entity!(:group) do
    group = Fabricate(:localpool)
    User.find(user.resource_owner_id).add_role(:localpool_manager, group)
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
        "updatable"=>false,
        "deletable"=>false,
        "meters"=>{
          'array'=>group.meters.collect do |meter|
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
          end
        },
        "managers"=>{
          'array'=>group.managers.collect do |manager|
            {
              "id"=>manager.id,
              "type"=>"user",
              "user_name"=>manager.user_name,
              "title"=>manager.profile.title,
              "first_name"=>manager.first_name,
              "last_name"=>manager.last_name,
              "gender"=>manager.profile.gender,
              "phone"=>manager.profile.phone,
              "email"=>manager.email,
              "image"=>manager.profile.image.md.url,
              "updatable"=>false,
              "deletable"=>false
            }
          end
        }
      }
    end

    let(:admin_group_json) do
      json = group_json.dup
      #json['updatable']=true
      #json['deletable']=true
      #(json['managers'] + json['meters']).each do |m|
      #  m['updatable'] = true
      #  m['deletable'] = true
      #end
      json
    end

    let(:empty_json) do
      []
    end

    let(:groups_json) do
      group_data = group_json.dup
      group_data['readable'] = 'member'
      [
        group_data
      ]
    end

    let(:filtered_admin_groups_json) do
      group_data = admin_group_json.dup
      group_data['readable'] = 'member'
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
#          rel["localpool_processing_contract"] = nil
#          rel["metering_point_operator_contract"] = nil
#          rel["localpool_power_taker_contracts"] = []
#          rel["prices"] = []
#          rel["billing_cycles"] = []
        end
        json = {
          "id"=>group.id,
          "type"=>"group_#{type}",
          "name"=>group.name,
          "description"=>group.description,
          "readable"=>group.readable,
          "updatable"=>false,
          "deletable"=>false,
          "meters"=>{
            'array'=>group.meters.collect do |meter|
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
            end
          },
          "managers"=>{
            'array'=>group.managers.collect do |manager|
              {
                "id"=>manager.id,
                "type"=>"user",
                "user_name"=>manager.user_name,
                "title"=>manager.profile.title,
                "first_name"=>manager.first_name,
                "last_name"=>manager.last_name,
                "gender"=>manager.profile.gender,
                "phone"=>manager.profile.phone,
                "email"=>manager.email,
                "image"=>manager.profile.image.md.url,
                "updatable"=>false,
                "deletable"=>false,
              }
            end
          },
        }.merge(rel)
      end
    end

    xit '403' do
      begin
        tribe.update(readable: :member)
        GET "/api/v1/groups/#{tribe.id}", user
        expect(response).to have_http_status(403)
        expect(json).to eq denied_json
      ensure
        tribe.update(readable: :world)
      end
    end

    it '404' do
      GET "/api/v1/groups/bla-blub", admin
      expect(response).to have_http_status(404)
      expect(json).to eq not_found_json
    end

    it '200' do
      GET "/api/v1/groups/#{group.id}?include=meters,managers", user
      expect(response).to have_http_status(200)
      expect(json.to_yaml).to eq group_json.to_yaml

      GET "/api/v1/groups/#{group.id}?include=meters,managers", admin
      expect(response).to have_http_status(200)
      expect(json.to_yaml).to eq admin_group_json.to_yaml
    end

    it '200 all' do
      begin
        Group::Base.update_all(readable: :member)

        GET "/api/v1/groups"
        expect(response).to have_http_status(200)
        expect(json['array'].to_yaml).to eq empty_json.to_yaml

        GET "/api/v1/groups?include=meters,managers", user
        expect(response).to have_http_status(200)
        expect(json['array'].to_yaml).to eq groups_json.to_yaml

        GET "/api/v1/groups?include=meters,managers", admin
        expect(response).to have_http_status(200)
        expect(sort(json['array']).to_yaml).to eq sort(admin_groups_json).to_yaml
      ensure
        Group::Base.update_all(readable: :world)
      end
    end

    it '200 all filtered' do
      begin
        Group::Base.update_all(readable: :member)

        GET "/api/v1/groups"
        expect(response).to have_http_status(200)
        expect(json['array'].to_yaml).to eq empty_json.to_yaml

        GET "/api/v1/groups", user, filter: 'blabla'
        expect(response).to have_http_status(200)
        expect(json['array'].to_yaml).to eq empty_json.to_yaml

        GET "/api/v1/groups", other, filter: group.name
        expect(response).to have_http_status(200)
        expect(json['array'].to_yaml).to eq empty_json.to_yaml

        GET "/api/v1/groups?include=meters,managers", user, filter: group.name
        expect(response).to have_http_status(200)
        expect(json['array'].to_yaml).to eq groups_json.to_yaml

        GET "/api/v1/groups", admin, filter: 'blabla'
        expect(response).to have_http_status(200)
        expect(json['array'].to_yaml).to eq empty_json.to_yaml

        GET "/api/v1/groups?include=meters,managers", admin, filter: group.name
        expect(response).to have_http_status(200)
        expect(json['array'].to_yaml).to eq filtered_admin_groups_json.to_yaml
      ensure
        Group::Base.update_all(readable: :world)
      end
    end
  end

  context 'mentors' do

    context 'GET' do
      xit '403' do
        begin
          localpool.update(readable: :member)
          GET "/api/v1/groups/#{localpool.id}/mentors"
          expect(response).to have_http_status(403)
          expect(json).to eq anonymous_denied_json

          tribe.update(readable: :member)
          GET "/api/v1/groups/#{tribe.id}/mentors", user
          expect(response).to have_http_status(403)
          expect(json).to eq denied_json
        ensure
          localpool.update(readable: :world)
          tribe.update(readable: :world)
        end
      end

      it '404' do
        GET "/api/v1/groups/bla-blub/mentors", admin
        expect(response).to have_http_status(404)
        expect(json).to eq not_found_json
      end

      [:tribe, :localpool].each do |type|
        entity(:manager) { Fabricate(:user) }
        let(:group) do
          group = send type
          manager.add_role(:manager, group)
          group
        end

        let(:managers_json) do
          [
            {
              "id"=>manager.id,
              "type"=>"user",
              "first_name"=>manager.profile.first_name,
              "last_name"=>manager.profile.last_name,
              "image"=>manager.image.md.url,
            }
          ]
        end

        context "as #{type}" do
          it "200 as #{type}" do
            GET "/api/v1/groups/#{group.id}/mentors", admin
          
            expect(response).to have_http_status(200)
            expect(json.to_yaml).to eq(managers_json.to_yaml)
          end
        end
      end
    end
  end

  context 'meters' do

    context 'GET' do
      xit '403' do
        begin
          tribe.update(readable: :member)
          GET "/api/v1/groups/#{tribe.id}/meters", user
          expect(response).to have_http_status(403)
          expect(json).to eq denied_json
        ensure
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

          let(:minimal_meter_json) do
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
              end
              json
            end
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
                json["registers"]={
                  'array'=> meter.registers.collect do |register|
                    {
                      "id"=>register.id,
                      "type"=>'register_real',
                      "direction"=>register.direction.to_s,
                      "name"=>register.name,
                      "pre_decimal"=>register.digits_before_comma,
                      "decimal"=>register.decimal_digits,
                      "converter_constant"=>1,
                      "low_power"=>register.low_load_ability,
                        "label"=>register.label,
                        "last_reading"=>0,
                        "uid"=>register.uid,
                        "obis"=>register.obis
                    }
                  end                  
                }
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
                  "label"=>meter.register.label,
                  "last_reading"=>0
                }
              end
              json
            end
          end

          it '200' do
            GET "/api/v1/groups/#{group.id}/meters", admin, include: 'registers,register'

            expect(response).to have_http_status(200)
            expect(json['array'].to_yaml).to eq(meter_json.to_yaml)

            GET "/api/v1/groups/#{group.id}/meters?include=", admin

            expect(response).to have_http_status(200)
            expect(json['array'].to_yaml).to eq(minimal_meter_json.to_yaml)
          end
        end
      end
    end
  end
end
