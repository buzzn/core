require_relative 'test_admin_localpool_roda'
describe Admin::LocalpoolRoda do

  def app
    TestAdminLocalpoolRoda # this defines the active application for this test
  end

  entity!(:address) { create(:address) }
  entity!(:person) do create(:person, :with_bank_account,
                             address: address) end
  entity!(:organization) do create(:organization, :with_bank_account,
                                   address: address,
                                   contact: person) end
  entity!(:localpool) { create(:localpool) }

  let(:localpool_json) do
    {
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
      'deletable'=>true,
      'incompleteness' => {
        'grid_feeding_register' => ['must be filled'],
        'grid_consumption_register' => ['must be filled'],
        'distribution_system_operator' => ['must be filled'],
        'transmission_system_operator' => ['must be filled'],
        'electricity_supplier' => ['must be filled'],
        'bank_account' => ['must be filled']
      },
      'bank_account' => nil,
      'power_sources' => [],
      'display_app_url' => nil,
    }
  end

  let(:address_json) do
    {
      'id'=>address.id,
      'type'=>'address',
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
      'address' => address_json,
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
        GET "/test/#{localpool.id}", $admin, include: "#{key}:[address, bank_accounts, contact:[address]]"
        expect(response).to have_http_status(200)
        expect(json.to_yaml).to eq localpool_json.to_yaml
      end
    end
  end

  shared_examples 'nested organization' do |key|

    before do
      localpool.update(key => organization)
      localpool_json[key] = {
        'id'=>organization.id,
        'type'=>'organization',
        'updated_at'=>organization.updated_at.as_json,
        'name'=>organization.name,
        'phone'=>organization.phone,
        'fax'=>organization.fax,
        'website'=>organization.website,
        'email'=>organization.email,
        'description'=>organization.description,
        'customer_number' => nil,
        'updatable'=>true,
        'deletable'=>false,
        'bank_accounts'=>{
          'array'=> organization.bank_accounts.collect do |bank_account|
            {
              'id'=>bank_account.id,
              'type'=>'bank_account',
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
        'address' => address_json,
        'contact' => person_json
      }
    end

    context 'GET' do

      it '200' do
        GET "/test/#{localpool.id}", $admin, include: "#{key}:[address, bank_accounts, contact:[address]]"
        expect(response).to have_http_status(200)
        expect(json).to eq localpool_json
      end
    end
  end

  it_behaves_like 'nested person', 'owner'
  it_behaves_like 'nested organization', 'owner'

  it_behaves_like 'nested person', 'gap_contract_customer'
  it_behaves_like 'nested organization', 'gap_contract_customer'

end
