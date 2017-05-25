# coding: utf-8
describe "meters" do

  def app
    CoreRoda # this defines the active application for this test
  end

  entity(:admin) { Fabricate(:admin_token) }

  entity(:user) { Fabricate(:user_token) }

  let(:anonymous_denied_json) do
    {
      "errors" => [
        {
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
        {
          "detail"=>"Meter::Base: bla-blub not found"
        }
      ]
    }
  end

  let(:not_found_json) do
    json = anonymous_not_found_json.dup
    json['errors'][0]['detail'] = "Meter::Base: bla-blub not found by User: #{admin.resource_owner_id}"
    json
  end

  entity(:virtual_meter) { Fabricate(:virtual_meter) }

  entity(:real_meter) { Fabricate(:meter) }

  entity(:meter) do
    meter = Fabricate(:input_meter)
    User.find(user.resource_owner_id).add_role(:manager, meter.input_register)
    meter
  end


  context 'GET' do

    let(:meter_json) do
      {
        "id"=>meter.id,
        "type"=>"meter_real",
        "manufacturer_name"=>meter.manufacturer_name,
        "manufacturer_product_name"=>meter.manufacturer_product_name,
        "manufacturer_product_serialnumber"=>meter.manufacturer_product_serialnumber,
        "metering_type"=>meter.metering_type,
        "meter_size"=>nil,
        "ownership"=>nil,
        "direction_label"=>meter.direction,
        "build_year"=>nil,
        "updatable"=>true,
        "deletable"=>true,
        "smart"=>false,
        "registers"=>[
          {
            "id"=>meter.input_register.id,
            "type"=>"register_real",
            "direction"=>meter.input_register.direction.to_s,
            "name"=>meter.input_register.name,
            "pre_decimal"=>6,
            "decimal"=>2,
            "converter_constant"=>1,
            "low_power"=>false,
            "label"=>meter.input_register.label,
            "last_reading"=>0,
            "uid"=>meter.input_register.uid,
            "obis"=>meter.input_register.obis,
            "group"=>nil,
            "devices"=>[]
          }
        ]
      }
    end

    let(:admin_meter_json) do
      json = meter_json.dup
      json['updatable']=true
      json['deletable']=true
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
      expect(json.to_yaml).to eq meter_json.to_yaml

      GET "/api/v1/meters/#{meter.id}", admin
      expect(response).to have_http_status(200)
      expect(json.to_yaml).to eq admin_meter_json.to_yaml
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
        "id"=>register.id,
        "type"=>"register_virtual",
        "direction"=>register.direction.to_s,
        "name"=>register.name,
        "pre_decimal"=>6,
        "decimal"=>2,
        "converter_constant"=>1,
        "low_power"=>false,
        "label"=>register.label,
        "last_reading"=>Reading.by_register_id(register.id).last.energy_milliwatt_hour,
        "group"=>nil
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
      [
        {
          "id"=>register.id,
          "type"=>"register_real",
          "direction"=>register.direction.to_s,
          "name"=>register.name,
          "pre_decimal"=>6,
          "decimal"=>2,
          "converter_constant"=>1,
          "low_power"=>false,
          "label"=>register.label,
          "last_reading"=>Reading.by_register_id(register.id).last.energy_milliwatt_hour,
          "uid"=>register.uid,
          "obis"=>register.obis,
          "group"=>nil,
          "devices"=>[],
        }
      ]
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
