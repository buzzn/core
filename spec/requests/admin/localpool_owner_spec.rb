require_relative 'test_admin_localpool_roda'
describe Admin::LocalpoolRoda do

  def app
    TestAdminLocalpoolRoda # this defines the active application for this test
  end

  entity!(:address) { create(:address) }
  entity!(:person) { create(:person, :with_bank_account,
                           address: address) }
  entity!(:organization) { create(:organization, :with_bank_account,
                                  address: address,
                                  contact: person) }
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
    }
  end

  let(:address_json) do
    {
      "id"=>address.id,
      "type"=>"address",
      'updated_at'=>address.updated_at.as_json,
      "street"=>address.street,
      "city"=>address.city,
      "state"=>address.attributes['state'],
      "zip"=>address.zip,
      "country"=>address.attributes['country'],
      "updatable"=>true,
      "deletable"=>true
    }
  end

  let(:person_json) do
    {
      "id"=>person.id,
      "type"=>"person",
      'updated_at'=>person.updated_at.as_json,
      "prefix"=>person.attributes['prefix'],
      "title"=>person.title,
      "first_name"=>person.first_name,
      "last_name"=>person.last_name,
      "phone"=>person.phone,
      "fax"=>person.fax,
      "email"=>person.email,
      "preferred_language"=>person.attributes['preferred_language'],
      "image"=>person.image.md.url,
      'customer_number' => nil,
      "updatable"=>true,
      "deletable"=>false,
      'address' => address_json,
    }
  end

  context :person do

    before do
      localpool.update(owner: person)
#      localpool_json['incompleteness']['owner'] = ['BUG: missing GROUP_ADMIN role']
      owner_json = person_json.dup
      owner_json['bank_accounts'] = {
        'array'=> person.bank_accounts.collect do |bank_account|
          {
            "id"=>bank_account.id,
            "type"=>"bank_account",
            'updated_at'=>bank_account.updated_at.as_json,
            "holder"=>bank_account.holder,
            "bank_name"=>bank_account.bank_name,
            "bic"=>bank_account.bic,
            "iban"=>bank_account.iban,
            "direct_debit"=>bank_account.direct_debit,
            'updatable'=> true,
            'deletable'=> true
          }
        end
      }
      localpool_json['owner'] = owner_json
    end

    context 'GET' do

      it '200' do
        GET "/test/#{localpool.id}", $admin, include: 'owner:[address, bank_accounts, contact:[address]]'
        expect(response).to have_http_status(200)
        expect(json.to_yaml).to eq localpool_json.to_yaml
      end
    end
  end

  context :organization do

    before do
      localpool.update(owner: organization)
#      localpool_json['incompleteness']['owner'] = ['BUG: missing GROUP_ADMIN role']
      localpool_json['owner'] = {
        "id"=>organization.id,
        "type"=>"organization",
        'updated_at'=>organization.updated_at.as_json,
        "name"=>organization.name,
        "phone"=>organization.phone,
        "fax"=>organization.fax,
        "website"=>organization.website,
        "email"=>organization.email,
        "description"=>organization.description,
        'customer_number' => nil,
        "updatable"=>true,
        "deletable"=>false,
        "bank_accounts"=>{
          'array'=> organization.bank_accounts.collect do |bank_account|
            {
              "id"=>bank_account.id,
              "type"=>"bank_account",
              'updated_at'=>bank_account.updated_at.as_json,
              "holder"=>bank_account.holder,
              "bank_name"=>bank_account.bank_name,
              "bic"=>bank_account.bic,
              "iban"=>bank_account.iban,
              "direct_debit"=>bank_account.direct_debit,
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
        GET "/test/#{localpool.id}", $admin, include: 'owner:[address, bank_accounts, contact:[address]]'
        expect(response).to have_http_status(200)
        expect(json).to eq localpool_json
      end
    end
  end
end
