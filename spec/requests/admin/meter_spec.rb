# coding: utf-8
# coding: utf-8
describe Admin::LocalpoolRoda do

  def app
    Admin::LocalpoolRoda # this defines the active application for this test
  end

  context 'meters' do

    entity(:admin) { Fabricate(:admin_token) }

    entity(:user) { Fabricate(:user_token) }

    entity(:group) do
      group = Fabricate(:localpool)
      User.find(user.resource_owner_id).add_role(:localpool_member, group)
      group
    end

    let(:denied_json) do
      {
        "errors" => [
          {
            "detail"=>"retrieve Meter::Real: #{real_meter.id} permission denied for User: #{user.resource_owner_id}" }
        ]
      }
    end

    let(:not_found_json) do
      {
        "errors" => [
          {
            "detail"=>"Meter::Base: bla-blub not found by User: #{admin.resource_owner_id}"
          }
        ]
      }
    end

    entity(:virtual_meter) { Fabricate(:virtual_meter) }

    entity(:real_meter) { Fabricate(:meter) }

    entity(:meter) do
      meter = Fabricate(:input_meter)
      meter.input_register.update(group: group)
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
          "registers"=>{
            'array'=>[
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
                "obis"=>meter.input_register.obis
              }
            ]
          }
        }
      end

      it '403' do
        GET "/#{group.id}/meters/#{real_meter.id}", user
        expect(response).to have_http_status(403)
        expect(json).to eq denied_json
      end

      it '404' do
        GET "/#{group.id}/meters/bla-blub", admin
        expect(response).to have_http_status(404)
        expect(json).to eq not_found_json
      end

      it '200' do
        GET "/#{group.id}/meters/#{meter.id}", admin, include: :registers
        expect(response).to have_http_status(200)
        expect(json.to_yaml).to eq meter_json.to_yaml
      end
    end

    # NOT IMPLEMENTED CURRENTLY
    #     also not sure whether or not it come back like this, i.e. keep it

    # context 'virtual/register' do

    #   let(:meter) { virtual_meter }

    #   let(:register) do
    #     meter.register.tap do |register|
    #       Fabricate(:reading, register_id: register.id)
    #     end
    #   end

    #   let(:register_denied_json) do
    #     json = denied_json.dup
    #     json['errors'][0]['detail'].sub! 'Base', "Virtual"
    #     json
    #   end

    #   let(:virtual_not_found_json) do
    #     json = not_found_json.dup
    #     json['errors'][0]['detail'].sub! 'BaseResource', 'Virtual'
    #     json
    #   end

    #   let(:register_json) do
    #     {
    #       "id"=>register.id,
    #       "type"=>"register_virtual",
    #       "direction"=>register.direction.to_s,
    #       "name"=>register.name,
    #       "pre_decimal"=>6,
    #       "decimal"=>2,
    #       "converter_constant"=>1,
    #       "low_power"=>false,
    #       "label"=>register.label,
    #       "last_reading"=>Reading.by_register_id(register.id).last.energy_milliwatt_hour,
    #       "group"=>nil
    #     }
    #   end

    #   context 'GET' do
    #     it '403' do
    #       GET "/#{group.id}/meters/virtual/#{meter.id}/register", user
    #       expect(response).to have_http_status(403)
    #       expect(json).to eq register_denied_json
    #     end

    #     it '404' do
    #       GET "/#{group.id}/meters/virtual/bla-blub/register", admin
    #       expect(response).to have_http_status(404)
    #       expect(json).to eq virtual_not_found_json
    #     end

    #     it '200' do
    #       register # setup
    #       GET "/#{group.id}/meters/virtual/#{meter.id}/register", admin, include: :group
    #       expect(response).to have_http_status(200)
    #       expect(json.to_yaml).to eq(register_json.to_yaml)
    #     end
    #   end
    # end

    # context 'real/registers' do

    #   let(:meter) { real_meter }

    #   let(:registers) do
    #     meter.registers.each do |register|
    #       Fabricate(:reading, register_id: register.id)
    #     end
    #   end

    #   let(:registers_denied_json) do
    #     json = denied_json.dup
    #     json['errors'][0]['detail'].sub! 'Base', "Real"
    #     json
    #   end

    #   let(:real_not_found_json) do
    #     json = not_found_json.dup
    #     json['errors'][0]['detail'].sub! 'BaseResource', 'Real'
    #     json
    #   end

    #   let(:registers_json) do
    #     register = registers.first
    #     [
    #       {
    #         "id"=>register.id,
    #         "type"=>"register_real",
    #         "direction"=>register.direction.to_s,
    #         "name"=>register.name,
    #         "pre_decimal"=>6,
    #         "decimal"=>2,
    #         "converter_constant"=>1,
    #         "low_power"=>false,
    #         "label"=>register.label,
    #         "last_reading"=>Reading.by_register_id(register.id).last.energy_milliwatt_hour,
    #         "uid"=>register.uid,
    #         "obis"=>register.obis,
    #         "group"=>nil,
    #         "devices"=> { 'array'=>[] },
    #       }
    #     ]
    #   end

    #   context 'GET' do
    #     it '403' do
    #       GET "/#{group.id}/meters/real/#{meter.id}/registers", user
    #       expect(response).to have_http_status(403)
    #       expect(json).to eq registers_denied_json
    #     end

    #     it '404' do
    #       GET "/#{group.id}/meters/real/bla-blub/registers", admin
    #       expect(response).to have_http_status(404)
    #       expect(json).to eq real_not_found_json
    #     end

    #     it '200' do
    #       registers # setup
    #       GET "/#{group.id}/meters/real/#{meter.id}/registers?include=group,devices", admin
    #       expect(response).to have_http_status(200)
    #       expect(json['array'].to_yaml).to eq(registers_json.to_yaml)
    #     end
    #   end
    # end
  end
end
