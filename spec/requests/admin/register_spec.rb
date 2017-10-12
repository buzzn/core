require_relative 'test_admin_localpool_roda'
describe Admin::LocalpoolRoda do

  def app
    TestAdminLocalpoolRoda # this defines the active application for this test
  end

  let(:not_found_json) do
    {
      "errors" => [
        {
          "detail"=>"Register::Base: bla-blub not found by User: #{$admin.id}"
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
    meter.registers.detect{ |r| r != real_register }
  end

  entity!(:virtual_register) do
    reg = Fabricate(:virtual_meter).register
    reg.group = group
    reg.save
    reg
  end

  let(:expired_json) do
    {"error" => "This session has expired, please login again."}
  end

  context 'meters' do
   context 'registers' do
     context 'PATCH' do

       let(:not_found_json) do
         {
           "errors" => [
             {
               "detail"=>"Register::Real: bla-blub not found by User: #{$admin.id}"
             }
           ]
         }
       end

       let(:stale_json) do
         {
           "errors" => [
             {"detail"=>"#{register.class.name}: #{register.id} was updated at: #{register.updated_at}"}]
         }
       end

       let(:updated_json) do
         last = register.readings.order('date').last
         {
           "id"=>register.id,
           "type"=>"register_real",
           "direction"=>register.attributes['direction'],
           "name"=>'Smarty',
           "pre_decimal_position"=>4,
           "post_decimal_position"=>3,
           "low_load_ability"=>true,
           "label"=>'DEMARCATION_PV',
           "last_reading"=>last ? last.value : 0,
           "observer_min_threshold"=>10,
           "observer_max_threshold"=>100,
           "observer_enabled"=>true,
           "observer_offline_monitoring"=>true,
          'updatable'=> true,
          'deletable'=> false,
           "createables"=>["readings"],
           "metering_point_id"=>'123456',
           "obis"=>register.obis,
         }
       end

       let(:wrong_json) do
         {
           "errors"=>[
             {"parameter"=>"updated_at",
              "detail"=>"is missing"},
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

       it '401' do
         GET "/test/#{group.id}/meters/#{meter.id}/registers/#{register.id}", $admin
         Timecop.travel(Time.now + 30 * 60) do
           PATCH "/test/#{group.id}/meters/#{meter.id}/registers/#{register.id}", $admin

           expect(response).to have_http_status(401)
           expect(json).to eq(expired_json)
         end
       end

       it '404' do
         PATCH "/test/#{group.id}/meters/#{meter.id}/registers/bla-blub", $admin
         expect(response).to have_http_status(404)
         expect(json).to eq not_found_json
       end

       it '409' do
         PATCH "/test/#{group.id}/meters/#{meter.id}/registers/#{register.id}", $admin,
               updated_at: DateTime.now
         expect(response).to have_http_status(409)
         expect(json).to eq stale_json
       end

       it '422 wrong' do
         PATCH "/test/#{group.id}/meters/#{meter.id}/registers/#{register.id}", $admin,
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
         old = register.updated_at
         PATCH "/test/#{group.id}/meters/#{meter.id}/registers/#{register.id}", $admin,
               updated_at: register.updated_at,
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
          "id"=>real_register.id,
          "type"=>"register_real",
          'updated_at'=>real_register.updated_at.as_json,
          "direction"=>real_register.attributes['direction'],
          "name"=>real_register.name,
          "pre_decimal_position"=>6,
          "post_decimal_position"=>2,
          "low_load_ability"=>false,
          "label"=>real_register.attributes['label'],
          "last_reading"=>last ? last.value : 0,
          "observer_min_threshold"=>100,
          "observer_max_threshold"=>5000,
          "observer_enabled"=>false,
          "observer_offline_monitoring"=>false,
          'updatable'=> true,
          'deletable'=> false,
          "createables"=>["readings"],
          "metering_point_id"=>real_register.metering_point_id,
          "obis"=>real_register.obis,
        }
      end

      let(:virtual_register_json) do
        last = virtual_register.readings.order('date').last
        {
          "id"=>virtual_register.id,
          "type"=>"register_virtual",
          'updated_at'=>virtual_register.updated_at.as_json,
          "direction"=>virtual_register.attributes['direction'],
          "name"=>virtual_register.name,
          "pre_decimal_position"=>6,
          "post_decimal_position"=>2,
          "low_load_ability"=>false,
          "label"=>virtual_register.attributes['label'],
          "last_reading"=>last ? last.value : 0,
          "observer_min_threshold"=>100,
          "observer_max_threshold"=>5000,
          "observer_enabled"=>false,
          "observer_offline_monitoring"=>false,
          'updatable'=> true,
          'deletable'=> false,
          "createables"=>["readings"],
        }
      end

      let(:registers_json) do
        Register::Base.all.reload.collect do |register|
          last = register.readings.order('date').last
          json = {
            "id"=>register.id,
            "type"=>"register_#{register.is_a?(Register::Real) ? 'real': 'virtual'}",
            'updated_at'=>register.updated_at.as_json,
            "direction"=>register.attributes['direction'],
            "name"=>register.name,
            "pre_decimal_position"=>register.pre_decimal_position,
            "post_decimal_position"=>register.post_decimal_position,
            "low_load_ability"=>register.low_load_ability,
            "label"=>register.attributes['label'],
            "last_reading"=>last ? last.value : 0,
            "observer_min_threshold"=>register.observer_min_threshold,
            "observer_max_threshold"=>register.observer_max_threshold,
            "observer_enabled"=>register.observer_enabled,
            "observer_offline_monitoring"=>register.observer_offline_monitoring,
            'updatable'=> true,
            'deletable'=> false,
            "createables"=>["readings"]
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

      it '401' do
        GET "/test/#{group.id}/registers/#{register.id}", $admin
        Timecop.travel(Time.now + 30 * 60) do
          GET "/test/#{group.id}/registers/#{register.id}", $admin

          expect(response).to have_http_status(401)
          expect(json).to eq(expired_json)

          GET "/test/#{group.id}/registers", $admin

          expect(response).to have_http_status(401)
          expect(json).to eq(expired_json)
        end
      end

      it '404' do
        GET "/test/#{group.id}/registers/bla-blub", $admin
        expect(response).to have_http_status(404)
        expect(json).to eq not_found_json
      end

      it '200 all' do
        GET "/test/#{group.id}/registers", $admin
        expect(response).to have_http_status(200)
        expect(sort(json['array']).to_yaml).to eq sort(registers_json).to_yaml
      end

#      [:real, :virtual].each do |type|
      [:real].each do |type|

        context "as #{type}" do
          let(:virtual_registers_json) { [ virtual_register_json ] }
          let(:real_registers_json) do
            Register::Real.all.collect do |register|
              last = register.readings.order('date').last
              {
                "id"=>register.id,
                "type"=>"register_real",
                'updated_at'=>register.updated_at.as_json,
                "direction"=>register.attributes['direction'],
                "name"=>register.name,
                "pre_decimal_position"=>register.pre_decimal_position,
                "post_decimal_position"=>register.post_decimal_position,
                "low_load_ability"=>register.low_load_ability,
                "label"=>register.attributes['label'],
                "last_reading"=> last ? last.value : 0,
                "observer_min_threshold"=>register.observer_min_threshold,
                "observer_max_threshold"=>register.observer_max_threshold,
                "observer_enabled"=>register.observer_enabled,
                "observer_offline_monitoring"=>register.observer_offline_monitoring,
                'updatable'=> true,
                'deletable'=> false,
                "createables"=>["readings"],
                "metering_point_id"=>register.metering_point_id,
                "obis"=>register.obis
              }
            end
          end

          it '200 all' do
            register = send "#{type}_register"
            registers_json = send("#{type}_registers_json")

            GET "/test/#{group.id}/meters/#{register.meter.id}/registers", $admin
            expect(response).to have_http_status(200)
            expect(sort(json['array']).to_yaml).to eq sort(registers_json).to_yaml
          end

          it '200' do
            register = send "#{type}_register"
            register_json = send "#{type}_register_json"

            GET "/test/#{group.id}/registers/#{register.id}", $admin
            expect(response).to have_http_status(200)
            expect(json.to_yaml).to eq register_json.to_yaml

            GET "/test/#{group.id}/meters/#{register.meter.id}/registers/#{register.id}", $admin
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

        # note can not test 403 as we do need a user which has access to
        # the regsiter but not to the readings

        it '404' do
          GET "/test/#{group.id}/registers/bla-blub/readings", $admin
          expect(response).to have_http_status(404)
          expect(json).to eq not_found_json
        end

        [:real, :virtual].each do |type|

          context "as #{type}" do

            let(:register) { send "#{type}_register" }
            let!(:readings_json) do
              readings = 2.times
                           .collect { Fabricate(:single_reading, register: register) }
              readings.collect do |r|
                {
                  "id"=>r.id,
                  "type"=>"reading",
                  "updated_at"=> r.updated_at.as_json,
                  "date"=>r.date.as_json,
                  "raw_value"=>r.raw_value,
                  "value"=>r.value,
                  "unit"=>r.attributes['unit'],
                  "reason"=>r.attributes['reason'],
                  "read_by"=>r.attributes['read_by'],
                  "source"=>r.attributes['source'],
                  "quality"=>r.attributes['quality'],
                  "status"=>r.attributes['status'],
                  "comment"=>nil,
                  'updatable'=>false,
                  'deletable'=>true
                }
              end
            end

            it '200' do
              GET "/test/#{group.id}/registers/#{register.id}/readings", $admin

              expect(response).to have_http_status(200)
              expect(sort(json['array']).to_yaml).to eq sort(readings_json).to_yaml
            end
          end
        end
      end
    end
  end
end
