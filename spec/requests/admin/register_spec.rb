require_relative 'test_admin_localpool_roda'
describe Admin::LocalpoolRoda do

  def app
    TestAdminLocalpoolRoda # this defines the active application for this test
  end

  entity(:group) { create(:localpool) }

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
      context 'PATCH' do

        let(:updated_json) do
          last = register.readings.order('date').last
          {
            'id'=>register.id,
            'type'=>'register_real',
            'label'=>'DEMARCATION_PV',
            'direction'=>register.attributes['direction'],
            'last_reading'=>last ? last.value : 0,
            'observer_min_threshold'=>10,
            'observer_max_threshold'=>100,
            'observer_enabled'=>true,
            'observer_offline_monitoring'=>true,
            'meter_id' => register.meter_id,
            'updatable'=> true,
            'deletable'=> true,
            'createables'=>['readings'],
            'pre_decimal_position'=>6,
            'post_decimal_position'=>1,
            'low_load_ability'=>false,
            'metering_point_id'=>'123456',
            'obis'=>register.obis,
          }
        end

        let(:wrong_json) do
          {
            'errors'=>[
              {'parameter'=>'label',
               'detail'=>'must be one of: CONSUMPTION, CONSUMPTION_COMMON, DEMARCATION_PV, DEMARCATION_CHP, DEMARCATION_WIND, DEMARCATION_WATER, PRODUCTION_PV, PRODUCTION_CHP, PRODUCTION_WIND, PRODUCTION_WATER, GRID_CONSUMPTION, GRID_FEEDING, GRID_CONSUMPTION_CORRECTED, GRID_FEEDING_CORRECTED, OTHER'},
              {'parameter'=>'metering_point_id',
               'detail'=>'size cannot be greater than 64'},
              {'parameter'=>'observer_enabled',
               'detail'=>'must be boolean'},
              {'parameter'=>'observer_min_threshold',
               'detail'=>'must be an integer'},
              {'parameter'=>'observer_max_threshold',
               'detail'=>'must be an integer'},
              {'parameter'=>'observer_offline_monitoring',
               'detail'=>'must be boolean'},
              {'parameter'=>'updated_at',
               'detail'=>'is missing'},
            ]
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
          expect(response).to be_not_found_json(404, Register::Real)
        end

        it '409' do
          PATCH "/localpools/#{group.id}/meters/#{meter.id}/registers/#{register.id}", $admin,
                updated_at: DateTime.now
          expect(response).to be_stale_json(409, register)
        end

        it '422' do
          PATCH "/localpools/#{group.id}/meters/#{meter.id}/registers/#{register.id}", $admin,
                metering_point_id: '123321' * 20,
                label: 'grid',
                pre_decimal_position: 'pre',
                post_decimal_position: 'post',
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
                metering_point_id: '123456',
                label: Register::Base.labels[:demarcation_pv],
                observer_enabled: true,
                observer_min_threshold: 10,
                observer_max_threshold: 100,
                observer_offline_monitoring: true
          expect(response).to have_http_status(200)
          register.reload
          expect(register.metering_point_id).to eq '123456'
          expect(register.label).to eq 'demarcation_pv'
          expect(register.observer_enabled).to eq true
          expect(register.observer_min_threshold).to eq 10
          expect(register.observer_max_threshold).to eq 100
          expect(register.observer_offline_monitoring).to eq true

          result = json
          # TODO fix it: our time setup does not allow
          #expect(result.delete('updated_at')).to be > old.as_json
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
          'label'=>real_register.attributes['label'],
          'direction'=>real_register.attributes['direction'],
          'last_reading'=>last ? last.value : 0,
          'observer_min_threshold'=>nil,
          'observer_max_threshold'=>nil,
          'observer_enabled'=>nil,
          'observer_offline_monitoring'=>nil,
          'meter_id' => real_register.meter_id,
          'updatable'=> true,
          'deletable'=> true,
          'createables'=>['readings'],
          'pre_decimal_position'=>6,
          'post_decimal_position'=>real_register.post_decimal_position,
          'low_load_ability'=>false,
          'metering_point_id'=>real_register.metering_point_id,
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
          'direction'=>virtual_register.attributes['direction'],
          'last_reading'=>last ? last.value : 0,
          'observer_min_threshold'=>100,
          'observer_max_threshold'=>5000,
          'observer_enabled'=>false,
          'observer_offline_monitoring'=>false,
          'meter_id' => virtual_register.meter_id,
          'updatable'=> true,
          'deletable'=> true,
          'createables'=>['readings']
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
            'observer_min_threshold'=>register.observer_min_threshold,
            'observer_max_threshold'=>register.observer_max_threshold,
            'observer_enabled'=>register.observer_enabled,
            'observer_offline_monitoring'=>register.observer_offline_monitoring,
            'meter_id' => register.meter_id,
            'updatable'=> true,
            'deletable'=> false,
            'createables'=>['readings'],
          }
          if register.is_a? Register::Real
            json['direction'] = register.attributes['direction']
            json['pre_decimal_position'] = register.pre_decimal_position
            json['post_decimal_position'] = register.post_decimal_position
            json['low_load_ability'] = register.low_load_ability
            json['metering_point_id'] = register.metering_point_id
            json['obis'] = register.obis
          end
          json
        end
      end

      # NOTE picking a sample register is enough for the 404 tests

      let(:regixster) do
        register = [real_register, virtual_register].sample
        Fabricate(:single_reading, register: register)
        register
      end

      [:real].each do |type|

        context "as #{type}" do
          let(:virtual_registers_json) { [virtual_register_json] }
          let(:real_registers_json) do
            real_register.meter.registers.collect do |register|
              last = register.readings.order('date').last
              {
                'id'=>register.id,
                'type'=>'register_real',
                'updated_at'=>register.updated_at.as_json,
                'label'=>register.attributes['label'],
                'direction'=>register.attributes['direction'],
                'last_reading'=> last ? last.value : 0,
                'observer_min_threshold'=>register.observer_min_threshold,
                'observer_max_threshold'=>register.observer_max_threshold,
                'observer_enabled'=>register.observer_enabled,
                'observer_offline_monitoring'=>register.observer_offline_monitoring,
                'meter_id' => register.meter_id,
                'updatable'=> true,
                'deletable'=> true,
                'createables'=>['readings'],
                'pre_decimal_position'=>register.pre_decimal_position,
                'post_decimal_position'=>register.post_decimal_position,
                'low_load_ability'=>register.low_load_ability,
                'metering_point_id'=>register.metering_point_id,
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
