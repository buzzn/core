require_relative 'test_admin_localpool_roda'
describe Admin::LocalpoolRoda do

  def app
    TestAdminLocalpoolRoda # this defines the active application for this test
  end

  context 'market location' do

    entity(:group) do
      group = create(:localpool)
      $user.person.reload.add_role(Role::GROUP_MEMBER, group)
      group
    end

    entity(:market_location) do
      create(:market_location,
             register: create(:register, :real),
             group: group)
    end

    context 'GET' do

      let(:expected_json) do
        register = market_location.register
        {
          'id' => market_location.id,
          'type' => 'market_location',
          'updated_at' => market_location.updated_at.as_json,
          'name' => market_location.name,
          'updatable' => true,
          'deletable' => false,
          'register' => {
            'id' => register.id,
            'type' => 'register_real',
            'updated_at'=> register.updated_at.as_json,
            'direction' => register.attributes['direction'],
            'pre_decimal_position' => 6,
            'post_decimal_position' => register.post_decimal_position,
            'low_load_ability' => false,
            'label' => register.attributes['label'],
            'last_reading' => 0,
            'observer_min_threshold' => nil,
            'observer_max_threshold' => nil,
            'observer_enabled'=> nil,
            'observer_offline_monitoring' => nil,
            'meter_id' => register.meter.id,
            'kind' => 'consumption',
            'updatable' => false,
            'deletable' => false,
            'createables' => ['readings'],
            'metering_point_id' => register.metering_point_id,
            'obis' => register.obis,
            'meter' => nil
          }
        }
      end

      it '401' do
        GET "/test/#{group.id}/market-locations/#{market_location.id}", $admin
        expire_admin_session do
          GET "/test/#{group.id}/market_locations/#{market_location.id}", $admin
          expect(response).to be_session_expired_json(401)
        end
      end

      it '403' do
        GET "/test/#{group.id}/market-locations/#{market_location.id}", $user
        expect(response).to be_denied_json(403, market_location)
      end

      it '404' do
        GET "/test/#{group.id}/market-locations/bla-blub", $admin
        expect(response).to be_not_found_json(404, MarketLocation)
      end

      it '200' do
        GET "/test/#{group.id}/market-locations/#{market_location.id}", $admin, include: 'register:meter'
        expect(response).to have_http_status(200)
        expect(json.to_yaml).to eq expected_json.to_yaml
      end
    end

  end
end
