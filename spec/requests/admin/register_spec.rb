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

  entity!(:real_register) do
    reg = Fabricate(:real_meter).registers.first
    reg.group = group
    reg.save
    reg
  end

  entity!(:virtual_register) do
    reg = Fabricate(:virtual_meter).register
    reg.group = group
    reg.save
    reg
  end

  context 'registers' do
    context 'GET' do

      let(:real_register_json) do
        meter = real_register.meter
        {
          "id"=>real_register.id,
          "type"=>"register_real",
          "direction"=>real_register.direction.to_s,
          "name"=>real_register.name,
          "pre_decimal"=>6,
          "decimal"=>2,
          "converter_constant"=>1,
          "low_power"=>false,
          "label"=>real_register.label,
          "last_reading"=>Reading.by_register_id(real_register.id).sort('timestamp': -1).first.nil? ? 0 : Reading.by_register_id(real_register.id).sort('timestamp': -1).first.energy_milliwatt_hour,
          "uid"=>real_register.uid,
          "obis"=>real_register.obis,
        }
      end

      let(:virtual_register_json) do
        meter = virtual_register.meter
        {
          "id"=>virtual_register.id,
          "type"=>"register_virtual",
          "direction"=>virtual_register.direction.to_s,
          "name"=>virtual_register.name,
          "pre_decimal"=>6,
          "decimal"=>2,
          "converter_constant"=>1,
          "low_power"=>false,
          "label"=>virtual_register.label,
          "last_reading"=>Reading.by_register_id(virtual_register.id).sort('timestamp': -1).first.nil? ? 0 : Reading.by_register_id(virtual_register.id).sort('timestamp': -1).first.energy_milliwatt_hour,
        }
      end

      let(:registers_json) do
        [real_register_json] + Register::Virtual.all.collect do |register|
          {
            "id"=>register.id,
            "type"=>"register_virtual",
            "direction"=>register.direction.to_s,
            "name"=>register.name,
            "pre_decimal"=>register.digits_before_comma,
            "decimal"=>register.decimal_digits,
            "converter_constant"=>1,
            "low_power"=>register.low_load_ability,
            "label"=>register.label,
            "last_reading"=>Reading.by_register_id(register.id).sort('timestamp': -1).first.nil? ? 0 : Reading.by_register_id(register.id).sort('timestamp': -1).first.energy_milliwatt_hour,
          }
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
        GET "/#{group.id}/registers?include=meter", admin
        expect(response).to have_http_status(200)
        expect(sort(json['array']).to_yaml).to eq sort(registers_json).to_yaml
      end

      [:real, :virtual].each do |type|

        context "as #{type}" do
          it '200' do
            register = send "#{type}_register"
            register_json = send "#{type}_register_json"

            GET "/#{group.id}/registers/#{register.id}?include=meter", admin
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
                  "timestamp"=>r.timestamp.to_s.sub('+01','.000+01'),
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
