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
    entity(:organization_with_address) { Fabricate(:hell_und_warm) }
    entity!(:organization) do
      organization = Fabricate(:metering_service_provider)
      Fabricate(:bank_account, contracting_party: organization)
      Fabricate(:metering_point_operator_contract,
                localpool: group,
                customer: organization,
                contractor: organization_with_address)
      organization
    end

    context 'GET' do

      let(:organization_json) do
        {
          "id"=>organization.id,
          "type"=>"organization",
          "name"=>organization.name,
          "phone"=>organization.phone,
          "fax"=>organization.fax,
          "website"=>organization.website,
          "email"=>organization.email,
          "description"=>organization.description,
          "mode"=>"metering_service_provider",
          "updatable"=>true,
          "deletable"=>true,
          "address"=>nil,
          "bank_accounts"=>{
            'array'=> organization.bank_accounts.collect do |bank_account|
              {
                "id"=>bank_account.id,
                "type"=>"bank_account",
                "holder"=>bank_account.holder,
                "bank_name"=>bank_account.bank_name,
                "bic"=>bank_account.bic,
                "iban"=>bank_account.iban,
                "direct_debit"=>bank_account.direct_debit
              }
            end
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
        GET "/#{group.id}/organizations/#{organization.id}", admin, include: 'address,bank_accounts'
        expect(response).to have_http_status(200)
        expect(json).to eq organization_json
      end
    end

    context 'address' do

      let(:address) { organization_with_address.address}

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
          "address"=>nil,
          "street_name"=>"Aberlestraße",
          "street_number"=>"16",
          "city"=>"München",
          "state"=>"Bavaria",
          "zip"=>81371,
          "country"=>"Germany",
          "longitude"=>nil,
          "latitude"=>nil,
          "addition"=>"HH",
          "time_zone"=>"Berlin",
          "updatable"=>true,
          "deletable"=>true
        }
      end

      context 'GET' do

        it '403' do
          # nothing to test here as an address of an organization is public
        end

        it '404' do
          GET "/#{group.id}/organizations/#{organization.id}/address", admin
          expect(response).to have_http_status(404)
          expect(json).to eq address_not_found_json
        end

        it '200' do
          GET "/#{group.id}/organizations/#{organization_with_address.id}/address", admin
          expect(response).to have_http_status(200)
          expect(json.to_yaml).to eq address_json.to_yaml
        end
      end
    end
  end
end
