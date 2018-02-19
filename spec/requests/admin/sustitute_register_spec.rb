require_relative 'test_admin_localpool_roda'
require_relative 'resource_shared'

describe Register::SubstituteResource do

  def app
    TestAdminLocalpoolRoda
  end

  entity(:group) { create(:localpool) }

  entity(:meter) { create(:meter, :virtual, group: group, registers: [build(:register, :substitute)]) }

  entity(:register) { meter.registers.first }

  context 'localpools/<id>/meters/<id>/registers' do

    let(:expected_json) do
      last = register.readings.order('date').last
      {
        'id'=>register.id,
        'type'=>'register_substitute',
        'updated_at'=>register.updated_at.as_json,
        'label'=>register.attributes['label'],
        'last_reading'=>last ? last.value : 0,
        'observer_min_threshold'=>nil,
        'observer_max_threshold'=>nil,
        'observer_enabled'=>nil,
        'observer_offline_monitoring'=>nil,
        'meter_id' => register.meter_id,
        'updatable'=> true,
        'deletable'=> false,
        'createables'=>['readings'],
        'direction'=>register.attributes['direction'],
      }
    end

    let(:path) { "/test/#{group.id}/meters/#{meter.id}/registers/#{register.id}" }

    it_behaves_like 'GET resource', :register
    it_behaves_like 'GET resources'
  end
end
