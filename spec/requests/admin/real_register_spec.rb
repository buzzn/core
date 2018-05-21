require_relative 'test_admin_localpool_roda'
require_relative 'resource_shared'

describe Register::RealResource do

  def app
    TestAdminLocalpoolRoda
  end

  entity(:group) { create(:localpool) }

  entity(:meter) { create(:meter, :real, group: group) }

  entity(:register) { meter.registers.first }

  before(:all) { register.update(metering_point_id: '123456') }

  context 'localpools/<id>/meters/<id>/registers' do

    context 'GET' do

      let(:path) { "/localpools/#{group.id}/meters/#{meter.id}/registers/#{register.id}" }

      let(:expected_json) do
        last = register.readings.order('date').last
        {
          'id'=>register.id,
          'type'=>'register_real',
          'updated_at'=>register.updated_at.as_json,
          'label'=>register.attributes['label'],
          'direction'=>register.attributes['direction'],
          'last_reading'=>last ? last.value : 0,
          'observer_min_threshold'=>nil,
          'observer_max_threshold'=>nil,
          'observer_enabled'=>nil,
          'observer_offline_monitoring'=>nil,
          'meter_id' => register.meter_id,
          'updatable'=> true,
          'deletable'=> true,
          'createables'=>['readings', 'contracts'],
          'pre_decimal_position'=>6,
          'post_decimal_position'=>1,
          'low_load_ability'=>false,
          'metering_point_id'=>'123456',
          'obis'=>register.obis,
        }
      end

      it_behaves_like 'single', :register
      it_behaves_like 'all'
    end
  end
end
