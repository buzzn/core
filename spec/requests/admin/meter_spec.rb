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
      meter.update(sent_data_dso: Date.today)
      meter.register.update(group: group)
      meter
    end
    
    entity(:meter) do
      meter = Fabricate(:input_meter)
      meter.update(sent_data_dso: Date.today)
      meter.input_register.update(group: group)
      meter
    end

    let(:real_meter) do
      meter = Fabricate(:output_meter)
      meter.output_register.update(group: group)
      meter
    end

    let(:meter_json) do
      {
        "id"=>meter.id,
        "type"=>"meter_real",
        'updated_at'=> meter.updated_at.as_json,
        "product_name"=>meter.product_name,
        "product_serialnumber"=>meter.product_serialnumber,
        "updatable"=>true,
        "deletable"=>true,
        "manufacturer_name"=>meter.attributes['manufacturer_name'],
        "direction_number"=>meter.attributes['direction_number'],
        "converter_constant"=>meter.converter_constant,
        "ownership"=>meter.attributes['ownership'],
        "section"=>meter.attributes['section'],
        "build_year"=>meter.build_year,
        "calibrated_until"=>meter.calibrated_until ? meter.calibrated_until.to_s : nil,
        "edifact_metering_type"=>meter.attributes['edifact_metering_type'],
        "edifact_meter_size"=>meter.attributes['edifact_meter_size'],
        "edifact_tariff"=>meter.attributes['edifact_tariff'],
        "edifact_measurement_method"=>meter.attributes['edifact_measurement_method'],
        "edifact_mounting_method"=>meter.attributes['edifact_mounting_method'],
        "edifact_voltage_level"=>meter.attributes['edifact_voltage_level'],
        "edifact_cycle_interval"=>meter.attributes['edifact_cycle_interval'],
        "edifact_data_logging"=>meter.attributes['edifact_data_logging'],
        "sent_data_dso"=>Date.today.to_s,
        "registers"=>{
          'array'=>[
            {
              "id"=>meter.input_register.id,
              "type"=>"register_real",
              'updated_at'=> meter.input_register.updated_at.as_json,
              "direction"=>meter.input_register.attributes['direction'],
              "name"=>meter.input_register.name,
              "pre_decimal_position"=>6,
              "post_decimal_position"=>2,
              "low_load_ability"=>false,
              "label"=>meter.input_register.attributes['label'],
              "last_reading"=>0,
              'observer_min_threshold'=> 100,
              'observer_max_threshold'=> 5000,
              'observer_enabled'=> false,
              'observer_offline_monitoring'=> false,
              "metering_point_id"=>meter.input_register.metering_point_id,
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

      let(:real_wrong_json) do
        {
          "errors"=>[
            {"parameter"=>"updated_at",
             "detail"=>"is missing"},
            {"parameter"=>"manufacturer_name",
             "detail"=>"must be one of: easy_meter, amperix, ferraris, other"},
            {"parameter"=>"product_name",
             "detail"=>"size cannot be greater than 64"},
            {"parameter"=>"product_serialnumber",
             "detail"=>"size cannot be greater than 64"},
            {"parameter"=>"section",
             "detail"=>"must be one of: S, G"},
            {"parameter"=>"build_year",
             "detail"=>"must be an integer"},
            {"parameter"=>"sent_data_dso",
             "detail"=>"must be a date"},
            {"parameter"=>"converter_constant",
             "detail"=>"must be an integer"},
            {"parameter"=>"calibrated_until",
             "detail"=>"must be a date"},
            {"parameter"=>"direction_number",
             "detail"=>"must be one of: ERZ, ZRZ"},
            {"parameter"=>"edifact_metering_type",
             "detail"=>"must be one of: AHZ, LAZ, WSZ, EHZ, MAZ, IVA"},
            {"parameter"=>"edifact_meter_size",
             "detail"=>"must be one of: Z01, Z02, Z03"},
            {"parameter"=>"edifact_measurement_method",
             "detail"=>"must be one of: AMR, MMR"},
            {"parameter"=>"edifact_tariff",
             "detail"=>"must be one of: ETZ, ZTZ, NTZ"},
            {"parameter"=>"edifact_mounting_method",
             "detail"=>"must be one of: BKE, DPA, HS"},
            {"parameter"=>"edifact_voltage_level",
             "detail"=>"must be one of: E06, E05, E04, E03"},
            {"parameter"=>"edifact_cycle_interval",
             "detail"=>"must be one of: MONTHLY, YEARLY, QUARTERLY, HALF_YEARLY"},
            {"parameter"=>"edifact_data_logging",
             "detail"=>"must be one of: Z04, Z05"}
          ]
        }
      end

      let(:virtual_wrong_json) do
        {
          "errors"=>[
            {"parameter"=>"updated_at",
             "detail"=>"is missing"},
            {"parameter"=>"product_name",
             "detail"=>"size cannot be greater than 64"},
            {"parameter"=>"product_serialnumber",
             "detail"=>"size cannot be greater than 64"},
          ]
        }
      end

      let(:real_updated_json) do
        meter = real_meter
        {
          "id"=>real_meter.id,
          "type"=>"meter_real",
          "product_name"=>'Smarty Super Meter',
          "product_serialnumber"=>'12341234',
          "updatable"=>true,
          "deletable"=>true,
          "manufacturer_name"=>'other',
          "direction_number"=>'ZRZ',
          "converter_constant"=>20,
          "ownership"=>'CUSTOMER',
          "section"=>'G',
          "build_year"=>2017,
          "calibrated_until"=>Date.today.to_s,
          "edifact_metering_type"=>'EHZ',
          "edifact_meter_size"=>'Z02',
          "edifact_tariff"=>'ZTZ',
          "edifact_measurement_method"=>'MMR',
          "edifact_mounting_method"=> 'HS',
          "edifact_voltage_level"=>'E04',
          "edifact_cycle_interval"=>'QUARTERLY',
          "edifact_data_logging"=>'Z04',
          "sent_data_dso"=>'2010-01-01',
        }
      end

      let(:virtual_meter_json) do
        meter = virtual_meter
        {
          "id"=>meter.id,
          "type"=>"meter_virtual",
          "product_name"=>'Smarty Super Meter',
          "product_serialnumber"=>'12341234',
          "updatable"=>true,
          "deletable"=>true,
        }
      end

      let(:virtual_updated_json) do
        json = virtual_meter_json.dup
        json['product_name'] = 'Smarty Super Meter'
        json['product_serialnumber'] = '12341234'
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

      context 'virtual' do
        it '404' do
          skip('asd')
        end
      end

      [:real, :virtual].each do |type|
        context type do

          let(:real_stale_json) do
            {
              "errors" => [
                {"detail"=>"Meter::Real: #{real_meter.id} was updated at: #{real_meter.updated_at}"}]
            }
          end

          let(:virtual_stale_json) do
            {
              "errors" => [
                {"detail"=>"Meter::Virtual: #{virtual_meter.id} was updated at: #{virtual_meter.updated_at}"}]
            }
          end

          it '409' do
            meter = send "#{type}_meter"
            PATCH "/#{group.id}/meters/#{meter.id}", admin,
                  updated_at: DateTime.now
            expect(response).to have_http_status(409)
            expect(json).to eq send("#{type}_stale_json")
          end

          it '422' do
            meter = send "#{type}_meter"
            PATCH "/#{group.id}/meters/#{meter.id}", admin,
                  manufacturer_name: 'Maxima' * 20,
                  product_name: 'SmartyMeter' * 10,
                  product_serialnumber: '12341234' * 10,
                  onwership: 'me',
                  section: 'some' * 60,
                  build_year: 'this-year',
                  sent_data_dso: 'some-years-ago',
                  converter_constant: 'convert-it',
                  calibrated_until: 'today',
                  edifact_metering_type: 'sometype',
                  edifact_meter_size: 'somesize',
                  edifact_measurement_method: 'some' * 60,
                  edifact_tariff: 'something',
                  edifact_mounting_method: 'something',
                  edifact_voltage_level: 'something',
                  edifact_cycle_interval: 'something',
                  edifact_data_logging: 'something',
                  direction_number: 'uni'
        
            expect(response).to have_http_status(422)
            expect(json.to_yaml).to eq send("#{type}_wrong_json").to_yaml
          end

          it '200' do
            meter = send "#{type}_meter"
            sent = meter.sent_data_dso
            old = meter.updated_at
            PATCH "/#{group.id}/meters/#{meter.id}", admin,
                  updated_at: meter.updated_at,
                  manufacturer_name: Meter::Real::OTHER,
                  product_name: 'Smarty Super Meter',
                  product_serialnumber: '12341234',
                  ownership: Meter::Base::CUSTOMER,
                  section: Meter::Base::GAS,
                  build_year: 2017,
                  sent_data_dso: '2010-01-01',
                  converter_constant: 20,
                  calibrated_until: Date.today,
                  edifact_metering_type: Meter::Base::DIGITAL_HOUSEHOLD_METER,
                  edifact_meter_size: Meter::Base::EDL21,
                  edifact_measurement_method: Meter::Base::MANUAL,
                  edifact_tariff: Meter::Base::DUAL_TARIFF,
                  edifact_mounting_method: Meter::Base::CAP_RAIL,
                  edifact_voltage_level: Meter::Base::HIGH_LEVEL,
                  edifact_cycle_interval: Meter::Base::QUARTERLY,
                  edifact_data_logging: Meter::Base::ANALOG,
                  direction_number: Meter::Real::TWO_WAY_METER

            expect(response).to have_http_status(200)
            meter.reload
            if meter.is_a? Meter::Real
              expect(meter.manufacturer_name).to eq 'other'
              expect(meter.direction_number).to eq 'two_way_meter'
              expect(meter.ownership).to eq 'customer'
              expect(meter.section).to eq 'gas'
              expect(meter.build_year).to eq 2017
              expect(meter.sent_data_dso).to eq Date.new(2010)
              expect(meter.converter_constant).to eq 20
              expect(meter.calibrated_until).to eq Date.today
              expect(meter.edifact_metering_type).to eq 'digital_household_meter'
              expect(meter.edifact_meter_size).to eq 'edl21'
              expect(meter.edifact_measurement_method).to eq 'manual'
              expect(meter.edifact_tariff).to eq 'dual_tariff'
              expect(meter.edifact_mounting_method).to eq 'cap_rail'
              expect(meter.edifact_voltage_level).to eq 'high_level'
              expect(meter.edifact_cycle_interval).to eq 'quarterly'
              expect(meter.edifact_data_logging).to eq 'analog'
            end
            expect(meter.product_name).to eq 'Smarty Super Meter'
            expect(meter.product_serialnumber).to eq '12341234'

            result = json
            # TODO fix it: our time setup does not allow
            #expect(result.delete('updated_at')).to be > old.as_json
            expect(result.delete('updated_at')).not_to eq old.as_json
            expect(result.to_yaml).to eq send("#{type}_updated_json").to_yaml
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
