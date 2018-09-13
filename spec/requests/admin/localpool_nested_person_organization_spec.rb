require_relative 'test_admin_localpool_roda'
require_relative 'shared_crud'

describe Admin::LocalpoolRoda, :request_helper, :order => :defined do

  def app
    TestAdminLocalpoolRoda # this defines the active application for this test
  end

  entity!(:address) { create(:address) }
  entity!(:person) do create(:person, :with_bank_account,
                             address: address) end
  entity!(:organization) do create(:organization, :with_bank_account,
                                   address: address,
                                   contact: person,
                                   legal_representation: person) end
  entity!(:localpool) { create(:group, :localpool) }

  let(:localpool_json) do
    {
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
      'createables' => ['managers', 'organizations', 'localpool_processing_contracts', 'metering_point_operator_contracts', 'localpool_power_taker_contracts', 'registers', 'persons', 'tariffs', 'billing_cycles', 'devices'],
      'incompleteness' => {
        'grid_feeding_register' => ['must be filled'],
        'grid_consumption_register' => ['must be filled'],
        'distribution_system_operator' => ['must be filled'],
        'transmission_system_operator' => ['must be filled'],
        'electricity_supplier' => ['must be filled'],
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
      'next_billing_cycle_begin_date' => '2016-02-01',
    }
  end

  let(:address_json) do
    {
      'id'=>address.id,
      'type'=>'address',
      'created_at'=>address.created_at.as_json,
      'updated_at'=>address.updated_at.as_json,
      'street'=>address.street,
      'city'=>address.city,
      'zip'=>address.zip,
      'country'=>address.attributes['country'],
      'updatable'=>true,
      'deletable'=>true
    }
  end

  let(:person_json) do
    {
      'id'=>person.id,
      'type'=>'person',
      'created_at'=>person.created_at.as_json,
      'updated_at'=>person.updated_at.as_json,
      'prefix'=>person.attributes['prefix'],
      'title'=>person.title,
      'first_name'=>person.first_name,
      'last_name'=>person.last_name,
      'phone'=>person.phone,
      'fax'=>person.fax,
      'email'=>person.email,
      'preferred_language'=>person.attributes['preferred_language'],
      'image'=>person.image.medium.url,
      'customer_number' => nil,
      'updatable'=>true,
      'deletable'=>false,
      'address' => address_json.dup,
    }
  end

  shared_examples 'nested person' do |key|

    before do
      localpool.update(key => person)
      json = person_json.dup
      json['bank_accounts'] = {
        'array'=> person.bank_accounts.collect do |bank_account|
          {
            'id'=>bank_account.id,
            'type'=>'bank_account',
            'created_at'=>bank_account.created_at.as_json,
            'updated_at'=>bank_account.updated_at.as_json,
            'holder'=>bank_account.holder,
            'bank_name'=>bank_account.bank_name,
            'bic'=>bank_account.bic,
            'iban'=>bank_account.iban,
            'direct_debit'=>bank_account.direct_debit,
            'updatable'=> true,
            'deletable'=> true
          }
        end
      }
      localpool_json[key] = json
    end

    context 'GET' do

      it '200' do
        GET "/localpools/#{localpool.id}", $admin, include: "#{key}:[address, bank_accounts, contact:[address]]"
        expect(response).to have_http_status(200)
        result = json
        result['incompleteness'].delete('owner') # is flaky
        expect(result.to_yaml).to eq localpool_json.to_yaml
      end
    end
  end

  shared_examples 'nested organization' do |key|

    before do
      localpool.update(key => organization)
      localpool_json[key] = {
        'id'=>organization.id,
        'type'=>'organization',
        'created_at'=>organization.created_at.as_json,
        'updated_at'=>organization.updated_at.as_json,
        'name'=>organization.name,
        'phone'=>organization.phone,
        'fax'=>organization.fax,
        'website'=>organization.website,
        'email'=>organization.email,
        'description'=>organization.description,
        'additional_legal_representation'=>organization.additional_legal_representation,
        'updatable'=>true,
        'deletable'=>false,
        'customer_number' => nil,
        'address' => address_json,
        'bank_accounts'=>{
          'array'=> organization.bank_accounts.collect do |bank_account|
            {
              'id'=>bank_account.id,
              'type'=>'bank_account',
              'created_at'=>bank_account.created_at.as_json,
              'updated_at'=>bank_account.updated_at.as_json,
              'holder'=>bank_account.holder,
              'bank_name'=>bank_account.bank_name,
              'bic'=>bank_account.bic,
              'iban'=>bank_account.iban,
              'direct_debit'=>bank_account.direct_debit,
              'updatable'=> true,
              'deletable'=> true
            }
          end
        },
        'contact' => person_json
      }
    end

    context 'GET' do

      it '200' do
        GET "/localpools/#{localpool.id}", $admin, include: "#{key}:[address, bank_accounts, contact:[address]]"
        expect(response).to have_http_status(200)
        result = json
        result['incompleteness'].delete('owner') # is flaky
        expect(result.to_yaml).to eq localpool_json.to_yaml
      end
    end
  end

  context 'person owner' do
    it_behaves_like 'nested person', 'owner'
    let(:path) { "/localpools/#{localpool.id}/person-owner" }
    it_behaves_like 'create', Person,
                    path: :path,
                    wrong: {
                      prefix: 'M_W',
                      first_name: 'Ford' * 100,
                      last_name: 'Perfect' * 100,
                      preferred_language: 'german'
                    },
                    params: {
                      prefix: 'M',
                      first_name: 'Ford',
                      last_name: 'Perfect',
                      preferred_language: 'de'
                    },
                    errors: {
                      'prefix'=>['must be one of: F, M'],
                      'first_name'=>['size cannot be greater than 64'],
                      'last_name'=>['size cannot be greater than 64'],
                      'preferred_language'=>['must be one of: de, en']
                    },
                    expected: {
                      'type' => 'person',
                      'prefix' => 'M',
                      'title' => nil,
                      'first_name' => 'Ford',
                      'last_name' => 'Perfect',
                      'phone' => nil,
                      'fax' => nil,
                      'email' => nil,
                      'preferred_language' => 'de',
                      'image' => nil,
                      'customer_number' => nil,
                      'updatable' => true,
                      'deletable' => false
                    }
  end

  context 'organization owner' do
    it_behaves_like 'nested organization', 'owner'
    let(:path) { "/localpools/#{localpool.id}/organization-owner" }
    it_behaves_like 'create', Organization::General,
                    path: :path,
                    wrong: {
                      name: 'Perfect Propaganda' * 100,
                    },
                    params: {
                      name: 'Perfect Propaganda'
                    },
                    errors: {
                      'name'=>['size cannot be greater than 64'],
                    },
                    expected: {
                      'type' => 'organization',
                      'name' => 'Perfect Propaganda',
                      'phone' => nil,
                      'fax' => nil,
                      'website' => nil,
                      'email' => nil,
                      'description' => nil,
                      'additional_legal_representation' => nil,
                      'updatable' => true,
                      'deletable' => false,
                      'customer_number' => nil,
                    }

    let(:new_organization_owner_json) do
      {
        name: 'Gute Energie'
      }
    end

    # regression test
    it 'does does not fail with repeated POSTs' do
      4.times do
        POST path, $admin, new_organization_owner_json
        expect(response).to have_http_status(201)
      end
    end
  end

  context 'gap_contract_customer' do
    it_behaves_like 'nested person', 'gap_contract_customer'
    it_behaves_like 'nested organization', 'gap_contract_customer'
  end

  context 'organization update' do

    let(:a_brand_new_address) { build(:address) }
    let(:a_brand_new_address_json) do
      json = a_brand_new_address.as_json
      json.delete('created_at')
      json.delete('updated_at')
      json.delete_if { |k, v| v.nil? }
      json[:country] = 'DE'
      json
    end

    let(:legacy_person) { create(:person, :with_address) }
    let(:a_brand_new_person) { build(:person) }
    let(:a_brand_new_person_json) do
      json = a_brand_new_person.as_json
      json.delete('id')
      json.delete('image')
      json.delete('updated_at')
      json.delete('created_at')
      json.delete_if { |k, v| k.end_with?('_id') }
      json.delete_if { |k, v| v.nil? }
      json['preferred_language'] = 'de'
      json['address'] = a_brand_new_address_json
      json['prefix'] = 'M'
      json
    end

    let(:a_brand_new_legal_person) { build(:person) }
    let(:a_brand_new_legal_person_json) do
      json = a_brand_new_legal_person.as_json
      json.delete('id')
      json.delete('image')
      json.delete('updated_at')
      json.delete('created_at')
      json.delete('address')
      json.delete_if { |k, v| k.end_with?('_id') }
      json.delete_if { |k, v| v.nil? }
      json['preferred_language'] = 'de'
      json['prefix'] = 'M'
      json
    end

    let(:a_brand_new_address_without_a_name_json) do
      json = a_brand_new_person_json.dup
      json.delete('first_name')
      json.delete('last_name')
      json
    end

    let(:owner_path) do
      localpool.reload
      "/localpools/#{localpool.id}?include=owner:[bank_accounts,address,legal_representation,contact:[bank_accounts,address]]"
    end

    let(:patch_path) do
      localpool.reload
      "/localpools/#{localpool.id}/organization-owner"
    end

    it 'fails with incomplete data' do
      # assign an contact first
      localpool.reload
      localpool.owner.contact_id = legacy_person.id
      localpool.owner.save
      # fetch organization
      GET owner_path, $admin
      expect(response).to have_http_status(200)
      owner_json = json['owner']
      owner_json.delete('address')
      owner_json.delete('legal_representation')
      owner_json['contact'] = a_brand_new_address_without_a_name_json
      PATCH patch_path, $admin, owner_json
      expect(response).to have_http_status(422)
    end

    it 'assigns a new person to contact and updates the organization' do
      # fetch organization
      GET owner_path, $admin
      expect(response).to have_http_status(200)
      owner_json = json['owner']
      owner_json.delete('email')
      owner_json.delete('address')
      owner_json.delete('legal_representation')
      owner_json['contact'] = a_brand_new_person_json
      PATCH patch_path, $admin, owner_json
      expect(response).to have_http_status(200)
      localpool.reload
      expect(localpool.owner.contact.address.street).to eq a_brand_new_person_json['address']['street']
    end

    it 'assigns a new person as legal representation and updates the organization' do
      # fetch organization
      GET owner_path, $admin
      expect(response).to have_http_status(200)
      owner_json = json['owner']
      owner_json.delete('address')
      owner_json.delete('contact')
      owner_json['legal_representation'] = a_brand_new_legal_person_json
      PATCH patch_path, $admin, owner_json
      expect(response).to have_http_status(200)
      localpool.owner.reload
      expect(localpool.owner.legal_representation.last_name).to eq a_brand_new_legal_person_json['last_name']
      expect(localpool.owner.legal_representation.first_name).to eq a_brand_new_legal_person_json['first_name']
    end

    after :all do
      localpool.owner.contact = nil
      localpool.owner.save
    end

  end

  context 'organization owner assign' do
    entity!(:another_organization) do
      create(:organization, :with_bank_account,
             address: address, contact: person,
             legal_representation: person)
    end

    let(:base_path) { "/localpools/#{localpool.id}/organization-owner" }

    it 'assigs a new owner' do
      localpool.reload
      expect(localpool.owner_organization_id).not_to be_nil
      old_org_owner_id = localpool.owner_organization_id
      request_path = "#{base_path}/#{another_organization.id}"
      POST request_path, $admin
      expect(response).to have_http_status(201)
      localpool.reload
      expect(localpool.owner.id).not_to eq old_org_owner_id
      expect(localpool.owner.id).to eq another_organization.id
    end

  end

end
