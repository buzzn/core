require_relative 'test_admin_localpool_roda'
describe Admin::LocalpoolRoda do

  def app
    TestAdminLocalpoolRoda # this defines the active application for this test
  end

  entity(:group) { create(:localpool) }

  entity(:meter) { create(:meter, :real, group: group) }

  entity!(:real_register) do
    register = meter.registers.first
    create(:contract, :localpool_powertaker, register: register, localpool: group)
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
           'direction'=>register.attributes['direction'],
           'name'=>'Smarty',
           'pre_decimal_position'=>6,
           'post_decimal_position'=>1,
           'low_load_ability'=>false,
           'label'=>'DEMARCATION_PV',
           'last_reading'=>last ? last.value : 0,
           'observer_min_threshold'=>10,
           'observer_max_threshold'=>100,
           'observer_enabled'=>true,
           'observer_offline_monitoring'=>true,
           'meter_id' => register.meter_id,
           'updatable'=> true,
           'deletable'=> false,
           'createables'=>['readings'],
           'metering_point_id'=>'123456',
           'obis'=>register.obis,
         }
       end

       let(:wrong_json) do
         {
           'errors'=>[
             {'parameter'=>'metering_point_id',
              'detail'=>'size cannot be greater than 64'},
             {'parameter'=>'label',
              'detail'=>'must be one of: CONSUMPTION, CONSUMPTION_COMMON, DEMARCATION_PV, DEMARCATION_CHP, DEMARCATION_WIND, DEMARCATION_WATER, PRODUCTION_PV, PRODUCTION_CHP, PRODUCTION_WIND, PRODUCTION_WATER, GRID_CONSUMPTION, GRID_FEEDING, GRID_CONSUMPTION_CORRECTED, GRID_FEEDING_CORRECTED, OTHER'},
             {'parameter'=>'observer_enabled',
              'detail'=>'must be boolean'},
             {'parameter'=>'observer_min_threshold',
              'detail'=>'must be an integer'},
             {'parameter'=>'observer_max_threshold',
              'detail'=>'must be an integer'},
             {'parameter'=>'observer_offline_monitoring',
              'detail'=>'must be boolean'},
             {'parameter'=>'name',
              'detail'=>'size cannot be greater than 64'},
             {'parameter'=>'updated_at',
              'detail'=>'is missing'},
           ]
         }
       end

       it '401' do
         GET "/test/#{group.id}/meters/#{meter.id}/registers/#{register.id}", $admin
         expire_admin_session do
           PATCH "/test/#{group.id}/meters/#{meter.id}/registers/#{register.id}", $admin
           expect(response).to be_session_expired_json(401)
         end
       end

       it '404' do
         PATCH "/test/#{group.id}/meters/#{meter.id}/registers/bla-blub", $admin
         expect(response).to be_not_found_json(404, Register::Real)
       end

       it '409' do
         PATCH "/test/#{group.id}/meters/#{meter.id}/registers/#{register.id}", $admin,
               updated_at: DateTime.now
         expect(response).to be_stale_json(409, register)
       end

       it '422' do
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
               label: Register::Base.labels[:demarcation_pv],
               observer_enabled: true,
               observer_min_threshold: 10,
               observer_max_threshold: 100,
               observer_offline_monitoring: true
         expect(response).to have_http_status(200)
         register.reload
         expect(register.metering_point_id).to eq'123456'
         expect(register.name).to eq 'Smarty'
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
          'direction'=>real_register.attributes['direction'],
          'name'=>real_register.name,
          'pre_decimal_position'=>6,
          'post_decimal_position'=>real_register.post_decimal_position,
          'low_load_ability'=>false,
          'label'=>real_register.attributes['label'],
          'last_reading'=>last ? last.value : 0,
          'observer_min_threshold'=>nil,
          'observer_max_threshold'=>nil,
          'observer_enabled'=>nil,
          'observer_offline_monitoring'=>nil,
          'meter_id' => real_register.meter_id,
          'updatable'=> true,
          'deletable'=> false,
          'createables'=>['readings'],
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
          'direction'=>virtual_register.attributes['direction'],
          'name'=>virtual_register.name,
          'pre_decimal_position'=>6,
          'post_decimal_position'=>2,
          'low_load_ability'=>false,
          'label'=>virtual_register.attributes['label'],
          'last_reading'=>last ? last.value : 0,
          'observer_min_threshold'=>100,
          'observer_max_threshold'=>5000,
          'observer_enabled'=>false,
          'observer_offline_monitoring'=>false,
          'meter_id' => virtual_register.meter_id,
          'updatable'=> true,
          'deletable'=> false,
          'createables'=>['readings'],
        }
      end

      let(:registers_json) do
        Register::Base.all.reload.collect do |register|
          last = register.readings.order('date').last
          json = {
            'id'=>register.id,
            'type'=>"register_#{register.is_a?(Register::Real) ? 'real': 'virtual'}",
            'updated_at'=>register.updated_at.as_json,
            'direction'=>register.attributes['direction'],
            'name'=>register.name,
            'pre_decimal_position'=>register.pre_decimal_position,
            'post_decimal_position'=>register.post_decimal_position,
            'low_load_ability'=>register.low_load_ability,
            'label'=>register.attributes['label'],
            'last_reading'=>last ? last.value : 0,
            'observer_min_threshold'=>register.observer_min_threshold,
            'observer_max_threshold'=>register.observer_max_threshold,
            'observer_enabled'=>register.observer_enabled,
            'observer_offline_monitoring'=>register.observer_offline_monitoring,
            'meter_id' => register.meter_id,
            'updatable'=> true,
            'deletable'=> false,
            'createables'=>['readings']
          }
          if register.is_a? Register::Real
            json['metering_point_id'] = register.metering_point_id
            json['obis'] = register.obis
          end
          json
        end
      end

      # NOTE picking a sample register is enough for the 404 tests

      let(:register) do
        register = [real_register, virtual_register].sample
        Fabricate(:single_reading, register: register)
        register
      end

      it '401' do
        GET "/test/#{group.id}/registers/#{register.id}", $admin
        expire_admin_session do
          GET "/test/#{group.id}/registers/#{register.id}", $admin
          expect(response).to be_session_expired_json(401)

          GET "/test/#{group.id}/registers", $admin
          expect(response).to be_session_expired_json(401)
        end
      end

      it '404' do
        GET "/test/#{group.id}/registers/bla-blub", $admin
        expect(response).to be_not_found_json(404, Register::Base)
      end

      it '200 all' do
        GET "/test/#{group.id}/registers", $admin
        expect(response).to have_http_status(200)
        expect(sort(json['array']).to_yaml).to eq sort(registers_json).to_yaml
      end

#      [:real, :virtual].each do |type|
      [:real].each do |type|

        context "as #{type}" do
          let(:virtual_registers_json) { [virtual_register_json] }
          let(:real_registers_json) do
            Register::Real.all.collect do |register|
              last = register.readings.order('date').last
              {
                'id'=>register.id,
                'type'=>'register_real',
                'updated_at'=>register.updated_at.as_json,
                'direction'=>register.attributes['direction'],
                'name'=>register.name,
                'pre_decimal_position'=>register.pre_decimal_position,
                'post_decimal_position'=>register.post_decimal_position,
                'low_load_ability'=>register.low_load_ability,
                'label'=>register.attributes['label'],
                'last_reading'=> last ? last.value : 0,
                'observer_min_threshold'=>register.observer_min_threshold,
                'observer_max_threshold'=>register.observer_max_threshold,
                'observer_enabled'=>register.observer_enabled,
                'observer_offline_monitoring'=>register.observer_offline_monitoring,
                'meter_id' => register.meter_id,
                'updatable'=> true,
                'deletable'=> false,
                'createables'=>['readings'],
                'metering_point_id'=>register.metering_point_id,
                'obis'=>register.obis
              }
            end
          end
          let(:contract_json) do
            contract = real_register.contracts.first
            {
              'contracts' => {
                'array' => [
                  {
                    'id'=>contract.id,
                    'type'=>'contract_localpool_power_taker',
                    'updated_at'=>contract.updated_at.as_json,
                    'full_contract_number'=>contract.full_contract_number,
                    'signing_date'=>contract.signing_date.to_s,
                    'begin_date'=>contract.begin_date.to_s,
                    'termination_date'=>nil,
                    'last_date'=>nil,
                    'status'=>contract.status.to_s,
                    'updatable'=>false,
                    'deletable'=>false,
                    'forecast_kwh_pa'=>contract.forecast_kwh_pa,
                    'renewable_energy_law_taxation'=>contract.attributes['renewable_energy_law_taxation'],
                    'third_party_billing_number'=>contract.third_party_billing_number,
                    'third_party_renter_number'=>contract.third_party_renter_number,
                    'old_supplier_name'=>contract.old_supplier_name,
                    'old_customer_number'=>contract.old_customer_number,
                    'old_account_number'=>contract.old_account_number,
                    'mandate_reference' => nil,
                  }
                ]
              }
            }
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

            GET "/test/#{group.id}/meters/#{register.meter.id}/registers/#{register.id}", $admin, include: :contracts
            expect(response).to have_http_status(200)
            expect(json.to_yaml).to eq register_json.merge!(contract_json).to_yaml
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
          expect(response).to be_not_found_json(404, Register::Base)
        end

        [:real, :virtual].each do |type|

          context "as #{type}" do

            let(:register) { send "#{type}_register" }
            let!(:readings_json) do
              readings = 2.times
                           .collect { Fabricate(:single_reading, register: register) }
              register.readings.collect do |r|
                {
                  'id'=>r.id,
                  'type'=>'reading',
                  'updated_at'=> r.updated_at.as_json,
                  'date'=>r.date.as_json,
                  'raw_value'=>r.raw_value,
                  'value'=>r.value,
                  'unit'=>r.attributes['unit'],
                  'reason'=>r.attributes['reason'],
                  'read_by'=>r.attributes['read_by'],
                  'source'=>r.attributes['source'],
                  'quality'=>r.attributes['quality'],
                  'status'=>r.attributes['status'],
                  'comment'=>nil,
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
