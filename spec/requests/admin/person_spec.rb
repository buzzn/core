require_relative 'test_admin_localpool_roda'
describe Admin::LocalpoolRoda, :request_helper do

  def app
    TestAdminLocalpoolRoda # this defines the active application for this test
  end

  context 'persons' do

    entity!(:group) { create(:group, :localpool) }

    entity!(:person) do
      $other.person.reload.add_role(Role::GROUP_MEMBER, group)
      person = $user.person.reload
      person.add_role(Role::GROUP_OWNER, group)
      create(:bank_account, owner: person)
      person.update!(address: create(:address))
      person
    end

    let(:empty_json) do
      []
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
        'email_backend_host' => nil,
        'email_backend_port' => nil,
        'email_backend_user' => nil,
        'email_backend_encryption' => nil,
        'email_backend_active' => false,
        'email_backend_signature' => nil,
        'updatable'=>true,
        'deletable'=>false,
        'bank_accounts'=>{
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
        },
        'address'=>{
          'id'=>person.address.id,
          'type'=>'address',
          'created_at'=>person.address.created_at.as_json,
          'updated_at'=>person.address.updated_at.as_json,
          'street'=>person.address.street,
          'city'=>person.address.city,
          'zip'=>person.address.zip,
          'country'=>person.address.attributes['country'],
          'updatable'=>true,
          'deletable'=>true
        }
      }
    end

    let(:persons_json) do
      group.persons.collect do |person|
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
          'email_backend_host' => nil,
          'email_backend_port' => nil,
          'email_backend_user' => nil,
          'email_backend_encryption' => nil,
          'email_backend_active' => false,
          'email_backend_signature' => nil,
          'updatable'=>true,
          'deletable'=>false,
          'bank_accounts'=> {
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
        }
      end
    end

    let(:admin_persons_json) do
      group.persons.collect do |person|
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
          'email_backend_host' => nil,
          'email_backend_port' => nil,
          'email_backend_user' => nil,
          'email_backend_encryption' => nil,
          'email_backend_active' => false,
          'email_backend_signature' => nil,
          'updatable'=>true,
          'deletable'=>false,
          'bank_accounts'=> {
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
        }
      end
    end

    let(:filtered_admin_persons_json) do
      [
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
          'email_backend_host' => nil,
          'email_backend_port' => nil,
          'email_backend_user' => nil,
          'email_backend_encryption' => nil,
          'email_backend_active' => false,
          'email_backend_signature' => nil,
          'updatable'=>true,
          'deletable'=>false,
          'bank_accounts'=>{
            'array'=>person.bank_accounts.collect do |bank_account|
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

      it '401' do
        GET "/localpools/#{group.id}/persons/#{person.id}", $admin
        expire_admin_session do
          GET "/localpools/#{group.id}/persons", $admin
          expect(response).to be_session_expired_json(401)

          GET "/localpools/#{group.id}/persons/#{person.id}", $admin
          expect(response).to be_session_expired_json(401)
        end
      end

      it '403' do
        GET "/localpools/#{group.id}/persons/#{person.id}", $other
        expect(response).to have_http_status(403)
      end

      it '404' do
        GET "/localpools/#{group.id}/persons/bla-blub", $admin
        expect(response).to have_http_status(404)
      end

      it '200' do
        GET "/localpools/#{group.id}/persons/#{person.id}", $user, include: 'bank_accounts, address'
        expect(response).to have_http_status(200)
        expect(json.to_yaml).to eq person_json.to_yaml

        GET "/localpools/#{group.id}/persons/#{person.id}", $admin, include: :bank_accounts
        expect(response).to have_http_status(200)
        expect(json.to_yaml).to eq admin_person_json.to_yaml
      end

      it '200 all' do
        GET "/localpools/#{group.id}/persons", $user, include: :bank_accounts
        expect(response).to have_http_status(200)
        expect(json['array']).to eq persons_json

        GET "/localpools/#{group.id}/persons", $admin, include: :bank_accounts
        expect(response).to have_http_status(200)
        expect(sort(json['array']).to_yaml).to eq sort(admin_persons_json).to_yaml
      end
    end
  end
end
