require_relative 'test_admin_localpool_roda'
describe Admin::LocalpoolRoda do

  def app
    TestAdminLocalpoolRoda # this defines the active application for this test
  end

  context 'meters as virtual' do

    entity(:group) do
      group = create(:localpool)
      $user.person.reload.add_role(Role::GROUP_MEMBER, group)
      group
    end

    entity(:meter) do
      meter = create(:meter, :virtual, group: group)
      create(:formula_part, operand: create(:meter, :real, group: group).input_register,
             register: meter.register)
      meter
    end

    entity!(:register) { meter.register }

    entity!(:register2) { Fabricate(:output_meter, group: group).registers.first }

    entity!(:formula_part) { register.formula_parts.first }

    let(:meter_json) do
      {
        'id'=>meter.id,
        'type'=>'meter_virtual',
        'updated_at'=> meter.updated_at.as_json,
        'product_name'=>meter.product_name,
        'product_serialnumber'=>meter.product_serialnumber,
        'sequence_number' => nil,
        'updatable'=>true,
        'deletable'=>true,
        'formula_parts'=> {
          'array'=> register.formula_parts.collect do |part|
            {
              'id'=>part.id,
              'type'=>'meter_formula_part',
              'updated_at'=> part.updated_at.as_json,
              'operator'=>part.attributes['operator'],
              'register'=>{
                'id'=>part.operand.id,
                'type'=>'register_real',
                'updated_at'=> part.operand.updated_at.as_json,
                'direction'=>part.operand.attributes['direction'],
                'pre_decimal_position'=>part.operand.pre_decimal_position,
                'post_decimal_position'=>part.operand.post_decimal_position,
                'low_load_ability'=>part.operand.low_load_ability,
                'label'=>part.operand.attributes['label'],
                'last_reading'=>0,
                'observer_min_threshold'=> part.operand.observer_min_threshold,
                'observer_max_threshold'=> part.operand.observer_max_threshold,
                'observer_enabled'=> part.operand.observer_enabled,
                'observer_offline_monitoring'=> part.operand.observer_offline_monitoring,
                'meter_id' => part.operand.meter_id,
                'kind' => part.operand.label.production? ? 'production' : 'consumption',
                'updatable'=>false,
                'deletable'=>false,
                'createables' => ['readings'],
                'metering_point_id'=>part.operand.metering_point_id,
                'obis'=>part.operand.obis
              }
            }
          end
        }
      }
    end

    context 'GET' do

      it '401' do
        GET "/test/#{group.id}/meters/#{meter.id}", $admin
        expire_admin_session do
          GET "/test/#{group.id}/meters/#{meter.id}", $admin
          expect(response).to be_session_expired_json(401)

          GET "/test/#{group.id}/meters", $admin
          expect(response).to be_session_expired_json(401)
        end
      end

      it '403' do
        GET "/test/#{group.id}/meters/#{meter.id}", $user
        expect(response).to be_denied_json(403, meter)
      end

      it '404' do
        GET "/test/#{group.id}/meters/bla-blub", $admin
        expect(response).to be_not_found_json(404, Meter::Base)
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
          'errors'=>[
            {'parameter'=>'product_name',
             'detail'=>'size cannot be greater than 64'},
            {'parameter'=>'product_serialnumber',
             'detail'=>'size cannot be greater than 128'},
            {'parameter'=>'updated_at',
             'detail'=>'is missing'}
          ]
        }
      end

      let(:updated_json) do
        {
          'id'=>meter.id,
          'type'=>'meter_virtual',
          'product_name'=>'SmartySuper',
          'product_serialnumber'=>'41234',
          'sequence_number' => nil,
          'updatable'=>true,
          'deletable'=>true,
        }
      end

      it '401' do
        GET "/test/#{group.id}/meters/#{meter.id}", $admin
        expire_admin_session do
          PATCH "/test/#{group.id}/meters/#{meter.id}", $admin
          expect(response).to be_session_expired_json(401)
        end
      end

      it '403' do
        PATCH "/test/#{group.id}/meters/#{meter.id}", $user
        expect(response).to be_denied_json(403, meter)
      end

      it '404' do
        PATCH "/test/#{group.id}/meters/bla-blub", $admin
        expect(response).to be_not_found_json(404, Meter::Base)
      end

      it '409' do
        PATCH "/test/#{group.id}/meters/#{meter.id}", $admin,
              updated_at: DateTime.now
        expect(response).to be_stale_json(409, meter)
      end

      it '422' do
        PATCH "/test/#{group.id}/meters/#{meter.id}", $admin,
              manufacturer_name: 'Maxima' * 20,
              product_name: 'SmartyMeter' * 10,
              product_serialnumber: '12341234' * 20

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

        it '401' do
          GET "/test/#{group.id}/meters/#{meter.id}/formula-parts/#{formula_part.id}", $admin
          expire_admin_session do
            GET "/test/#{group.id}/meters/#{meter.id}/formula-parts/#{formula_part.id}", $admin
            expect(response).to be_session_expired_json(401)

            GET "/test/#{group.id}/meters/#{meter.id}/formula-parts", $admin
            expect(response).to be_session_expired_json(401)
          end
        end

        it '404' do
          GET "/test/#{group.id}/meters/#{meter.id}/formula-parts/bla-blub", $admin
          expect(response).to be_not_found_json(404, Register::FormulaPart)
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

        let(:wrong_json) do
          {
            'errors'=>[
              {'parameter'=>'updated_at',
               'detail'=>'is missing'},
              {'parameter'=>'operator',
               'detail'=>'must be one of: +, -'},
            ]
          }
        end

        let(:updated_json) do
          {
            'id'=>formula_part.id,
            'type'=>'meter_formula_part',
            'operator'=> '-'
          }
        end

        it '401' do
          GET "/test/#{group.id}/meters/#{meter.id}/formula-parts/#{formula_part.id}", $admin
          expire_admin_session do
            PATCH "/test/#{group.id}/meters/#{meter.id}/formula-parts/#{formula_part.id}", $admin
            expect(response).to be_session_expired_json(401)
          end
        end

        it '404' do
          PATCH "/test/#{group.id}/meters/#{meter.id}/formula-parts/bla-blub", $admin
          expect(response).to be_not_found_json(404, Register::FormulaPart)

          PATCH "/test/#{group.id}/meters/#{meter.id}/formula-parts/#{formula_part.id}",
                $admin,
                updated_at: DateTime.now,
                register_id: 123
          expect(response).to be_not_found_json(404, Register::Base, 123)
        end

        it '403' do
          PATCH "/test/#{group.id}/meters/#{meter.id}/formula-parts/#{formula_part.id}", $user
          expect(response).to be_denied_json(403, meter)
        end

        it '409' do
          PATCH "/test/#{group.id}/meters/#{meter.id}/formula-parts/#{formula_part.id}", $admin,
                updated_at: DateTime.now
          expect(response).to be_stale_json(409, formula_part)
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
