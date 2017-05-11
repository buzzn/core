# coding: utf-8
describe "organizations" do

  def app
    CoreRoda # this defines the active application for this test
  end

  entity(:admin) { Fabricate(:admin_token) }

  entity(:user) { Fabricate(:user_token) }

  let(:anonymous_denied_json) do
    {
      "errors" => [
        {
          "detail"=>"retrieve Organization: permission denied for User: --anonymous--" }
      ]
    }
  end

  let(:denied_json) do
    json = anonymous_denied_json.dup
    json['errors'][0]['detail'].sub! /--anonymous--/, user.resource_owner_id
    json
  end

  let(:anonymous_not_found_json) do
    {
      "errors" => [
        {
          "detail"=>"Organization: bla-blub not found" }
      ]
    }
  end

  let(:not_found_json) do
    json = anonymous_not_found_json.dup
    json['errors'][0]['detail'] = "Organization: bla-blub not found by User: #{admin.resource_owner_id}"
    json
  end

  entity(:organization) do
    organization = Fabricate(:metering_service_provider)
    Fabricate(:bank_account, contracting_party: organization)
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
        "updatable"=>false,
        "deletable"=>false,
        "address"=>nil,
        "bank_accounts"=>[]
      }
    end

    let(:admin_organization_json) do
      json = organization_json.dup
      json['updatable']=true
      json['deletable']=true
      json.delete('address')
      json.delete('bank_accounts')
      json
    end

    it '403' do
      # nothing to test here as an organization is public
    end

    it '404' do
      GET "/api/v1/organizations/bla-blub"
      expect(response).to have_http_status(404)
      expect(json).to eq anonymous_not_found_json

      GET "/api/v1/organizations/bla-blub", admin
      expect(response).to have_http_status(404)
      expect(json).to eq not_found_json
    end

    it '200' do
      GET "/api/v1/organizations/#{organization.id}"
      expect(response).to have_http_status(200)
      expect(json).to eq organization_json

      GET "/api/v1/organizations/#{organization.id}?include=", admin
      expect(response).to have_http_status(200)
      expect(json).to eq admin_organization_json
    end
  end

  context 'address' do

    entity(:organization_with_address) { Fabricate(:hell_und_warm)}

    let(:address) { organization_with_address.address}

    let(:address_not_found_json) do
      {
        "errors" => [
          {
            # TODO fix bad error response
            "detail"=>"Buzzn::RecordNotFound" }
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
        GET "/api/v1/organizations/bla-blub/address", admin
        expect(response).to have_http_status(404)
        expect(json).to eq not_found_json

        GET "/api/v1/organizations/#{organization.id}/address", admin
        expect(response).to have_http_status(404)
        expect(json).to eq address_not_found_json
      end

      it '200' do
        GET "/api/v1/organizations/#{organization_with_address.id}/address", admin
        expect(response).to have_http_status(200)
        expect(json.to_yaml).to eq address_json.to_yaml
      end
    end
  end
end
