describe Admin::LocalpoolRoda do

  def app
    Admin::LocalpoolRoda # this defines the active application for this test
  end

  context 'persons' do

    entity!(:admin) { Fabricate(:admin_token) }

    entity!(:user_token) { Fabricate(:user_token) }

    entity!(:other) { Fabricate(:user_token) }

    entity!(:group) { Fabricate(:localpool) }

    entity!(:person) do
      Account::Base.find(other.resource_owner_id)
        .person.add_role(Role::GROUP_MEMBER, group)
      user = Account::Base.find(user_token.resource_owner_id).person
      user.add_role(Role::GROUP_OWNER, group)
      Fabricate(:bank_account, contracting_party: user)
      user.update(address: Fabricate(:address))
      user
    end

    let(:denied_json) do
      {
        "errors" => [
          {
            "detail"=>"retrieve Person: #{person.id} permission denied for User: #{other.resource_owner_id}"
          }
        ]
      }
    end

    let(:not_found_json) do
      {
        "errors" => [
          {
            "detail"=>"Person: bla-blub not found by User: #{admin.resource_owner_id}"
          }
        ]
      }
    end

    let(:empty_json) do
      []
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
        "updatable"=>true,
        "deletable"=>false,
        "bank_accounts"=>{
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
        },
        'address'=>{
          "id"=>person.address.id,
          "type"=>"address",
          'updated_at'=>person.address.updated_at.as_json,
          "street"=>person.address.street,
          "city"=>person.address.city,
          "state"=>person.address.attributes['state'],
          "zip"=>person.address.zip,
          "country"=>person.address.attributes['country'],
          "updatable"=>true,
          "deletable"=>true
        }
      }
    end

    let(:persons_json) do
      group.persons.collect do |person|
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
          "updatable"=>true,
          "deletable"=>false,
          "bank_accounts"=> {
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
        }
      end
    end

    let(:admin_persons_json) do
      group.persons.collect do |person|
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
          "updatable"=>true,
          "deletable"=>false,
          "bank_accounts"=> {
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
        }
      end
    end

    let(:filtered_admin_persons_json) do
      [
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
          "updatable"=>true,
          "deletable"=>false,
          "bank_accounts"=>{
            'array'=>person.bank_accounts.collect do |bank_account|
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
        }
      ]
    end

    context 'GET' do

      let(:admin_person_json) do
        json = person_json.dup
        json['deletable']=false
        json.delete('address')
        json
      end

      it '403' do
        GET "/#{group.id}/persons/#{person.id}", other
        expect(response).to have_http_status(403)
        expect(json).to eq denied_json
      end

      it '404' do
        GET "/#{group.id}/persons/bla-blub", admin
        expect(response).to have_http_status(404)
        expect(json).to eq not_found_json
      end

      it '200' do
        GET "/#{group.id}/persons/#{person.id}", user_token, include: 'bank_accounts, address'
        expect(response).to have_http_status(200)
        expect(json.to_yaml).to eq person_json.to_yaml

        GET "/#{group.id}/persons/#{person.id}", admin, include: :bank_accounts
        expect(response).to have_http_status(200)
        expect(json.to_yaml).to eq admin_person_json.to_yaml
      end

      it '200 all' do
        GET "/#{group.id}/persons", user_token, include: :bank_accounts
        expect(response).to have_http_status(200)
        expect(json['array']).to eq persons_json

        GET "/#{group.id}/persons", admin, include: :bank_accounts
        expect(response).to have_http_status(200)
        expect(sort(json['array']).to_yaml).to eq sort(admin_persons_json).to_yaml
      end

      it '200 all filtered' do
        admin_user = Account::Base.find(admin.resource_owner_id).person

        GET "/#{group.id}/persons", user_token, include: :bank_accounts, filter: admin_user.first_name
        expect(response).to have_http_status(200)
        expect(json['array'].to_yaml).to eq empty_json.to_yaml

        GET "/#{group.id}/persons", admin, include: :bank_accounts, filter: person.first_name
        expect(response).to have_http_status(200)
        expect(json['array'].to_yaml).to eq filtered_admin_persons_json.to_yaml
      end
    end
  end
end
