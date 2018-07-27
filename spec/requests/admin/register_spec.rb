require_relative 'test_admin_localpool_roda'
describe Admin::LocalpoolRoda, :request_helper do

  def app
    TestAdminLocalpoolRoda # this defines the active application for this test
  end

  entity(:group) { create(:group, :localpool) }

  entity(:meter) { create(:meter, :real, group: group) }

  entity!(:real_register) do
    register = meter.registers.first
    create(:contract, :localpool_powertaker, market_location: create(:market_location, register: register), localpool: group)
    register
  end

  entity!(:register) { create(:register, :output, meter: meter) }

  entity!(:virtual_register) { create(:meter, :virtual, group: group).register }

  context 'meters' do
    context 'registers' do

      it 'PUT - 405' do
        PUT "/localpools/#{group.id}/meters/#{meter.id}/registers/#{register.id}", $admin
        expect(response).to have_http_status(405)
        expect(response.headers['X-Allowed-Methods']).to eq('get, patch')
      end

      context 'PATCH' do

        let(:updated_json) do
          last = register.readings.order('date').last
          {
            'id'=>register.id,
            'type'=>'register_real',
            'label'=>'DEMARCATION_PV',
            'direction'=>register.consumption? ? 'in' : 'out',
            'last_reading'=>last ? last.value : 0,
            'observer_min_threshold'=>10,
            'observer_max_threshold'=>100,
            'observer_enabled'=>true,
            'observer_offline_monitoring'=>true,
            'meter_id' => register.meter_id,
            'updatable'=> true,
            'deletable'=> true,
            'createables'=>['readings', 'contracts'],
            'pre_decimal_position'=>6,
            'post_decimal_position'=>1,
            'low_load_ability'=>false,
            'metering_point_id'=>'12345667890',
            'obis'=>register.obis,
          }
        end

        let(:wrong_json) do
          {
            'label'=>['must be one of: CONSUMPTION, CONSUMPTION_COMMON, DEMARCATION_PV, DEMARCATION_CHP, DEMARCATION_WIND, DEMARCATION_WATER, PRODUCTION_PV, PRODUCTION_CHP, PRODUCTION_WIND, PRODUCTION_WATER, GRID_CONSUMPTION, GRID_FEEDING, GRID_CONSUMPTION_CORRECTED, GRID_FEEDING_CORRECTED, OTHER'],
            'share_with_group'=>['must be boolean'],
            'share_publicly'=>['must be boolean'],
            'observer_enabled'=>['must be boolean'],
            'observer_min_threshold'=>['must be an integer'],
            'observer_max_threshold'=>['must be an integer'],
            'observer_offline_monitoring'=>['must be boolean'],
            'metering_point_id'=>['length must be 11'],
            'updated_at'=>['is missing']
          }
        end

        it '401' do
          GET "/localpools/#{group.id}/meters/#{meter.id}/registers/#{register.id}", $admin
          expire_admin_session do
            PATCH "/localpools/#{group.id}/meters/#{meter.id}/registers/#{register.id}", $admin
            expect(response).to be_session_expired_json(401)
          end
        end

        it '404' do
          PATCH "/localpools/#{group.id}/meters/#{meter.id}/registers/bla-blub", $admin
          expect(response).to have_http_status(404)
        end

        it '409' do
          PATCH "/localpools/#{group.id}/meters/#{meter.id}/registers/#{register.id}", $admin,
                updated_at: DateTime.now
          expect(response).to have_http_status(409)
        end

        it '422' do
          PATCH "/localpools/#{group.id}/meters/#{meter.id}/registers/#{register.id}", $admin,
                metering_point_id: '123321' * 20,
                label: 'grid',
                pre_decimal_position: 'pre',
                post_decimal_position: 'post',
                share_with_group: 'why not',
                share_publicly: 'never',
                low_load_ability: 'dunno',
                observer_enabled: 'dunno',
                observer_min_threshold: 'nothing',
                observer_max_threshold: 'nothing',
                observer_offline_monitoring: 'dunno'
          expect(response).to have_http_status(422)
          expect(json.to_yaml).to eq wrong_json.to_yaml
        end

        it '200' do
          old = register.updated_at
          PATCH "/localpools/#{group.id}/meters/#{meter.id}/registers/#{register.id}", $admin,
                updated_at: register.updated_at,
                metering_point_id: '12345667890',
                label: Register::Meta.labels[:demarcation_pv],
                share_with_group: true,
                share_publicly: false,
                observer_enabled: true,
                observer_min_threshold: 10,
                observer_max_threshold: 100,
                observer_offline_monitoring: true
          expect(response).to have_http_status(200)
          register.reload
          expect(register.meter.metering_location&.metering_location_id).to eq '12345667890'
          expect(register.meta.label).to eq 'demarcation_pv'
          expect(register.meta.share_with_group).to eq true
          expect(register.meta.share_publicly).to eq false
          expect(register.meta.observer_enabled).to eq true
          expect(register.meta.observer_min_threshold).to eq 10
          expect(register.meta.observer_max_threshold).to eq 100
          expect(register.meta.observer_offline_monitoring).to eq true

          result = json
          expect(result.delete('updated_at')).to be >= old.as_json
          expect(result.delete('updated_at')).not_to eq old.as_json
          expect(result.to_yaml).to eq updated_json.to_yaml
        end
      end
    end
  end

  context 'registers' do
    context 'GET' do

      let(:real_register_json) do
        last = real_register.readings.order('date').last
        {
          'id'=>real_register.id,
          'type'=>'register_real',
          'updated_at'=>real_register.updated_at.as_json,
          'label'=>real_register.meta.attributes['label'],
          'direction'=>real_register.consumption? ? 'in' : 'out',
          'last_reading'=>last ? last.value : 0,
          'observer_min_threshold'=>nil,
          'observer_max_threshold'=>nil,
          'observer_enabled'=>nil,
          'observer_offline_monitoring'=>nil,
          'meter_id' => real_register.meter_id,
          'updatable'=> true,
          'deletable'=> true,
          'createables'=>['readings', 'contracts'],
          'pre_decimal_position'=>6,
          'post_decimal_position'=>real_register.post_decimal_position,
          'low_load_ability'=>false,
          'metering_point_id'=>real_register.meter.reload.metering_location&.metering_location_id,
          'obis'=>real_register.obis,
        }
      end

      let(:virtual_register_json) do
        last = virtual_register.readings.order('date').last
        {
          'id'=>virtual_register.id,
          'type'=>'register_virtual',
          'updated_at'=>virtual_register.updated_at.as_json,
          'label'=>virtual_register.attributes['label'],
          'direction'=>virtual_register.label.consumption? ? 'in' : 'out',
          'last_reading'=>last ? last.value : 0,
          'observer_min_threshold'=>100,
          'observer_max_threshold'=>5000,
          'observer_enabled'=>false,
          'observer_offline_monitoring'=>false,
          'meter_id' => virtual_register.meter_id,
          'updatable'=> true,
          'deletable'=> true,
          'createables'=>['readings', 'contracts']
        }
      end

      let(:registers_json) do
        Register::Base.all.reload.collect do |register|
          last = register.readings.order('date').last
          json = {
            'id'=>register.id,
            'type'=>"register_#{register.is_a?(Register::Real) ? 'real': 'virtual'}",
            'updated_at'=>register.updated_at.as_json,
            'label'=>register.attributes['label'],
            'last_reading'=>last ? last.value : 0,
            'observer_min_threshold'=>register.meta.observer_min_threshold,
            'observer_max_threshold'=>register.meta.observer_max_threshold,
            'observer_enabled'=>register.meta.observer_enabled,
            'observer_offline_monitoring'=>register.meta.observer_offline_monitoring,
            'meter_id' => register.meter_id,
            'updatable'=> true,
            'deletable'=> false,
            'createables'=>['readings', 'contracts'],
          }
          if register.is_a? Register::Real
            json['direction'] = register.consumption? ? 'in' : 'out',
            json['pre_decimal_position'] = register.pre_decimal_position
            json['post_decimal_position'] = register.post_decimal_position
            json['low_load_ability'] = register.low_load_ability
            json['metering_point_id'] = register.meter.metering_location&.metering_location_id
            json['obis'] = register.obis
          end
          json
        end
      end

      # NOTE picking a sample register is enough for the 404 tests

      let(:regixster) do
        register = [real_register, virtual_register].sample
        create(:reading, :regualr, register: register)
        register
      end

      [:real].each do |type|

        context "as #{type}" do
          let(:virtual_registers_json) { [virtual_register_json] }
          let(:real_registers_json) do
            real_register.meter.registers.reload.collect do |register|
              last = register.readings.order('date').last
              {
                'id'=>register.id,
                'type'=>'register_real',
                'updated_at'=>register.updated_at.as_json,
                'label'=>register.meta.attributes['label'],
                'direction'=>register.consumption? ? 'in' : 'out',
                'last_reading'=> last ? last.value : 0,
                'observer_min_threshold'=>register.meta.observer_min_threshold,
                'observer_max_threshold'=>register.meta.observer_max_threshold,
                'observer_enabled'=>register.meta.observer_enabled,
                'observer_offline_monitoring'=>register.meta.observer_offline_monitoring,
                'meter_id' => register.meter_id,
                'updatable'=> true,
                'deletable'=> true,
                'createables'=>['readings', 'contracts'],
                'pre_decimal_position'=>register.pre_decimal_position,
                'post_decimal_position'=>register.post_decimal_position,
                'low_load_ability'=>register.low_load_ability,
                'metering_point_id'=>register.meter.metering_location&.metering_location_id,
                'obis'=>register.obis
              }
            end
          end

          it '200 all' do
            register = send "#{type}_register"
            registers_json = send("#{type}_registers_json")

            GET "/localpools/#{group.id}/meters/#{register.meter.id}/registers", $admin
            expect(response).to have_http_status(200)
            expect(sort(json['array']).to_yaml).to eq sort(registers_json).to_yaml
          end

          it '200' do
            register = send "#{type}_register"
            register_json = send "#{type}_register_json"

            GET "/localpools/#{group.id}/meters/#{register.meter.id}/registers/#{register.id}", $admin
            expect(response).to have_http_status(200)
            expect(json.to_yaml).to eq register_json.to_yaml

            GET "/localpools/#{group.id}/meters/#{register.meter.id}/registers/#{register.id}", $admin
            expect(response).to have_http_status(200)
            expect(json.to_yaml).to eq register_json.to_yaml

            GET "/localpools/#{group.id}/meters/#{register.meter.id}/registers/#{register.id}", $admin, include: 'market_location:contracts'
            expect(response).to have_http_status(200)

            expect(json).to has_nested_json(:market_location, :contracts, :array, :id)

            result = json
            result.delete('market_location')
            expect(result.to_yaml).to eq register_json.to_yaml
          end
        end
      end
    end
  end
end
