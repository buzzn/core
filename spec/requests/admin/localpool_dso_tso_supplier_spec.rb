require_relative 'test_admin_localpool_roda'
describe Admin::LocalpoolRoda, :request_helper do

  def app
    TestAdminLocalpoolRoda # this defines the active application for this test
  end

  entity!(:localpool) do create(:group, :localpool,
                                distribution_system_operator: Organization::Market.distribution_system_operators.first,
                                transmission_system_operator: Organization::Market.transmission_system_operators.first,
                                electricity_supplier: Organization::Market.electricity_suppliers.first) end

  let(:localpool_json) do
    json = {
      'id'=>localpool.id,
      'type'=>'group_localpool',
      'created_at'=>localpool.created_at.as_json,
      'updated_at'=>localpool.updated_at.as_json,
      'name'=>localpool.name,
      'slug'=>localpool.slug,
      'description'=>localpool.description,
      'start_date' => localpool.start_date.as_json,
      'show_object' => nil,
      'show_production' => nil,
      'show_energy' => nil,
      'show_contact' => nil,
      'show_display_app' => nil,
      'updatable'=>true,
      'deletable'=>false,
      'createables' => [
        'meters',
        'meters_real',
        'managers',
        'organizations',
        'localpool_processing_contracts',
        'metering_point_operator_contracts',
        'localpool_power_taker_contracts',
        'localpool_gap_contracts',
        'registers',
        'persons',
        'tariffs',
        'billing_cycles',
        'devices'
      ],
      'incompleteness' => {
        'grid_feeding_register' => ['must be filled'],
        'grid_consumption_register' => ['must be filled'],
        'bank_account' => ['must be filled'],
        'address' => ['must be filled']
      },
      'bank_account' => nil,
      'power_sources' => [],
      'display_app_url' => nil,
      'allowed_actions' => {
        'create_metering_point_operator_contract'=> {
          'address' => ['must be filled']
        },
        'create_localpool_processing_contract' => true,
        'create_localpool_power_taker_contract'=> {
          'localpool_processing_contract' => ['must be filled']
        },
        'create_billing_cycle' => true
      },
      'legacy_power_giver_contract_buzznid' => nil,
      'legacy_power_taker_contract_buzznid' => nil,
      'fake_stats' => nil,
      'next_billing_cycle_begin_date' => '2016-02-01',
      'distribution_system_operator' => nil,
      'transmission_system_operator' => nil,
      'electricity_supplier' => nil
    }
    %w(distribution_system_operator transmission_system_operator electricity_supplier).each do |key|
      organization = localpool.send key
      json[key] = {
        'id'=>organization.id,
        'type'=>'organization_market',
        'created_at'=>organization.created_at.as_json,
        'updated_at'=>organization.updated_at.as_json,
        'name'=>organization.name,
        'phone'=>organization.phone,
        'fax'=>organization.fax,
        'website'=>organization.website,
        'email'=>organization.email,
        'description'=>organization.description,
        'additional_legal_representation'=>organization.additional_legal_representation,
        'updatable'=>false,
        'deletable'=>false,
      }
    end
    json
  end

  context 'GET' do

    it '200' do
      GET "/localpools/#{localpool.id}", $admin, include: 'distribution_system_operator, transmission_system_operator, electricity_supplier'
      expect(response).to have_http_status(200)
      json_without = json.dup
      json_without.delete('allowed_actions')
      localpool_json.delete('allowed_actions')
      expect(json_without.to_yaml).to eq localpool_json.to_yaml
    end

  end
end
