describe Admin::LocalpoolRoda do

  def app
    Admin::LocalpoolRoda # this defines the active application for this test
  end

  entity(:admin) { Fabricate(:admin_token) }

  entity(:user) { Fabricate(:user_token) }

  let(:denied_json) do
    {
      "errors" => [
        {
          "detail"=>"retrieve Register::Base: permission denied for User: #{user.resource_owner_id}"
        }
      ]
    }
  end

  let(:not_found_json) do
    {
      "errors" => [
        {
          "detail"=>"Register::Base: bla-blub not found by User: #{admin.resource_owner_id}"
        }
      ]
    }
  end

  entity(:group) { Fabricate(:localpool) }

  entity(:meter) { Fabricate(:real_meter) }

  entity!(:real_register) do
    Fabricate(meter.registers.is_a?(Register::Input) ? :output_register : :input_register,
              group: group,
              meter: meter)
    meter.registers.each do |reg|
      reg.group = group
      reg.save
    end
    meter.registers.reload
    meter.registers.first
  end

  entity!(:register) do
    meter.registers.second
  end

  entity!(:virtual_register) do
    reg = Fabricate(:virtual_meter).register
    reg.group = group
    reg.save
    reg
  end

  context 'meters' do
   context 'registers' do
     context 'PATCH' do

       let(:not_found_json) do
         {
           "errors" => [
             {
               "detail"=>"Register::Real: bla-blub not found by User: #{admin.resource_owner_id}"
             }
           ]
         }
       end

       let(:updated_json) do
         {
           "id"=>register.id,
           "type"=>"register_real",
           "direction"=>register.direction == 'in' ? 'out' : 'in',
           "name"=>'Smarty',
           "pre_decimal_position"=>4,
           "post_decimal_position"=>3,
           "low_load_ability"=>true,
           "label"=>'DEMARCATION_PV',
           "last_reading"=>Reading.by_register_id(real_register.id).sort('timestamp': -1).first.nil? ? 0 : Reading.by_register_id(real_register.id).sort('timestamp': -1).first.energy_milliwatt_hour,
           "observer_min_threshold"=>10,
           "observer_max_threshold"=>100,
           "observer_enabled"=>true,
           "observer_offline_monitoring"=>true,
           "metering_point_id"=>'123456',
           "obis"=>register.direction == 'in' ? '1-0:2.8.0' : '1-0:1.8.0',
         }
       end

       let(:wrong_json) do
         {
           "errors"=>[
             {"parameter"=>"metering_point_id",
              "detail"=>"size cannot be greater than 32"},
             {"parameter"=>"name",
              "detail"=>"size cannot be greater than 64"},
             {"parameter"=>"label",
              "detail"=>"must be one of: CONSUMPTION, DEMARCATION_PV, DEMARCATION_CHP, PRODUCTION_PV, PRODUCTION_CHP, GRID_CONSUMPTION, GRID_FEEDING, GRID_CONSUMPTION_CORRECTED, GRID_FEEDING_CORRECTED, OTHER"},
             {"parameter"=>"pre_decimal_position",
              "detail"=>"must be an integer"},
             {"parameter"=>"post_decimal_position",
              "detail"=>"must be an integer"},
             {"parameter"=>"low_load_ability",
              "detail"=>"must be boolean"},
             {"parameter"=>"observer_enabled",
              "detail"=>"must be boolean"},
             {"parameter"=>"observer_min_threshold",
              "detail"=>"must be an integer"},
             {"parameter"=>"observer_max_threshold",
              "detail"=>"must be an integer"},
             {"parameter"=>"observer_offline_monitoring",
              "detail"=>"must be boolean"}
           ]
         }
       end

       it '404' do
         PATCH "/#{group.id}/meters/#{meter.id}/registers/bla-blub", admin
         expect(response).to have_http_status(404)
         expect(json).to eq not_found_json
       end

       it '422 wrong' do
         PATCH "/#{group.id}/meters/#{meter.id}/registers/#{register.id}", admin,
               metering_point_id: '123321' * 20,
               name: 'Smarty' * 20,
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
         PATCH "/#{group.id}/meters/#{meter.id}/registers/#{register.id}", admin,
               metering_point_id: '123456',
               name: 'Smarty',
               label: Register::Real::DEMARCATION_PV,
               pre_decimal_position: 4,
               post_decimal_position: 3,
               low_load_ability: true,
               observer_enabled: true,
               observer_min_threshold: 10,
               observer_max_threshold: 100,
               observer_offline_monitoring: true
         expect(response).to have_http_status(200)
         expect(json.to_yaml).to eq updated_json.to_yaml
         register.reload
         expect(register.metering_point_id).to eq'123456'
         expect(register.name).to eq 'Smarty'
         expect(register.label).to eq 'demarcation_pv'
         expect(register.pre_decimal_position).to eq 4
         expect(register.post_decimal_position).to eq 3
         expect(register.low_load_ability).to eq true
         expect(register.observer_enabled).to eq true
         expect(register.observer_min_threshold).to eq 10
         expect(register.observer_max_threshold).to eq 100
         expect(register.observer_offline_monitoring).to eq true
       end
     end
   end
  end

  context 'registers' do
    context 'GET' do

      let(:real_register_json) do
        meter = real_register.meter
        {
          "id"=>real_register.id,
          "type"=>"register_real",
          "direction"=>real_register.attributes['direction'],
          "name"=>real_register.name,
          "pre_decimal_position"=>6,
          "post_decimal_position"=>2,
          "low_load_ability"=>false,
          "label"=>real_register.attributes['label'],
          "last_reading"=>Reading.by_register_id(real_register.id).sort('timestamp': -1).first.nil? ? 0 : Reading.by_register_id(real_register.id).sort('timestamp': -1).first.energy_milliwatt_hour,
          "observer_min_threshold"=>100,
          "observer_max_threshold"=>5000,
          "observer_enabled"=>false,
          "observer_offline_monitoring"=>false,
          "metering_point_id"=>real_register.metering_point_id,
          "obis"=>real_register.obis,
        }
      end

      let(:virtual_register_json) do
        meter = virtual_register.meter
        {
          "id"=>virtual_register.id,
          "type"=>"register_virtual",
          "direction"=>virtual_register.attributes['direction'],
          "name"=>virtual_register.name,
          "pre_decimal_position"=>6,
          "post_decimal_position"=>2,
          "low_load_ability"=>false,
          "label"=>virtual_register.attributes['label'],
          "last_reading"=>Reading.by_register_id(virtual_register.id).sort('timestamp': -1).first.nil? ? 0 : Reading.by_register_id(virtual_register.id).sort('timestamp': -1).first.energy_milliwatt_hour,
          "observer_min_threshold"=>100,
          "observer_max_threshold"=>5000,
          "observer_enabled"=>false,
          "observer_offline_monitoring"=>false
        }
      end

      let(:registers_json) do
        Register::Base.all.reload.collect do |register|
          json = {
            "id"=>register.id,
            "type"=>"register_#{register.is_a?(Register::Real) ? 'real': 'virtual'}",
            "direction"=>register.attributes['direction'],
            "name"=>register.name,
            "pre_decimal_position"=>register.pre_decimal_position,
            "post_decimal_position"=>register.post_decimal_position,
            "low_load_ability"=>register.low_load_ability,
            "label"=>register.attributes['label'],
            "last_reading"=>Reading.by_register_id(register.id).sort('timestamp': -1).first.nil? ? 0 : Reading.by_register_id(register.id).sort('timestamp': -1).first.energy_milliwatt_hour,
            "observer_min_threshold"=>register.observer_min_threshold,
            "observer_max_threshold"=>register.observer_max_threshold,
            "observer_enabled"=>register.observer_enabled,
            "observer_offline_monitoring"=>register.observer_offline_monitoring,
          }
          if register.is_a? Register::Real
            json["metering_point_id"] = register.metering_point_id
            json["obis"] = register.obis
          end
          json
        end
      end
      
      # NOTE picking a sample register is enough for the 404 tests

      let(:register) do
        register = [real_register, virtual_register].sample
        Fabricate(:reading, register_id: register.id)
        register
      end

      it '404' do
        GET "/#{group.id}/registers/bla-blub", admin
        expect(response).to have_http_status(404)
        expect(json).to eq not_found_json
      end

      it '200 all' do
        GET "/#{group.id}/registers", admin
        expect(response).to have_http_status(200)
        expect(sort(json['array']).to_yaml).to eq sort(registers_json).to_yaml
      end

      [:real, :virtual].each do |type|

        context "as #{type}" do
          let(:virtual_registers_json) { [ virtual_register_json ] }
          let(:real_registers_json) do
            Register::Real.all.collect do |register|
              {
                "id"=>register.id,
                "type"=>"register_real",
                "direction"=>register.attributes['direction'],
                "name"=>register.name,
                "pre_decimal_position"=>register.pre_decimal_position,
                "post_decimal_position"=>register.post_decimal_position,
                "low_load_ability"=>register.low_load_ability,
                "label"=>register.attributes['label'],
                "last_reading"=>Reading.by_register_id(register.id).sort('timestamp': -1).first.nil? ? 0 : Reading.by_register_id(register.id).sort('timestamp': -1).first.energy_milliwatt_hour,
                "observer_min_threshold"=>register.observer_min_threshold,
                "observer_max_threshold"=>register.observer_max_threshold,
                "observer_enabled"=>register.observer_enabled,
                "observer_offline_monitoring"=>register.observer_offline_monitoring,
                "metering_point_id"=>register.metering_point_id,
                "obis"=>register.obis
              }
            end
          end

          it '200 all' do
            register = send "#{type}_register"
            registers_json = send("#{type}_registers_json")

            GET "/#{group.id}/meters/#{register.meter.id}/registers", admin
            expect(response).to have_http_status(200)
            expect(sort(json['array']).to_yaml).to eq sort(registers_json).to_yaml
          end

          it '200' do
            register = send "#{type}_register"
            register_json = send "#{type}_register_json"

            GET "/#{group.id}/registers/#{register.id}", admin
            expect(response).to have_http_status(200)
            expect(json.to_yaml).to eq register_json.to_yaml

            GET "/#{group.id}/meters/#{register.meter.id}/registers/#{register.id}", admin
            expect(response).to have_http_status(200)
            expect(json.to_yaml).to eq register_json.to_yaml
          end
        end
      end
    end

    context 'readings' do
      context 'GET' do

        # NOTE picking a sample register is enough for the 404 and 403 tests

        let(:register) do
          [real_register, virtual_register].sample
        end

        xit '403' do
          GET "/#{group.id}/registers/#{register.id}/readings", user
          expect(response).to have_http_status(403)
          expect(json).to eq denied_json
        end

        it '404' do
          GET "/#{group.id}/registers/bla-blub/readings", admin
          expect(response).to have_http_status(404)
          expect(json).to eq not_found_json
        end

        [:real, :virtual].each do |type|

          context "as #{type}" do

            let(:register) { send "#{type}_register" }
            let!(:readings_json) do
              Reading.all.delete_all
              readings = 2.times.collect { Fabricate(:reading, register_id: register.id) }
              readings.collect do |r|
                {
                  "id"=>r.id.to_s,
                  "type"=>"reading",
                  "energy_milliwatt_hour"=>r.energy_milliwatt_hour,
                  "power_milliwatt"=>r.power_milliwatt,
                  "timestamp"=>r.timestamp.utc.to_s.sub('+00:00','.000Z'),
                  "reason"=>"regular_reading",
                  "source"=>"buzzn_systems",
                  "quality"=>"read_out",
                  "meter_serialnumber"=>'12346578'
                }
              end
            end

            it '200' do
              GET "/#{group.id}/registers/#{register.id}/readings", admin

              expect(response).to have_http_status(200)
              expect(json['array'].to_yaml).to eq readings_json.to_yaml
            end
          end
        end
      end
    end
  end
end
