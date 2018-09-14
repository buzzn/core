require_relative 'test_admin_localpool_roda'
require_relative 'shared_crud'

describe Register::SubstituteResource, :request_helper do

  def app
    TestAdminLocalpoolRoda
  end

  entity(:group) { create(:group, :localpool) }

  entity(:meter) { create(:meter, :virtual, group: group, registers: [build(:register, :substitute)]) }

  entity(:register) { meter.registers.first }

  context 'localpools/<id>/meters/<id>/registers' do

    context 'GET' do

      let(:expected_json) do
        last = register.readings.order('date').last
        {
          'id'=>register.id,
          'type'=>'register_substitute',
          'created_at'=>register.created_at.as_json,
          'updated_at'=>register.updated_at.as_json,
          'label'=>register.meta.attributes['label'],
          'direction'=>register.consumption? ? 'in' : 'out',
          'last_reading'=>last ? last.value : 0,
          'observer_min_threshold'=>nil,
          'observer_max_threshold'=>nil,
          'observer_enabled'=>false,
          'observer_offline_monitoring'=>false,
          'meter_id' => register.meter_id,
          'updatable'=> true,
          'deletable'=> true,
          'createables'=>['readings', 'contracts'],
        }
      end

      let(:path) { "/localpools/#{group.id}/meters/#{meter.id}/registers/#{register.id}" }

      it_behaves_like 'single', :register, path: :path, expected: :expected_json
      it_behaves_like 'all', path: :path, expected: :expected_json
    end
  end
end
