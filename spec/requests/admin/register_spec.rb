require_relative 'test_admin_localpool_roda'
describe Admin::LocalpoolRoda, :request_helper do

  def app
    TestAdminLocalpoolRoda # this defines the active application for this test
  end

  let(:group) { create(:group, :localpool) }

  let(:meter) { create(:meter, :real, group: group) }

  let!(:real_register) do
    register = meter.registers.first
    create(:contract, :localpool_processing, localpool: group)
    create(:contract, :localpool_powertaker, register_meta: register.meta, localpool: group)
    register
  end

  let!(:register) { create(:register, :output, meter: meter) }

  let!(:virtual_register) { create(:meter, :virtual, group: group).register }

  context 'meters' do
    context 'registers' do

      it 'PUT - 405' do
        PUT "/localpools/#{group.id}/meters/#{meter.id}/registers/#{register.id}", $admin
        expect(response).to have_http_status(405)
        expect(response.headers['X-Allowed-Methods']).to eq('get, patch')
      end

    end
  end

  context 'registers' do
    context 'PATCH' do
      let(:register_first) do
        create(:register, :real, meta: nil)
      end
      let(:register_second) do
        create(:register, :real)
      end
      let(:meter) do
        create(:meter, :real, group: group, registers: [register_first, register_second])
      end

      context 'creation' do
        let(:grid_consumption_register) { build(:meta, :grid_consumption) }
        let(:market_location_id) do
          'DE133713371'
        end
        let(:grid_consumption_register_params) do
          params = grid_consumption_register.attributes
          params = params.delete_if {|k, v| k.ends_with?('id')}
          params = params.delete_if {|k, v| v.nil? }
          params.delete('updated_at')
          params.delete('created_at')
          params['market_location_id'] = market_location_id
          params
        end
        let(:params) do
          {
            updated_at: register_first.updated_at.to_json,
            meta: grid_consumption_register_params
          }
        end

        it '403' do
          PATCH "/localpools/#{group.id}/meters/#{meter.id}/registers/#{register_first.id}", nil, params
          expect(response).to have_http_status(403)
        end

        it '201' do
          PATCH "/localpools/#{group.id}/meters/#{meter.id}/registers/#{register_first.id}", $admin, params
          expect(response).to have_http_status(200)
          register_first.reload
          expect(register_first.meta).not_to be_nil
          expect(register_first.meta.name).to eql grid_consumption_register_params['name']
        end

      end

      context 'assignment' do
        let(:register_meta) { create(:meta) }
        let(:params) do
          {
            updated_at: register_first.updated_at.to_json,
            meta: {
              id: register_meta.id
            }
          }
        end

        it '403' do
          PATCH "/localpools/#{group.id}/meters/#{meter.id}/registers/#{register_first.id}", nil, params
          expect(response).to have_http_status(403)
        end

        it '201' do
          PATCH "/localpools/#{group.id}/meters/#{meter.id}/registers/#{register_first.id}", $admin, params
          expect(response).to have_http_status(200)
          register_first.reload
          expect(register_first.meta.id).to eql register_meta.id
        end
      end

    end

    context 'GET' do

      let(:real_register_json) do
        last = real_register.readings.order('date').last
        {
          'id'=>real_register.id,
          'type'=>'register_real',
          'created_at'=>real_register.created_at.as_json,
          'updated_at'=>real_register.updated_at.as_json,
          'direction'=>real_register.consumption? ? 'in' : 'out',
          'last_reading'=>last ? last.value : 0,
          'meter_id' => real_register.meter_id,
          'updatable'=> true,
          'deletable'=> true,
          'createables'=>['readings', 'contracts'],
          'pre_decimal_position'=>6,
          'post_decimal_position'=>real_register.post_decimal_position,
          'low_load_ability'=>false,
          'obis'=>real_register.obis,
        }
      end

      let(:virtual_register_json) do
        last = virtual_register.readings.order('date').last
        {
          'id'=>virtual_register.id,
          'type'=>'register_virtual',
          'updated_at'=>virtual_register.updated_at.as_json,
          'direction'=>virtual_register.label.consumption? ? 'in' : 'out',
          'last_reading'=>last ? last.value : 0,
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
            'created_at'=>register.created_at.as_json,
            'updated_at'=>register.updated_at.as_json,
            'last_reading'=>last ? last.value : 0,
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
                'created_at'=>register.created_at.as_json,
                'updated_at'=>register.updated_at.as_json,
                'direction'=>register.consumption? ? 'in' : 'out',
                'last_reading'=> last ? last.value : 0,
                'meter_id' => register.meter_id,
                'updatable'=> true,
                'deletable'=> true,
                'createables'=>['readings', 'contracts'],
                'pre_decimal_position'=>register.pre_decimal_position,
                'post_decimal_position'=>register.post_decimal_position,
                'low_load_ability'=>register.low_load_ability,
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

            GET "/localpools/#{group.id}/meters/#{register.meter.id}/registers/#{register.id}", $admin, include: 'register_meta:contracts'
            expect(response).to have_http_status(200)

            expect(json).to has_nested_json(:register_meta, :contracts, :array, :id)

            result = json
            result.delete('register_meta')
            expect(result.to_yaml).to eq register_json.to_yaml
          end
        end
      end
    end
  end
end
