require_relative 'test_admin_localpool_roda'
describe Admin::LocalpoolRoda, :request_helper do

  def app
    TestAdminLocalpoolRoda # this defines the active application for this test
  end

  context 'market location' do

    entity(:market_location) do
      create(:register, :real).meta
    end

    entity(:group) do
      group = market_location.register.meter.group
      $user.person.reload.add_role(Role::GROUP_MEMBER, group)
      group
    end

    context 'GET' do

      let(:expected_json) do
        register = market_location.register
        meter = register.meter
        {
          'id' => market_location.id,
          'type' => 'market_location',
          'created_at' => market_location.created_at.as_json,
          'updated_at' => market_location.updated_at.as_json,
          'name' => market_location.register.meta.name,
          'kind' => 'consumption',
          'market_location_id' => nil,
          'updatable' => true,
          'deletable' => false,
          'register' => {
            'id' => register.id,
            'type' => 'register_real',
            'created_at'=> register.created_at.as_json,
            'updated_at'=> register.updated_at.as_json,
            'label' => register.meta.attributes['label'],
            'direction' => register.meta.label.consumption? ? 'in' : 'out',
            'last_reading' => 0,
            'observer_min_threshold' => nil,
            'observer_max_threshold' => nil,
            'observer_enabled'=> nil,
            'observer_offline_monitoring' => nil,
            'meter_id' => register.meter.id,
            'updatable' => false,
            'deletable' => false,
            'createables' => ['readings', 'contracts'],
            'pre_decimal_position' => 6,
            'post_decimal_position' => register.post_decimal_position,
            'low_load_ability' => false,
            'metering_point_id'=>register.meter.metering_location&.metering_location_id,
            'obis' => register.obis,
            'meter' => {
              'id'=>meter.id,
              'type'=>'meter_real',
              'created_at'=> meter.created_at.as_json,
              'updated_at'=> meter.updated_at.as_json,
              'product_serialnumber'=>meter.product_serialnumber,
              'sequence_number' => meter.sequence_number,
              'datasource'=>meter.datasource.to_s,
              'updatable'=>false,
              'deletable'=>false,
              'product_name'=>meter.product_name,
              'manufacturer_name'=>meter.attributes['manufacturer_name'],
              'manufacturer_description'=>meter.attributes['manufacturer_description'],
              'location_description'=>meter.attributes['location_description'],
              'direction_number'=>meter.attributes['direction_number'],
              'converter_constant'=>meter.converter_constant,
              'ownership'=>meter.attributes['ownership'],
              'build_year'=>meter.build_year,
              'calibrated_until'=>meter.calibrated_until ? meter.calibrated_until.to_s : nil,
              'edifact_metering_type'=>meter.attributes['edifact_metering_type'],
              'edifact_meter_size'=>meter.attributes['edifact_meter_size'],
              'edifact_tariff'=>meter.attributes['edifact_tariff'],
              'edifact_measurement_method'=>meter.attributes['edifact_measurement_method'],
              'edifact_mounting_method'=>meter.attributes['edifact_mounting_method'],
              'edifact_voltage_level'=>meter.attributes['edifact_voltage_level'],
              'edifact_cycle_interval'=>meter.attributes['edifact_cycle_interval'],
              'edifact_data_logging'=>meter.attributes['edifact_data_logging'],
              'sent_data_dso'=>meter.sent_data_dso.to_s
            }
          }
        }
      end

      it '401' do
        GET "/localpools/#{group.id}/market-locations/#{market_location.id}", $admin
        expire_admin_session do
          GET "/localpools/#{group.id}/market_locations/#{market_location.id}", $admin
          expect(response).to be_session_expired_json(401)
        end
      end

      it '403' do
        GET "/localpools/#{group.id}/market-locations/#{market_location.id}", $user
        expect(response).to have_http_status(403)
      end

      it '404' do
        GET "/localpools/#{group.id}/market-locations/bla-blub", $admin
        expect(response).to have_http_status(404)
      end

      it '200' do
        GET "/localpools/#{group.id}/market-locations/#{market_location.id}", $admin, include: 'register:meter'
        expect(response).to have_http_status(200)
        expect(json.to_yaml).to eq expected_json.to_yaml
      end
    end

  end
end
