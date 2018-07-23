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
      'createables' => ['managers', 'organizations', 'localpool_processing_contracts', 'registers', 'persons', 'tariffs', 'billing_cycles', 'devices'],
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
        }
      },
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
        'updated_at'=>organization.updated_at.as_json,
        'name'=>organization.name,
        'phone'=>organization.phone,
        'fax'=>organization.fax,
        'website'=>organization.website,
        'email'=>organization.email,
        'description'=>organization.description,
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
      expect(json.to_yaml).to eq localpool_json.to_yaml
    end

  end
end
