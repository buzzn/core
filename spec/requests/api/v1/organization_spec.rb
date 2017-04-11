# coding: utf-8
describe "organizations" do

  let(:admin) do
    Fabricate(:admin_token)
  end

  let(:user) do
    Fabricate(:user_token)
  end

  let(:anonymous_denied_json) do
    {
      "errors" => [
        { "title"=>"Permission Denied",
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
        { "title"=>"Record Not Found",
          "detail"=>"Organization: bla-blub not found" }
      ]
    }
  end

  let(:not_found_json) do
    json = anonymous_not_found_json.dup
    json['errors'][0]['detail'] = "Organization: bla-blub not found by User: #{admin.resource_owner_id}"
    json
  end

  let(:organization) { Fabricate(:metering_service_provider)}

  context 'GET' do

    let(:organization_json) do
      { "data"=>{
          "id"=>organization.id,
          "type"=>"organizations",
          "attributes"=>{
            "type"=>"organization",
            "name"=>organization.name,
            "phone"=>organization.phone,
            "fax"=>organization.fax,
            "website"=>organization.website,
            "email"=>organization.email,
            "description"=>organization.description,
            "mode"=>"metering_service_provider",
            "updatable"=>false,
            "deletable"=>false},
          "relationships"=>{
            "address"=>{"data"=>nil},
            "bank-account"=>{"data"=>nil}
          }
        }
      }
    end

    let(:admin_organization_json) do
      json = organization_json.dup
      json['data']['attributes']['updatable']=true
      json['data']['attributes']['deletable']=true
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
      bank_account = organization.bank_account
      bank_account.delete if bank_account

      GET "/api/v1/organizations/#{organization.id}"
      expect(response).to have_http_status(200)
      expect(json).to eq organization_json

      GET "/api/v1/organizations/#{organization.id}", admin
      expect(response).to have_http_status(200)
      expect(json).to eq admin_organization_json
    end
  end

  context 'bank_account' do

    let(:bank_account) { organization.bank_account}

    let(:bank_account_not_found_json) do
      {
        "errors" => [
          { "title"=>"Record Not Found",
            # TODO fix bad error response
            "detail"=>"Buzzn::RecordNotFound" }
        ]
      }
    end

    let(:bank_account_anonymous_denied_json) do
      json = anonymous_denied_json.dup
      json['errors'][0]['detail'].sub! 'Organization:', "BankAccount: #{bank_account.id}"
      json
    end

    let(:bank_account_json) do
      { "data"=>{
          "id"=>bank_account.id,
          "type"=>"bank-accounts",
          "attributes"=>{
            "type"=>"bank_account",
            "holder"=>bank_account.holder,
            "bank-name"=>bank_account.bank_name,
            "bic"=>bank_account.bic,
            "iban"=>bank_account.iban,
            "direct-debit"=>bank_account.direct_debit
          }
        }
      }
    end

    context 'GET' do
      it '403' do
        GET "/api/v1/organizations/#{organization.id}/bank-account"
        expect(response).to have_http_status(403)
        expect(json).to eq bank_account_anonymous_denied_json

        # TODO this should fail as expected same as top-level object
        #GET "/api/v1/organizations/#{organization.id}/bank-account", user
        #expect(response).to have_http_status(403)
        #expect(json).to eq bank_account_denied_json
      end

      it '404' do
        GET "/api/v1/organizations/bla-blub/bank-account", admin
        expect(response).to have_http_status(404)
        expect(json).to eq not_found_json

        organization.bank_account.delete
        GET "/api/v1/organizations/#{organization.id}/bank-account", admin
        expect(response).to have_http_status(404)
        expect(json).to eq bank_account_not_found_json
      end

      it '200' do
        GET "/api/v1/organizations/#{organization.id}/bank-account", admin
        expect(response).to have_http_status(200)
        expect(json).to eq(bank_account_json)
      end
    end
  end

  context 'address' do

    let(:organization) { Fabricate(:transmission_system_operator_with_address)}
    let(:address) { organization.address}

    let(:address_not_found_json) do
      {
        "errors" => [
          { "title"=>"Record Not Found",
            # TODO fix bad error response
            "detail"=>"Buzzn::RecordNotFound" }
        ]
      }
    end

    let(:address_json) do
      { "data"=>{
          "id"=>address.id,
          "type"=>"addresses",
          "attributes"=>{
            "type"=>"address",
            "address"=>nil,
            "street-name"=>"Zu den Höfen",
            "street-number"=>"7",
            "city"=>"Asche",
            "state"=>"Lower Saxony",
            "zip"=>37181,
            "country"=>"Germany",
            "longitude"=>nil,
            "latitude"=>nil,
            "addition"=>"HH",
            "time-zone"=>"Berlin",
            "updatable"=>true,
            "deletable"=>true
          }
        }
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

        organization.address.delete
        GET "/api/v1/organizations/#{organization.id}/address", admin
        expect(response).to have_http_status(404)
        expect(json).to eq address_not_found_json
      end

      it '200' do
        GET "/api/v1/organizations/#{organization.id}/address", admin
        expect(response).to have_http_status(200)
        expect(json.to_yaml).to eq address_json.to_yaml
      end
    end
  end
end
