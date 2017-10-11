require_relative 'test_admin_localpool_roda'
describe Admin::LocalpoolRoda do

  def app
    TestAdminLocalpoolRoda # this defines the active application for this test
  end

  context 'meters as virtual' do

    entity(:group) do
      group = Fabricate(:localpool)
      $user.person.add_role(Role::GROUP_MEMBER, group)
      group
    end

    let(:denied_json) do
      {
        "errors" => [
          {
            "detail"=>"retrieve Meter::Virtual: #{meter.id} permission denied for User: #{$user.id}" }
        ]
      }
    end

    let(:not_found_json) do
      {
        "errors" => [
          {
            "detail"=>"Meter::Base: bla-blub not found by User: #{$admin.id}"
          }
        ]
      }
    end

    entity(:meter) do
      meter = Fabricate(:virtual_meter)
      meter.register.update(group: group)
      meter.update(group: group)
      Fabricate(:fp_plus, operand: Fabricate(:meter).registers.first,
                register: meter.register)
      meter
    end

    entity!(:register) { meter.register }

    entity!(:register2)do
      reg = Fabricate(:output_meter).registers.first
      reg.update(group: group)
      reg
    end

    entity!(:formula_part) { register.formula_parts.first }

    let(:meter_json) do
      {
        "id"=>meter.id,
        "type"=>"meter_virtual",
        'updated_at'=> meter.updated_at.as_json,
        "product_name"=>meter.product_name,
        "product_serialnumber"=>meter.product_serialnumber,
        'sequence_number' => 0,
        "updatable"=>true,
        "deletable"=>true,
        "formula_parts"=> {
          'array'=> register.formula_parts.collect do |part|
            {
              'id'=>part.id,
              'type'=>'meter_formula_part',
              'updated_at'=> part.updated_at.as_json,
              'operator'=>part.attributes['operator'],
              'register'=>{
                "id"=>part.operand.id,
                "type"=>"register_real",
                'updated_at'=> part.operand.updated_at.as_json,
                "direction"=>part.operand.attributes['direction'],
                "name"=>part.operand.name,
                "pre_decimal_position"=>part.operand.pre_decimal_position,
                "post_decimal_position"=>part.operand.post_decimal_position,
                "low_load_ability"=>part.operand.low_load_ability,
                "label"=>part.operand.attributes['label'],
                "last_reading"=>0,
                'observer_min_threshold'=> part.operand.observer_min_threshold,
                'observer_max_threshold'=> part.operand.observer_max_threshold,
                'observer_enabled'=> part.operand.observer_enabled,
                'observer_offline_monitoring'=> part.operand.observer_offline_monitoring,
                "updatable"=>true,
                "deletable"=>false,
                'createables' => ['readings'],
                "metering_point_id"=>part.operand.metering_point_id,
                "obis"=>part.operand.obis
              }
            }
          end
        }
      }
    end

    context 'GET' do

      it '403' do
        GET "/test/#{group.id}/meters/#{meter.id}", $user
        expect(response).to have_http_status(403)
        expect(json).to eq denied_json
      end

      it '404' do
        GET "/test/#{group.id}/meters/bla-blub", $admin
        expect(response).to have_http_status(404)
        expect(json).to eq not_found_json
      end

      it '200' do
        GET "/test/#{group.id}/meters/#{meter.id}", $admin, include: 'formula_parts: register'
        expect(response).to have_http_status(200)
        expect(json.to_yaml).to eq meter_json.to_yaml
      end
    end

    context 'PATCH' do

      let(:wrong_json) do
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

      let(:updated_json) do
        {
          "id"=>meter.id,
          "type"=>"meter_virtual",
          "product_name"=>'SmartySuper',
          "product_serialnumber"=>'41234',
          'sequence_number' => 0,
          "updatable"=>true,
          "deletable"=>true,
        }
      end

      let(:stale_json) do
        {
          "errors" => [
            {"detail"=>"Meter::Virtual: #{meter.id} was updated at: #{meter.updated_at}"}]
        }
      end

      it '403' do
        PATCH "/test/#{group.id}/meters/#{meter.id}", $user
        expect(response).to have_http_status(403)
        expect(json).to eq denied_json
      end

      it '404' do
        PATCH "/test/#{group.id}/meters/bla-blub", $admin
        expect(response).to have_http_status(404)
        expect(json).to eq not_found_json
      end

      it '409' do
        PATCH "/test/#{group.id}/meters/#{meter.id}", $admin,
              updated_at: DateTime.now
        expect(response).to have_http_status(409)
        expect(json).to eq stale_json
      end

      it '422' do
        PATCH "/test/#{group.id}/meters/#{meter.id}", $admin,
              manufacturer_name: 'Maxima' * 20,
              product_name: 'SmartyMeter' * 10,
              product_serialnumber: '12341234' * 10

        expect(response).to have_http_status(422)
        expect(json.to_yaml).to eq wrong_json.to_yaml
      end

      it '200' do
        old = meter.updated_at
        sleep 1
        PATCH "/test/#{group.id}/meters/#{meter.id}", $admin,
              updated_at: meter.updated_at,
              product_name: 'SmartySuper',
              product_serialnumber: '41234'

        expect(response).to have_http_status(200)
        meter.reload
        expect(meter.product_name).to eq 'SmartySuper'
        expect(meter.product_serialnumber).to eq '41234'

        result = json
        # TODO fix it: our time setup does not allow
        #expect(result.delete('updated_at')).to be > old.as_json
        expect(result.delete('updated_at')).not_to eq old.as_json
        expect(result.to_yaml).to eq updated_json.to_yaml
      end
    end

    context 'formula-parts' do

      let(:not_found_json) do
        {
          "errors" => [
            {"detail"=>"Register::FormulaPart: bla-blub not found by User: #{$admin.id}"}
          ]
        }
      end

      context 'GET' do

        let(:part_json) do
          {
            'id'=>formula_part.id,
            'type'=>'meter_formula_part',
            'updated_at'=> formula_part.updated_at.as_json,
            'operator'=>formula_part.attributes['operator'],
          }
        end

        let(:parts_json) do
          {
            'array'=>[part_json]
          }
        end

        it '404' do
          GET "/test/#{group.id}/meters/#{meter.id}/formula-parts/bla-blub", $admin
          expect(response).to have_http_status(404)
          expect(json).to eq not_found_json
        end

        it '200 all' do
          GET "/test/#{group.id}/meters/#{meter.id}/formula-parts", $admin
          expect(response).to have_http_status(200)
          expect(json.to_yaml).to eq parts_json.to_yaml
        end

        it '200' do
          GET "/test/#{group.id}/meters/#{meter.id}/formula-parts/#{formula_part.id}", $admin
          expect(response).to have_http_status(200)
          expect(json.to_yaml).to eq part_json.to_yaml
        end
      end

      context 'PATCH' do
      
        let(:register_not_found_json) do
          {
            "errors" => [
              {"detail"=>"Register::Base: something not found by User: #{$admin.id}"}
            ]
          }
        end

        let(:register_denied_json) do
          {
            "errors" => [
              {"detail"=>"retrieve Register::Output: #{register2.id} permission denied for User: #{$admin.id}"}
            ]
          }
        end

        let(:wrong_json) do
          {
            "errors"=>[
              {"parameter"=>"updated_at",
               "detail"=>"is missing"},
              {"parameter"=>"operator",
               "detail"=>"must be one of: +, -"},
            ]
          }
        end

        let(:stale_json) do
          {
            "errors" => [
              {"detail"=>"Register::FormulaPart: #{formula_part.id} was updated at: #{formula_part.updated_at}"}]
          }
        end
  
        let(:updated_json) do
          {
            "id"=>formula_part.id,
            "type"=>"meter_formula_part",
            'operator'=> '-'
          }
        end

        it '404' do
          PATCH "/test/#{group.id}/meters/#{meter.id}/formula-parts/bla-blub", $admin
          expect(response).to have_http_status(404)
          expect(json).to eq not_found_json

          PATCH "/test/#{group.id}/meters/#{meter.id}/formula-parts/#{formula_part.id}",
                $admin,
                updated_at: DateTime.now,
                register_id: 'something'
          expect(response).to have_http_status(404)
          expect(json).to eq register_not_found_json
        end
        
        it '403' do
          PATCH "/test/#{group.id}/meters/#{meter.id}/formula-parts/#{formula_part.id}", $user
          expect(response).to have_http_status(403)
          expect(json).to eq denied_json

          register2.update(group: nil)
          begin
            PATCH "/test/#{group.id}/meters/#{meter.id}/formula-parts/#{formula_part.id}",
                  $admin,
                  updated_at: DateTime.now,
                  register_id: register2.id
            expect(response).to have_http_status(403)
            expect(json).to eq register_denied_json
          ensure
            register2.update(group: group)
          end
        end

        it '409' do
          PATCH "/test/#{group.id}/meters/#{meter.id}/formula-parts/#{formula_part.id}", $admin,
                updated_at: DateTime.now
          expect(response).to have_http_status(409)
          expect(json).to eq stale_json
        end

        it '422' do
          PATCH "/test/#{group.id}/meters/#{meter.id}/formula-parts/#{formula_part.id}", $admin,
                operator: '+/-'

          expect(response).to have_http_status(422)
          expect(json.to_yaml).to eq wrong_json.to_yaml
        end

        it '200' do
          old = meter.updated_at
          PATCH "/test/#{group.id}/meters/#{meter.id}/formula-parts/#{formula_part.id}", $admin,
                updated_at: formula_part.updated_at,
                operator: '-',
                register_id: register2.id

          expect(response).to have_http_status(200)
          formula_part.reload
          expect(formula_part.minus?).to eq true
          expect(formula_part.operand).to eq register2

          result = json
          # TODO fix it: our time setup does not allow
          #expect(result.delete('updated_at')).to be > old.as_json
          expect(result.delete('updated_at')).not_to eq old.as_json
          expect(result.to_yaml).to eq updated_json.to_yaml
        end
      end
    end
  end
end
