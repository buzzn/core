# coding: utf-8
describe Admin::LocalpoolRoda do

  def app
    Admin::LocalpoolRoda # this defines the active application for this test
  end

  context 'organizations' do

    entity(:admin) { Fabricate(:admin_token) }

    entity(:user) { Fabricate(:user_token) }

    let(:denied_json) do
      {
        "errors" => [
          {
            "detail"=>"retrieve Organization: permission denied for User: #{user.resource_owner_id}" }
        ]
      }
    end

    let(:not_found_json) do
      {
        "errors" => [
          {
            "detail"=>"Organization: bla-blub not found by User: #{admin.resource_owner_id}" }
        ]
      }
    end

    entity(:group) { Fabricate(:localpool) }
    entity!(:address) { Fabricate(:address) }
    entity!(:organization) do
      organization = Fabricate(:metering_service_provider,
                               address: address,
                               contact: Fabricate(:person))
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
                "direct_debit"=>bank_account.direct_debit
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
            "updatable"=>true,
            "deletable"=>false,
          }
        }
      end

      it '403' do
        # nothing to test here as an organization is public
      end

      it '404' do
        GET "/#{group.id}/organizations/bla-blub", admin
        expect(response).to have_http_status(404)
        expect(json).to eq not_found_json
      end

      it '200' do
        GET "/#{group.id}/organizations/#{organization.id}", admin, include: 'bank_accounts, contact'
        expect(response).to have_http_status(200)
        expect(json.to_yaml).to eq organization_json.to_yaml
      end
    end

    context 'address' do

      let(:address_not_found_json) do
        {
          "errors" => [
            {
              "detail"=>"OrganizationResource: address not found by User: #{admin.resource_owner_id}" }
          ]
        }
      end

      let(:address_json) do
        {
          "id"=>address.id,
          "type"=>"address",
          'updated_at'=>address.updated_at.as_json,
          "address"=>nil,
          "street_name"=>address.street_name,
          "street_number"=>address.street_number,
          "city"=>address.city,
          "state"=>address.state,
          "zip"=>address.zip,
          "country"=>address.country,
          "longitude"=>nil,
          "latitude"=>nil,
          "addition"=>address.addition,
          "time_zone"=>"Berlin",
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
          "updatable"=>true,
          "deletable"=>true,
          "address"=>address_json
        }
      end

      context 'GET' do

        it '403' do
          # nothing to test here as an address of an organization is public
        end

        it '404' do
          address.update(addressable: nil)
          begin
            GET "/#{group.id}/organizations/#{organization.id}/address", admin
            expect(response).to have_http_status(404)
            expect(json).to eq address_not_found_json
          ensure
            address.update(addressable: organization)
          end
        end

        it '200' do
          GET "/#{group.id}/organizations/#{organization.id}/address", admin
          expect(response).to have_http_status(200)
          expect(json.to_yaml).to eq address_json.to_yaml

          GET "/#{group.id}/organizations/#{organization.id}", admin, include: 'address'
          expect(response).to have_http_status(200)
          expect(json).to eq organization_json

        end
      end
    end
  end
end
