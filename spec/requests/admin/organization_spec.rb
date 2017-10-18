require_relative 'test_admin_localpool_roda'
describe Admin::LocalpoolRoda do

  def app
    TestAdminLocalpoolRoda # this defines the active application for this test
  end

  context 'organizations' do

    entity(:group) { Fabricate(:localpool) }
    entity!(:address) { Fabricate(:address) }
    entity!(:organization) do
      organization = Fabricate(:metering_service_provider,
                               contact: Fabricate(:person),
                               legal_representation: Fabricate(:person))
      organization.update(address: address)
      Fabricate(:bank_account, contracting_party: organization)
      Fabricate(:metering_point_operator_contract,
                localpool: group,
                customer: organization,
                contractor: organization)
      organization
    end

    context 'GET' do

      let(:organization_json) do
        {
          "id"=>organization.id,
          "type"=>"organization",
          'updated_at'=>organization.updated_at.as_json,
          "name"=>organization.name,
          "phone"=>organization.phone,
          "fax"=>organization.fax,
          "website"=>organization.website,
          "email"=>organization.email,
          "description"=>organization.description,
          "mode"=>"metering_service_provider",
          'customer_number' => nil,
          "updatable"=>true,
          "deletable"=>true,
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
            end,
          },
          'contact'=>{
            "id"=>organization.contact.id,
            "type"=>"person",
            'updated_at'=>organization.contact.updated_at.as_json,
            "prefix"=>organization.contact.attributes['prefix'],
            "title"=>organization.contact.title,
            "first_name"=>organization.contact.first_name,
            "last_name"=>organization.contact.last_name,
            "phone"=>organization.contact.phone,
            "fax"=>organization.contact.fax,
            "email"=>organization.contact.email,
            "preferred_language"=>organization.contact.attributes['preferred_language'],
            "image"=>organization.contact.image.md.url,
            'customer_number' => nil,
            "updatable"=>true,
            "deletable"=>false,
          },
          'legal_representation'=>{
            "id"=>organization.legal_representation.id,
            "type"=>"person",
            'updated_at'=>organization.legal_representation.updated_at.as_json,
            "prefix"=>organization.legal_representation.attributes['prefix'],
            "title"=>organization.legal_representation.title,
            "first_name"=>organization.legal_representation.first_name,
            "last_name"=>organization.legal_representation.last_name,
            "phone"=>organization.legal_representation.phone,
            "fax"=>organization.legal_representation.fax,
            "email"=>organization.legal_representation.email,
            "preferred_language"=>organization.legal_representation.attributes['preferred_language'],
            "image"=>organization.legal_representation.image.md.url,
            'customer_number' => nil,
            "updatable"=>true,
            "deletable"=>false,
          }
        }
      end

      it '401' do
        GET "/test/#{group.id}/organizations/#{organization.id}", $admin
        Timecop.travel(Time.now + 6 * 60 * 60) do
          GET "/test/#{group.id}/organizations", $admin
          expect(response).to be_session_expired_json(401)

          GET "/test/#{group.id}/organizations/#{organization.id}", $admin
          expect(response).to be_session_expired_json(401)
        end
      end

      it '403' do
        # nothing to test here as an organization is public
      end

      it '404' do
        GET "/test/#{group.id}/organizations/bla-blub", $admin
        expect(response).to be_not_found_json(404, Organization)
      end

      it '200' do
        GET "/test/#{group.id}/organizations/#{organization.id}", $admin, include: 'bank_accounts, contact, legal_representation'
        expect(response).to have_http_status(200)
        expect(json.to_yaml).to eq organization_json.to_yaml
      end
    end

    context 'address' do

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

      let(:organization_json) do
        {
          "id"=>organization.id,
          "type"=>"organization",
          'updated_at'=>organization.updated_at.as_json,
          "name"=>organization.name,
          "phone"=>organization.phone,
          "fax"=>organization.fax,
          "website"=>organization.website,
          "email"=>organization.email,
          "description"=>organization.description,
          "mode"=>organization.mode,
          'customer_number' => nil,
          "updatable"=>true,
          "deletable"=>true,
          "address"=>address_json
        }
      end

      context 'GET' do

        it '401' do
          GET "/test/#{group.id}/organizations/#{organization.id}/address", $admin
          Timecop.travel(Time.now + 6 * 60 * 60) do
            GET "/test/#{group.id}/organizations/#{organization.id}/address", $admin
            expect(response).to be_session_expired_json(401)
          end
        end

        it '403' do
          # nothing to test here as an address of an organization is public
        end

        it '404' do
          organization.update(address: nil)
          begin
            GET "/test/#{group.id}/organizations/#{organization.id}/address", $admin
            expect(response).to be_not_found_json(404, OrganizationResource, :address)
          ensure
            organization.update(address: address)
          end
        end

        it '200' do
          GET "/test/#{group.id}/organizations/#{organization.id}/address", $admin
          expect(response).to have_http_status(200)
          expect(json.to_yaml).to eq address_json.to_yaml

          GET "/test/#{group.id}/organizations/#{organization.id}", $admin, include: 'address'
          expect(response).to have_http_status(200)
          expect(json).to eq organization_json

        end
      end
    end
  end
end
