require_relative 'test_admin_localpool_roda'
describe Admin::LocalpoolRoda, :request_helper do

  def app
    TestAdminLocalpoolRoda # this defines the active application for this test
  end

  context 'organizations' do

    entity!(:localpool) { create(:group, :localpool, owner: organization) }
    entity!(:address) { create(:address) }
    entity!(:person) { create(:person) }
    entity!(:organization) do
      organization = create(:organization,
                            contact: person,
                            legal_representation: person)
      organization.update(address: address)
      organization
    end
    entity!(:contract) do
      create(:contract, :metering_point_operator, localpool: localpool)
    end

    context 'GET' do

      let(:organization_json) do
        {
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
          'additional_legal_representation'=> nil,
          'updatable'=>true,
          'deletable'=>false,
          'customer_number' => nil,
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
            end,
          },
          'contact'=>{
            'id'=>organization.contact.id,
            'type'=>'person',
            'created_at'=>organization.contact.created_at.as_json,
            'updated_at'=>organization.contact.updated_at.as_json,
            'prefix'=>organization.contact.attributes['prefix'],
            'title'=>organization.contact.title,
            'first_name'=>organization.contact.first_name,
            'last_name'=>organization.contact.last_name,
            'phone'=>organization.contact.phone,
            'fax'=>organization.contact.fax,
            'email'=>organization.contact.email,
            'preferred_language'=>organization.contact.attributes['preferred_language'],
            'image'=>organization.contact.image.medium.url,
            'customer_number' => nil,
            'email_backend_host' => nil,
            'email_backend_port' => nil,
            'email_backend_user' => nil,
            'email_backend_encryption' => nil,
            'email_backend_active' => false,
            'email_backend_signature' => nil,
            'updatable'=>true,
            'deletable'=>false,
          },
          'legal_representation'=>{
            'id'=>organization.legal_representation.id,
            'type'=>'person',
            'created_at'=>organization.legal_representation.created_at.as_json,
            'updated_at'=>organization.legal_representation.updated_at.as_json,
            'prefix'=>organization.legal_representation.attributes['prefix'],
            'title'=>organization.legal_representation.title,
            'first_name'=>organization.legal_representation.first_name,
            'last_name'=>organization.legal_representation.last_name,
            'phone'=>organization.legal_representation.phone,
            'fax'=>organization.legal_representation.fax,
            'email'=>organization.legal_representation.email,
            'preferred_language'=>organization.legal_representation.attributes['preferred_language'],
            'image'=>organization.legal_representation.image.medium.url,
            'customer_number' => nil,
            'email_backend_host' => nil,
            'email_backend_port' => nil,
            'email_backend_user' => nil,
            'email_backend_encryption' => nil,
            'email_backend_active' => false,
            'email_backend_signature' => nil,
            'updatable'=>true,
            'deletable'=>false,
          }
        }
      end

      it '401' do
        GET "/localpools/#{localpool.id}/organizations/#{organization.id}", $admin
        expire_admin_session do
          GET "/localpools/#{localpool.id}/organizations", $admin
          expect(response).to be_session_expired_json(401)

          GET "/localpools/#{localpool.id}/organizations/#{organization.id}", $admin
          expect(response).to be_session_expired_json(401)
        end
      end

      it '403' do
        # nothing to test here as an organization is public
      end

      it '404' do
        GET "/localpools/#{localpool.id}/organizations/bla-blub", $admin
        expect(response).to have_http_status(404)
      end

      it '200' do
        GET "/localpools/#{localpool.id}/organizations/#{organization.id}", $admin, include: 'bank_accounts, contact, legal_representation'
        expect(response).to have_http_status(200)
        expect(json.to_yaml).to eq organization_json.to_yaml
      end
    end

    context 'address' do

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

      let(:organization_json) do
        {
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
          # FIXME this is now stored on association OrganizationMarketFunction
          'customer_number' => nil,
          'updatable'=>true,
          'deletable'=>false,
          'address'=>address_json
        }
      end

      context 'GET' do

        it '401' do
          GET "/localpools/#{localpool.id}/organizations/#{organization.id}/address", $admin
          expire_admin_session do
            GET "/localpools/#{localpool.id}/organizations/#{organization.id}/address", $admin
            expect(response).to be_session_expired_json(401)
          end
        end

        it '403' do
          # nothing to test here as an address of an organization is public
        end

        it '404' do
          organization.update(address: nil)
          begin
            GET "/localpools/#{localpool.id}/organizations/#{organization.id}/address", $admin
            expect(response).to have_http_status(404)
          ensure
            organization.update(address: address)
          end
        end

        it '200' do
          GET "/localpools/#{localpool.id}/organizations/#{organization.id}/address", $admin
          expect(response).to have_http_status(200)
          expect(json.to_yaml).to eq address_json.to_yaml

          GET "/localpools/#{localpool.id}/organizations/#{organization.id}", $admin, include: 'address'
          expect(response).to have_http_status(200)
          expect(json).to eq organization_json

        end
      end
    end

    context 'bank-account' do

      entity!(:bank_account) { create(:bank_account, owner: organization) }
      entity!(:idempotent_update) { { 'updated_at': bank_account.updated_at } }

      context 'PATCH' do
        it '200' do
          PATCH "/localpools/#{localpool.id}/organizations/#{organization.id}/bank-accounts/#{bank_account.id}", $admin, idempotent_update
          expect(response.status).to be 200
        end

        it '422' do
          PATCH "/localpools/#{localpool.id}/organizations/#{organization.id}/bank-accounts/#{bank_account.id}", $admin, {}
          expect(response.status).to be 422
        end
      end
    end

  end
end
