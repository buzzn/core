describe Display::GroupRoda do

  def app
    Display::GroupRoda # this defines the active application for this test
  end

  context 'registers' do

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

    entity(:group) { Fabricate([:tribe, :localpool].sample) }

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

    context 'GET' do

      let(:real_register_json) do
        meter = real_register.meter
        {
          "id"=>real_register.id,
          "type"=>"register_real",
          "direction"=>real_register.direction.to_s,
          "name"=>real_register.name,
          "label"=>real_register.label,
        }
      end

      let(:virtual_register_json) do
        meter = virtual_register.meter
        {
          "id"=>virtual_register.id,
          "type"=>"register_virtual",
          "direction"=>virtual_register.direction.to_s,
          "name"=>virtual_register.name,
          "label"=>virtual_register.label,
        }
      end

      let(:registers_json) do
        [ real_register_json, virtual_register_json]
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
        expect(sort(json).to_yaml).to eq sort(registers_json).to_yaml
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
        [:real, :virtual].each do |type|

          context "as #{type}" do

            let(:register) { send "#{type}_register" }

            it '404' do
              GET "/#{group.id}/registers/#{register.id}/readings", admin

              expect(response).to have_http_status(404)
            end
          end
        end
      end
    end
  end
end
