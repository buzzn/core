describe "bank-accounts" do

  let(:account) do
    entities[:account] ||= 
      begin
        register = Fabricate(:output_meter).output_register
        contract = Fabricate(:power_giver_contract, register: register, contractor_bank_account: Fabricate(:bank_account))
        contract.contractor_bank_account
      end
  end

  let(:admin) do
    entities[:admin] ||= Fabricate(:admin_token)
  end

  let(:user) do
    entities[:user] ||= Fabricate(:user_token)
  end

  let(:anonymous_denied_json) do
    {
      "errors" => [
        { "title"=>"Permission Denied",
          "detail"=>"retrieve BankAccount: permission denied for User: --anonymous--" }
      ]
    }
  end

  let(:denied_json) do
    json = anonymous_denied_json.dup
    json['errors'][0]['detail'].sub! /--anonymous--/, user.resource_owner_id
    json
  end

  let(:not_found_json) do
    {
      "errors" => [
        { "title"=>"Record Not Found",
          "detail"=>"BankAccount: bla-bla-blub not found by User: #{admin.resource_owner_id}" }
      ]
    }
  end

  context 'PATCH' do

    let(:validation_json) do
      { "errors"=>[
          {
            "parameter"=>"bank_name",
            "source"=>{"pointer"=>"/data/attributes/bank_name"},
            "title"=>"Invalid Attribute",
            "detail"=>"bank_name is too long (maximum is 63 characters)"
          },
          {
            "parameter"=>"holder",
            "source"=>{"pointer"=>"/data/attributes/holder"},
            "title"=>"Invalid Attribute",
            "detail"=>"holder is too long (maximum is 63 characters)"
          }
        ]
      }
    end

    it '403' do
      PATCH "/api/v1/bank-accounts/#{account.id}"
      expect(response).to have_http_status(403)
      expect(json).to eq anonymous_denied_json

      PATCH "/api/v1/bank-accounts/#{account.id}", user
      expect(response).to have_http_status(403)
      expect(json).to eq denied_json
    end

    it '404' do
      PATCH "/api/v1/bank-accounts/bla-bla-blub", admin
      expect(response).to have_http_status(404)
      expect(json).to eq not_found_json
    end

    it '422' do
      # TODO add all possible validation errors, i.e. iban
      PATCH "/api/v1/bank-accounts/#{account.id}", admin,
            holder: 'Max Mueller' * 10,
            bank_name: 'Bundesbank' * 10
      expect(response).to have_http_status(422)
      expect(json).to eq validation_json
    end

    it '200' do
      PATCH "/api/v1/bank-accounts/#{account.id}", admin, holder: 'Max Mueller'
      expect(response).to have_http_status(200)
      expect(account.reload.holder).to eq 'Max Mueller'
    end
  end
end
