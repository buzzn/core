describe "registers" do

  let(:admin) do
    Fabricate(:admin_token)
  end

  let(:user) do
    Fabricate(:user_token)
  end

  let(:anonymous_denied_json) do
    {
      "errors" => [
        { "title"=>"Permission Denied",
          "detail"=>"retrieve Register::Base: permission denied for User: --anonymous--" }
      ]
    }
  end

  let(:denied_json) do
    json = anonymous_denied_json.dup
    json['errors'][0]['detail'].sub! /--anonymous--/, user.resource_owner_id 
    json
  end

  let(:anonymous_not_found_json) do
    {
      "errors" => [
        { "title"=>"Record Not Found",
          "detail"=>"Register::Base: bla-blub not found" }
      ]
    }
  end

  let(:not_found_json) do
    json = anonymous_not_found_json.dup
    json['errors'][0]['detail'] = "Register::Base: bla-blub not found by User: #{admin.resource_owner_id}"
    json
  end

  let(:real_register) do
    Fabricate(:real_meter).registers.first
  end

  let(:virtual_register) do
    Fabricate(:virtual_meter).register
  end

  context 'GET' do

    let(:real_register_json) do
      {
        "data"=>{
          "id"=>real_register.id,
          "attributes"=>{
            "type"=>"register_real",
            "direction"=>real_register.direction.to_s,
            "name"=>real_register.name,
            "pre-decimal"=>6,
            "decimal"=>2,
            "converter-constant"=>1,
            "low-power"=>false,
            "uid"=>real_register.uid,
            "obis"=>real_register.obis
          },
          "relationships"=>{
            "address"=>{
              "data"=>nil
            },
            "meter"=>{
              "data"=>{
                "id"=>real_register.meter_id,
                "type"=>"meter-reals"
              }
            },
            "devices"=>{
              "data"=>[]
            }
          }
        }
      }
    end

    let(:virtual_register_json) do
      {
        "data"=>{
          "id"=>virtual_register.id,
          "attributes"=>{
            "type"=>"register_virtual",
            "direction"=>virtual_register.direction.to_s,
            "name"=>virtual_register.name,
            "pre-decimal"=>6,
            "decimal"=>2,
            "converter-constant"=>1,
            "low-power"=>false
          },
          "relationships"=>{
            "address"=>{
              "data"=>nil
            },
            "meter"=>{
              "data"=>{
                "id"=>virtual_register.meter_id,
                "type"=>"meter-virtuals"
              }
            }
          }
        }
      }
    end

    # NOTE picking a sample register is enough for the 404 and 403 tests

    let(:register) do
      register = [real_register, virtual_register].sample
      Fabricate(:reading, register_id: register.id)
      register
    end

    it '403' do
      GET "/api/v1/registers/#{register.id}"
      expect(response).to have_http_status(403)
      expect(json).to eq anonymous_denied_json

      GET "/api/v1/registers/#{register.id}", user
      expect(response).to have_http_status(403)
      expect(json).to eq denied_json
    end

    it '404' do
      GET "/api/v1/registers/bla-blub"
      expect(response).to have_http_status(404)
      expect(json).to eq anonymous_not_found_json

      GET "/api/v1/registers/bla-blub", admin
      expect(response).to have_http_status(404)
      expect(json).to eq not_found_json
    end

    [:real, :virtual].each do |type|

      context "as #{type}" do
        it '200' do
          register = send "#{type}_register"
          register_json = send "#{type}_register_json"

          GET "/api/v1/registers/#{register.id}", admin
          expect(response).to have_http_status(200)
          # need to adjust json and remove faulty element
          result = json
          result['data'].delete('type')
          expect(result.to_yaml).to eq register_json.to_yaml
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

      it '403' do
        GET "/api/v1/registers/#{register.id}/readings"
        expect(response).to have_http_status(403)
        expect(json).to eq anonymous_denied_json

        GET "/api/v1/registers/#{register.id}/readings", user
        expect(response).to have_http_status(403)
        expect(json).to eq denied_json
      end

      it '404' do
        GET "/api/v1/registers/bla-blub/readings"
        expect(response).to have_http_status(404)
        expect(json).to eq anonymous_not_found_json

        GET "/api/v1/registers/bla-blub/readings", admin
        expect(response).to have_http_status(404)
        expect(json).to eq not_found_json
      end

      [:real, :virtual].each do |type|

        context "as #{type}" do

          let(:register) { send "#{type}_register" }
          let!(:readings_json) do
            readings = 5.times.collect { Fabricate(:reading, register_id: register.id) }
            {
              "data"=> readings.collect do |r|
                {
                  "id"=>r.id.to_s,
                  "type"=>"readings",
                  "attributes"=> {
                    "type"=>"reading",
                    "energy-milliwatt-hour"=>r.energy_milliwatt_hour,
                    "power-milliwatt"=>r.power_milliwatt,
                    "timestamp"=>r.timestamp.to_s.sub('+01','.000+01'),
                    "reason"=>"regular_reading",
                    "source"=>"buzzn_systems",
                    "quality"=>"read_out",
                    "meter-serialnumber"=>'12346578'
                  }
                }
              end
            }
          end

          it '200' do
            GET "/api/v1/registers/#{register.id}/readings", admin

            expect(response).to have_http_status(200)
            expect(json.to_yaml).to eq readings_json.to_yaml
          end
        end
      end
    end
  end
end
