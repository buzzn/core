# coding: utf-8
describe "meters" do

  let(:admin) do
    entities[:admin] ||= Fabricate(:admin_token)
  end

  let(:user) do
    entities[:user] ||= Fabricate(:user_token)
  end

  let(:anonymous_denied_json) do
    {
      "errors" => [
        { "title"=>"Permission Denied",
          "detail"=>"retrieve Meter::Base: permission denied for User: --anonymous--" }
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
          "detail"=>"Meter::Base: bla-blub not found" }
      ]
    }
  end

  let(:not_found_json) do
    json = anonymous_not_found_json.dup
    json['errors'][0]['detail'] = "Meter::Base: bla-blub not found by User: #{admin.resource_owner_id}"
    json
  end

  let(:virtual_meter) { entities[:virtual_meter] ||= Fabricate(:virtual_meter) }

  let(:real_meter) { entities[:real_meter] ||= Fabricate(:meter) }

  let(:meter) do
    entities[:meter] ||=
      begin
        meter = Fabricate(:input_meter)
        User.find(user.resource_owner_id).add_role(:manager, meter.input_register)
        meter
      end
  end


  context 'GET' do

    let(:meter_json) do
      {
        "data"=>{
          "id"=>meter.id,
          "type"=>"meter-reals",
          "attributes"=>{
            "type"=>"meter_real",
            "manufacturer-name"=>meter.manufacturer_name,
            "manufacturer-product-name"=>meter.manufacturer_product_name,
            "manufacturer-product-serialnumber"=>meter.manufacturer_product_serialnumber,
            "metering-type"=>nil,
            "meter-size"=>nil,
            "ownership"=>nil,
            "direction-label"=>"one_way_meter",
            "build-year"=>nil,
            "updatable"=>true,
            "deletable"=>true,
            "smart"=>false},
          "relationships"=>{
            "registers"=>{
              "data"=>[{"id"=>meter.input_register.id,
                        "type"=>"register-inputs"}]
            }
          }
        }
      }
    end

    let(:admin_meter_json) do
      json = meter_json.dup
      json['data']['attributes']['updatable']=true
      json['data']['attributes']['deletable']=true
      json
    end

    it '403' do
      GET "/api/v1/meters/#{virtual_meter.id}"
      expect(response).to have_http_status(403)
      expect(json).to eq anonymous_denied_json

      GET "/api/v1/meters/#{real_meter.id}", user
      expect(response).to have_http_status(403)
      expect(json).to eq denied_json
    end

    it '404' do
      GET "/api/v1/meters/bla-blub"
      expect(response).to have_http_status(404)
      expect(json).to eq anonymous_not_found_json

      GET "/api/v1/meters/bla-blub", admin
      expect(response).to have_http_status(404)
      expect(json).to eq not_found_json
    end

    it '200' do
      GET "/api/v1/meters/#{meter.id}", user
      expect(response).to have_http_status(200)
      expect(json).to eq meter_json

      GET "/api/v1/meters/#{meter.id}", admin
      expect(response).to have_http_status(200)
      expect(json).to eq admin_meter_json
    end
  end

  context 'virtual/register' do

    let(:meter) { virtual_meter }

    let(:register) do
      meter.register.tap do |register|
        Fabricate(:reading, register_id: register.id)
      end
    end

    let(:register_anonymous_denied_json) do
      json = anonymous_denied_json.dup
      json['errors'][0]['detail'].sub! 'Base', "Virtual"
      json
    end

    let(:register_denied_json) do
      json = denied_json.dup
      json['errors'][0]['detail'].sub! 'Base', "Virtual"
      json
    end

    let(:virtual_not_found_json) do
      json = not_found_json.dup
      json['errors'][0]['detail'].sub! 'Base', 'Virtual'
      json
    end

    let(:register_json) do
      {
        "data"=>{
          "id"=>register.id,
          "type"=>"register-virtuals",
          "attributes"=>{
            "type"=>"register_virtual",
            "direction"=>register.direction.to_s,
            "name"=>register.name,
            "pre-decimal"=>6,
            "decimal"=>2,
            "converter-constant"=>1,
            "low-power"=>false,
            "last-reading"=>Reading.by_register_id(register.id).last.energy_milliwatt_hour
          },
          "relationships"=>{
            "address"=>{"data"=>nil},
            "meter"=>{"data"=>nil}
          }
        }
      }
    end

    context 'GET' do
      it '403' do
        GET "/api/v1/meters/virtual/#{meter.id}/register"
        expect(response).to have_http_status(403)
        expect(json).to eq register_anonymous_denied_json

        GET "/api/v1/meters/virtual/#{meter.id}/register", user
        expect(response).to have_http_status(403)
        expect(json).to eq register_denied_json
      end

      it '404' do
        GET "/api/v1/meters/virtual/bla-blub/register", admin
        expect(response).to have_http_status(404)
        expect(json).to eq virtual_not_found_json
      end

      it '200' do
        register # setup
        GET "/api/v1/meters/virtual/#{meter.id}/register", admin
        expect(response).to have_http_status(200)
        expect(json.to_yaml).to eq(register_json.to_yaml)
      end
    end
  end

  context 'real/registers' do

    let(:meter) { real_meter }

    let(:registers) do
      meter.registers.each do |register|
        Fabricate(:reading, register_id: register.id)
      end
    end

    let(:registers_anonymous_denied_json) do
      json = anonymous_denied_json.dup
      json['errors'][0]['detail'].sub! 'Base', "Real"
      json
    end

    let(:registers_denied_json) do
      json = denied_json.dup
      json['errors'][0]['detail'].sub! 'Base', "Real"
      json
    end

    let(:real_not_found_json) do
      json = not_found_json.dup
      json['errors'][0]['detail'].sub! 'Base', 'Real'
      json
    end

    let(:registers_json) do
      register = registers.first
      {
        "data"=>[
          "id"=>register.id,
          "type"=>"register-#{register.direction}puts",
          "attributes"=>{
            "type"=>"register_real",
            "direction"=>register.direction.to_s,
            "name"=>register.name,
            "pre-decimal"=>6,
            "decimal"=>2,
            "converter-constant"=>1,
            "low-power"=>false,
            "last-reading"=>Reading.by_register_id(register.id).last.energy_milliwatt_hour,
            "uid"=>register.uid,
            "obis"=>register.obis
          },
          "relationships"=>{
            "address"=>{"data"=>nil},
            "meter"=>{"data"=>nil},
          }
        ]
      }
    end

    context 'GET' do
      it '403' do
        GET "/api/v1/meters/real/#{meter.id}/registers"
        expect(response).to have_http_status(403)
        expect(json).to eq registers_anonymous_denied_json

        GET "/api/v1/meters/real/#{meter.id}/registers", user
        expect(response).to have_http_status(403)
        expect(json).to eq registers_denied_json
      end

      it '404' do
        GET "/api/v1/meters/real/bla-blub/registers", admin
        expect(response).to have_http_status(404)
        expect(json).to eq real_not_found_json
      end

      it '200' do
        registers # setup
        GET "/api/v1/meters/real/#{meter.id}/registers", admin
        expect(response).to have_http_status(200)
        expect(json.to_yaml).to eq(registers_json.to_yaml)
      end
    end
  end
end
