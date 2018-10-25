require_relative 'test_admin_localpool_roda'
describe Admin::LocalpoolRoda, :request_helper, order: :defined do

  def app
    TestAdminLocalpoolRoda # this defines the active application for this test
  end

  context 'register meta' do

    entity(:register_meta) do
      create(:register, :real).meta
    end

    entity(:group) do
      group = register_meta.register.meter.group
      $user.person.reload.add_role(Role::GROUP_MEMBER, group)
      group
    end

    context 'GET' do

      let(:expected_json) do
        register = register_meta.register
        meter = register.meter
        {
          'id' => register_meta.id,
          'type' => 'register_meta',
          'created_at' => register_meta.created_at.as_json,
          'updated_at' => register_meta.updated_at.as_json,
          'name' => register_meta.register.meta.name,
          'kind' => 'consumption',
          'label' => 'CONSUMPTION',
          'market_location_id' => nil,
          'observer_enabled' => false,
          'observer_min_threshold' => nil,
          'observer_max_threshold' => nil,
          'observer_offline_monitoring' => false,
          'updatable' => true,
          'deletable' => false,
          'register' => {
            'id' => register.id,
            'type' => 'register_real',
            'created_at'=> register.created_at.as_json,
            'updated_at'=> register.updated_at.as_json,
            'direction' => register.meta.label.consumption? ? 'in' : 'out',
            'last_reading' => 0,
            'meter_id' => register.meter.id,
            'updatable' => false,
            'deletable' => false,
            'createables' => ['readings', 'contracts'],
            'pre_decimal_position' => 6,
            'post_decimal_position' => register.post_decimal_position,
            'low_load_ability' => false,
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
              'sent_data_dso'=>meter.sent_data_dso.to_s,
              'metering_location_id'=>meter.metering_location_id
            }
          }
        }
      end

      it '401' do
        GET "/localpools/#{group.id}/register-metas/#{register_meta.id}", $admin
        expire_admin_session do
          GET "/localpools/#{group.id}/register_metas/#{register_meta.id}", $admin
          expect(response).to be_session_expired_json(401)
        end
      end

      it '403' do
        GET "/localpools/#{group.id}/register-metas/#{register_meta.id}", $user
        expect(response).to have_http_status(403)
      end

      it '404' do
        GET "/localpools/#{group.id}/register-metas/bla-blub", $admin
        expect(response).to have_http_status(404)
      end

      it '200' do
        GET "/localpools/#{group.id}/register-metas/#{register_meta.id}", $admin, include: 'register:meter'
        expect(response).to have_http_status(200)
        expect(json.to_yaml).to eq expected_json.to_yaml
      end
    end

    context 'PATCH' do

      let(:updated_json) do
        {
          'id'=>register_meta.id,
          'type'=> 'register_meta',
          'name'=> 'SmallCell',
          'kind'=> 'system',
          'label'=>'DEMARCATION_PV',
          'market_location_id' => 'DE133713371',
          'observer_enabled'=>true,
          'observer_min_threshold'=>10,
          'observer_max_threshold'=>100,
          'observer_offline_monitoring'=>true,
        }
      end

      let(:wrong_json) do
        {
          'updated_at'=>['is missing'],
          'label'=>['must be one of: CONSUMPTION, CONSUMPTION_COMMON, DEMARCATION_PV, DEMARCATION_CHP, DEMARCATION_WIND, DEMARCATION_WATER, PRODUCTION_PV, PRODUCTION_CHP, PRODUCTION_WIND, PRODUCTION_WATER, GRID_CONSUMPTION, GRID_FEEDING, GRID_CONSUMPTION_CORRECTED, GRID_FEEDING_CORRECTED, OTHER'],
          'observer_enabled'=>['must be boolean'],
          'observer_min_threshold'=>['must be an integer'],
          'observer_max_threshold'=>['must be an integer'],
          'observer_offline_monitoring'=>['must be boolean'],
        }
      end

      it '401' do
        GET "/localpools/#{group.id}/register-metas/#{register_meta.id}", $admin
        expire_admin_session do
          PATCH "/localpools/#{group.id}/register-metas/#{register_meta.id}", $admin
          expect(response).to be_session_expired_json(401)
        end
      end

      it '404' do
        PATCH "/localpools/#{group.id}/register-metas/bla-blub", $admin
        expect(response).to have_http_status(404)
      end

      it '409' do
        PATCH "/localpools/#{group.id}/register-metas/#{register_meta.id}", $admin,
              updated_at: DateTime.now
        expect(response).to have_http_status(409)
      end

      it '422' do
        PATCH "/localpools/#{group.id}/register-metas/#{register_meta.id}", $admin,
              label: 'grid',
              observer_enabled: 'dunno',
              observer_min_threshold: 'nothing',
              observer_max_threshold: 'nothing',
              observer_offline_monitoring: 'dunno'
        expect(response).to have_http_status(422)
        expect(json.to_yaml).to eq wrong_json.to_yaml
      end

      it '200' do
        old = register_meta.updated_at
        PATCH "/localpools/#{group.id}/register-metas/#{register_meta.id}", $admin,
              updated_at: register_meta.updated_at,
              label: Register::Meta.labels[:demarcation_pv],
              observer_enabled: true,
              observer_min_threshold: 10,
              observer_max_threshold: 100,
              market_location_id: 'DE133713371',
              name: 'SmallCell',
              observer_offline_monitoring: true
        expect(response).to have_http_status(200)
        register_meta.reload
        expect(register_meta.label).to eq 'demarcation_pv'
        expect(register_meta.observer_enabled).to eq true
        expect(register_meta.observer_min_threshold).to eq 10
        expect(register_meta.observer_max_threshold).to eq 100
        expect(register_meta.observer_offline_monitoring).to eq true

        result = json
        expect(result.delete('updated_at')).to be >= old.as_json
        expect(result.delete('updated_at')).not_to eq old.as_json
        expect(result.delete('created_at')).not_to be_nil
        result.delete('updatable')
        result.delete('deletable')
        expect(result.to_yaml).to eq updated_json.to_yaml
      end
    end
  end
end
