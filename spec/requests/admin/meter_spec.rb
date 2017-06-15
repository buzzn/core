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

    entity(:virtual_meter) do
      meter = Fabricate(:virtual_meter)
      meter.register.update(group: group)
      meter
    end
    
    entity(:meter) do
      meter = Fabricate(:input_meter)
      meter.input_register.update(group: group)
      meter
    end

    let(:real_meter) { meter }

    let(:meter_json) do
      {
        "id"=>meter.id,
        "type"=>"meter_real",
        "manufacturer_product_name"=>meter.manufacturer_product_name,
        "manufacturer_product_serialnumber"=>meter.manufacturer_product_serialnumber,
        "metering_type"=>meter.metering_type,
        "meter_size"=>nil,
        "ownership"=>nil,
        "direction_label"=>meter.direction,
        "build_year"=>nil,
        "updatable"=>true,
        "deletable"=>true,
        "rules"=> {
          "manufacturer_name"=>'key?(:manufacturer_name) THEN key[manufacturer_name](included_in?(["easy_meter", "amperix", "ferraris", "other"]))',
          "manufacturer_product_name"=>"key?(:manufacturer_product_name) THEN key[manufacturer_product_name](filled?) AND key[manufacturer_product_name](str?) AND key[manufacturer_product_name](max_size?(63))",
          'manufacturer_product_serialnumber'=>'key?(:manufacturer_product_serialnumber) THEN key[manufacturer_product_serialnumber](filled?) AND key[manufacturer_product_serialnumber](str?) AND key[manufacturer_product_serialnumber](max_size?(63))',
          'metering_type'=>'key?(:metering_type) THEN key[metering_type](included_in?(["analog_household_meter", "smart_meter", "load_meter", "analog_ac_meter", "digital_household_meter", "maximum_meter", "individual_adjustment"]))',
          'metering_size'=>'key?(:metering_size) THEN key[metering_size](included_in?(["edl40", "edl21", "other_ehz"]))',
          'ownership'=>'key?(:ownership) THEN key[ownership](included_in?(["buzzn_systems", "foreign_ownership", "customer", "leased", "bought"]))',
          'build_year'=>'key?(:build_year) THEN key[build_year](filled?) AND key[build_year](int?)'
        },
        "manufacturer_name"=>meter.manufacturer_name,
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

    context 'GET' do

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

    context 'PATCH' do

      let(:wrong_json) do
        {
          "errors"=>[
            {"parameter"=>"manufacturer_name",
             "detail"=>"must be one of: easy_meter, amperix, ferraris, other"},
            {"parameter"=>"manufacturer_product_name",
             "detail"=>"size cannot be greater than 63"},
            {"parameter"=>"manufacturer_product_serialnumber",
             "detail"=>"size cannot be greater than 63"},
            {"parameter"=>"metering_type",
             "detail"=>"must be one of: analog_household_meter, smart_meter, load_meter, analog_ac_meter, digital_household_meter, maximum_meter, individual_adjustment"},
            {"parameter"=>"metering_size",
             "detail"=>"must be one of: edl40, edl21, other_ehz"},
            {"parameter"=>"build_year",
             "detail"=>"must be an integer"}
          ]
        }
      end

      let(:real_updated_json) do
        json = meter_json.dup
        json['manufacturer_product_name'] = 'Smarty Super Meter'
        json.delete('registers')
        json
      end

      let(:virtual_meter_json) do
        json = meter_json.dup
        json['type'] = 'meter_virtual'
        json['id'] = virtual_meter.id
        json['manufacturer_product_serialnumber'] = virtual_meter.manufacturer_product_serialnumber
        json.delete('manufacturer_name')
        json.delete('smart')
        json.delete('registers')
        json['rules'].shift
        json
      end
      let(:virtual_updated_json) do
        json = virtual_meter_json.dup
        json['manufacturer_product_name'] = 'Smarty Super Meter'
        json
      end

      let(:real_wrong_json) { wrong_json }
      let(:virtual_wrong_json) do
        json = wrong_json.dup
        json['errors'].shift
        json
      end

      it '403' do
        PATCH "/#{group.id}/meters/#{real_meter.id}", user
        expect(response).to have_http_status(403)
        expect(json).to eq denied_json
      end

      it '404' do
        PATCH "/#{group.id}/meters/bla-blub", admin
        expect(response).to have_http_status(404)
        expect(json).to eq not_found_json
      end

      [:real, :virtual].each do |type|
        context type do
          it '422 wrong' do
            meter = send "#{type}_meter"
            PATCH "/#{group.id}/meters/#{meter.id}", admin,
                  manufacturer_name: 'Maxima' * 20,
                  manufacturer_product_name: 'SmartyMeter' * 10,
                  manufacturer_product_serialnumber: '12341234' * 10,
                  metering_type: 'sometype',
                  metering_size: 'somesize',
                  onwership: 'me',
                  build_year: 'this-year'
        
            expect(response).to have_http_status(422)
            expect(json.to_yaml).to eq send("#{type}_wrong_json").to_yaml
          end

          it '200' do
            meter = send "#{type}_meter"
            PATCH "/#{group.id}/meters/#{meter.id}", admin, manufacturer_product_name: 'Smarty Super Meter'
            expect(response).to have_http_status(200)
            expect(meter.reload.manufacturer_product_name).to eq 'Smarty Super Meter'
            expect(json.to_yaml).to eq send("#{type}_updated_json").to_yaml
          end
        end
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
