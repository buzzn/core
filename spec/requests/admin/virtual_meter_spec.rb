require_relative 'test_admin_localpool_roda'
describe Admin::LocalpoolRoda, :request_helper, :order => :defined do

  def app
    TestAdminLocalpoolRoda # this defines the active application for this test
  end

  context 'meters as virtual' do

    entity(:group) do
      group = create(:group, :localpool)
      $user.person.reload.add_role(Role::GROUP_MEMBER, group)
      group
    end

    entity(:meter) do
      meter = create(:meter, :virtual, group: group)
      create(:formula_part, operand: create(:meter, :real, group: group).registers.first,
             register: meter.register)
      meter
    end

    entity!(:register) { meter.register }

    entity!(:register2) { create(:meter, :real, register_label: :production_pv, group: group).registers.first }

    entity!(:formula_part) { register.formula_parts.first }

    let(:meter_json) do
      {
        'id'=>meter.id,
        'type'=>'meter_virtual',
        'created_at'=> meter.created_at.as_json,
        'updated_at'=> meter.updated_at.as_json,
        'product_serialnumber'=>meter.product_serialnumber,
        'sequence_number' => meter.sequence_number,
        'datasource' => meter.datasource.to_s,
        'updatable'=>true,
        'deletable'=>true,
        'formula_parts'=> {
          'array'=> register.formula_parts.collect do |part|
            {
              'id'=>part.id,
              'type'=>'meter_formula_part',
              'created_at'=> part.created_at.as_json,
              'updated_at'=> part.updated_at.as_json,
              'operator'=>part.attributes['operator'],
              'register'=>{
                'id'=>part.operand.id,
                'type'=>'register_real',
                'created_at'=> part.operand.created_at.as_json,
                'updated_at'=> part.operand.updated_at.as_json,
                'direction'=>part.operand.meta.label.consumption? ? 'in' : 'out',
                'last_reading'=>0,
                'meter_id' => part.operand.meter_id,
                'updatable'=>false,
                'deletable'=>false,
                'createables' => ['readings', 'contracts'],
                'pre_decimal_position'=>part.operand.pre_decimal_position,
                'post_decimal_position'=>part.operand.post_decimal_position,
                'low_load_ability'=>part.operand.low_load_ability,
                'obis'=>part.operand.obis
              }
            }
          end
        }
      }
    end

    context 'GET' do

      it '401' do
        GET "/localpools/#{group.id}/meters/#{meter.id}", $admin
        expire_admin_session do
          GET "/localpools/#{group.id}/meters/#{meter.id}", $admin
          expect(response).to be_session_expired_json(401)

          GET "/localpools/#{group.id}/meters", $admin
          expect(response).to be_session_expired_json(401)
        end
      end

      it '403' do
        GET "/localpools/#{group.id}/meters/#{meter.id}", $user
        expect(response).to have_http_status(403)
      end

      it '404' do
        GET "/localpools/#{group.id}/meters/bla-blub", $admin
        expect(response).to have_http_status(404)
      end

      it '200' do
        GET "/localpools/#{group.id}/meters/#{meter.id}", $admin, include: 'formula_parts: register'
        expect(response).to have_http_status(200)
        expect(json.to_yaml).to eq meter_json.to_yaml
      end
    end

    context 'formula-parts' do

      context 'GET' do

        let(:part_json) do
          {
            'id'=>formula_part.id,
            'type'=>'meter_formula_part',
            'created_at'=> formula_part.created_at.as_json,
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
          GET "/localpools/#{group.id}/meters/#{meter.id}/formula-parts/#{formula_part.id}", $admin
          expire_admin_session do
            GET "/localpools/#{group.id}/meters/#{meter.id}/formula-parts/#{formula_part.id}", $admin
            expect(response).to be_session_expired_json(401)

            GET "/localpools/#{group.id}/meters/#{meter.id}/formula-parts", $admin
            expect(response).to be_session_expired_json(401)
          end
        end

        it '404' do
          GET "/localpools/#{group.id}/meters/#{meter.id}/formula-parts/bla-blub", $admin
          expect(response).to have_http_status(404)
        end

        it '200 all' do
          GET "/localpools/#{group.id}/meters/#{meter.id}/formula-parts", $admin
          expect(response).to have_http_status(200)
          expect(json.to_yaml).to eq parts_json.to_yaml
        end

        it '200' do
          GET "/localpools/#{group.id}/meters/#{meter.id}/formula-parts/#{formula_part.id}", $admin
          expect(response).to have_http_status(200)
          expect(json.to_yaml).to eq part_json.to_yaml
        end
      end

      context 'PATCH' do

        let(:wrong_json) do
          {
            'updated_at'=>['is missing'],
            'operator'=>['must be one of: +, -']
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
          GET "/localpools/#{group.id}/meters/#{meter.id}/formula-parts/#{formula_part.id}", $admin
          expire_admin_session do
            PATCH "/localpools/#{group.id}/meters/#{meter.id}/formula-parts/#{formula_part.id}", $admin
            expect(response).to be_session_expired_json(401)
          end
        end

        it '404' do
          PATCH "/localpools/#{group.id}/meters/#{meter.id}/formula-parts/bla-blub", $admin
          expect(response).to have_http_status(404)

          PATCH "/localpools/#{group.id}/meters/#{meter.id}/formula-parts/#{formula_part.id}",
                $admin,
                updated_at: formula_part.updated_at,
                register_id: 123
          expect(response).to have_http_status(404)
        end

        it '403' do
          PATCH "/localpools/#{group.id}/meters/#{meter.id}/formula-parts/#{formula_part.id}", $user
          expect(response).to have_http_status(403)
        end

        it '409' do
          PATCH "/localpools/#{group.id}/meters/#{meter.id}/formula-parts/#{formula_part.id}", $admin,
                updated_at: DateTime.now + 2.seconds
          expect(response).to have_http_status(409)
        end

        it '422' do
          PATCH "/localpools/#{group.id}/meters/#{meter.id}/formula-parts/#{formula_part.id}", $admin,
                operator: '+/-'

          expect(response).to have_http_status(422)
          expect(json.to_yaml).to eq wrong_json.to_yaml
        end

        it '200' do
          old = meter.updated_at
          PATCH "/localpools/#{group.id}/meters/#{meter.id}/formula-parts/#{formula_part.id}", $admin,
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
          expect(result.delete('created_at')).not_to be_nil
          expect(result.to_yaml).to eq updated_json.to_yaml
        end
      end
    end
  end
end
