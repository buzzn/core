require_relative 'test_admin_localpool_roda'
require_relative 'shared_crud'

describe Register::RealResource, :request_helper do

  def app
    TestAdminLocalpoolRoda
  end

  entity(:group) { create(:group, :localpool) }

  entity(:meter) { create(:meter, :real, group: group) }

  entity(:register) { meter.registers.first }

  before(:all) { register.meter.update(metering_location: Meter::MeteringLocation.new(metering_location_id: '123456')) }

  context 'localpools/<id>/meters/<id>/registers' do

    context 'GET' do

      let(:path) { "/localpools/#{group.id}/meters/#{meter.id}/registers/#{register.id}" }

      let(:expected_json) do
        last = register.readings.order('date').last
        {
          'id'=>register.id,
          'type'=>'register_real',
          'created_at'=>register.created_at.as_json,
          'updated_at'=>register.updated_at.as_json,
          'direction'=>register.consumption? ? 'in' : 'out',
          'last_reading'=>last ? last.value : 0,
          'meter_id' => register.meter_id,
          'updatable'=> true,
          'deletable'=> true,
          'createables'=>['readings', 'contracts'],
          'pre_decimal_position'=>6,
          'post_decimal_position'=>1,
          'low_load_ability'=>false,
          'obis'=>register.obis,
        }
      end

      it_behaves_like 'single', :register, path: :path, expected: :expected_json
      it_behaves_like 'all', path: :path, expected: :expected_json
    end
  end
end
