describe "BankAccount API" do

  let(:page_overload) { 11 }

  let(:user_with_register) { Fabricate(:user_with_register) }
  let(:contract) do
    contract = Fabricate(:power_giver_contract)
    contract.register = user_with_register.roles.first.resource
    contract.save!
    contract
  end
  let(:account) do
    account = Fabricate(:bank_account)
    account.bank_accountable = contract
    account.save!
    account
  end
  let(:admin_token) { Fabricate(:full_access_token_as_admin) }
  let(:simple_token) do
    Fabricate(:simple_access_token,
              resource_owner_id: user_with_register.id)
  end
  let(:full_token_community) do
    Fabricate(:full_access_token)
  end
  let(:full_token) do
    Fabricate(:full_access_token,
              resource_owner_id: user_with_register.id)
  end
  let(:smartmeter_token) do
    Fabricate(:smartmeter_access_token,
              resource_owner_id: user_with_register.id)
  end

  it 'denies access without token', :retry => 3 do
    post_without_token "/api/v1/bank-accounts", {}.to_json
    expect(response).to have_http_status(401)

    get_without_token "/api/v1/bank-accounts/#{account.id}"
    expect(response).to have_http_status(401)

    patch_without_token "/api/v1/bank-accounts/#{account.id}", {}.to_json
    expect(response).to have_http_status(401)

    delete_without_token "/api/v1/bank-accounts/#{account.id}"
    expect(response).to have_http_status(401)
  end

  [:simple_token, :full_token_community, :smartmeter_token].each do |token|

    it "does not get bank-account with #{token}", :retry => 3 do
      access_token  = send(token)

      if token != :full_token_community
        post_with_token "/api/v1/bank-accounts", {}.to_json, access_token.token
        expect(response).to have_http_status(403)
      end

      get_with_token "/api/v1/bank-accounts/#{account.id}", access_token.token
      expect(response).to have_http_status(403)

      patch_with_token "/api/v1/bank-accounts/#{account.id}", {}.to_json, access_token.token
      expect(response).to have_http_status(403)

      delete_with_token "/api/v1/bank-accounts/#{account.id}", access_token.token
      expect(response).to have_http_status(403)
    end

    it "does not get any bank-account with #{token}", :retry => 3 do
      3.times { Fabricate(:bank_account) }
      access_token  = send(token)

      get_with_token "/api/v1/bank-accounts", access_token.token
      if token == :full_token_community
        expect(json['data'].size).to eq(0)
      else
        expect(response).to have_http_status(403)
      end
    end
  end

  [:full_token, :admin_token].each do |token|

    it "paginates all bank accounts with #{token}", :retry => 3 do
      page_overload.times do
        Fabricate(:bank_account, bank_accountable: contract)
      end
      access_token  = send(token)

      get_with_token '/api/v1/bank-accounts', {}, access_token.token
      expect(response).to have_http_status(200)
      expect(json['meta']['total_pages']).to eq(2)

      get_with_token '/api/v1/bank-accounts', {per_page: 200}, access_token.token
      expect(response).to have_http_status(422)
    end

    it "creates bank-account with #{token}", :retry => 3 do
      access_token  = send(token)

      data = Fabricate.build(:bank_account).attributes.reject {|k,v| k == 'encrypted_iban' || v.nil? }
      data['iban'] = 'DE23100000001234567890'
      data['bank_accountable_id'] = contract.id
      data['bank_accountable_type'] = Contract.to_s

      post_with_token "/api/v1/bank-accounts", data.to_json, access_token.token
      expect(response).to have_http_status(201)
      expect(json['data']['id']).not_to be_nil

      # too long
      data.each do |k,v|
        next if k.to_s =~ /bank_accountable/
        invalid = data.dup
        invalid[k] = 'b' * 200

        post_with_token "/api/v1/bank-accounts", invalid.to_json, access_token.token
        expect(response).to have_http_status(422)
        expect(json['errors'].first['source']['pointer']).to eq "/data/attributes/#{k}"
      end

      # missing
      data.each do |k,v|
        next if k.to_s =~ /bank_accountable/
        invalid = data.dup
        invalid.delete(k)

        post_with_token "/api/v1/bank-accounts", invalid.to_json, access_token.token
        expect(response).to have_http_status(422)
        expect(json['errors'].first['source']['pointer']).to eq "/data/attributes/#{k}"
      end
    end


    it "retrieves bank-account with #{token}", :retry => 3 do
      access_token  = send(token)

      get_with_token "/api/v1/bank-accounts/#{account.id}-a", access_token.token
      expect(response).to have_http_status(404)

      get_with_token "/api/v1/bank-accounts/#{account.id}", access_token.token
      expect(response).to have_http_status(200)
      expect(json['data']['id']).to eq account.id
    end

    it "updates bank-account with #{token}", :retry => 3 do
      access_token  = send(token)

      patch_with_token "/api/v1/bank-accounts/#{account.id}-a", access_token.token
      expect(response).to have_http_status(404)

      data = Fabricate.build(:bank_account).attributes.reject {|k,v| k == 'encrypted_iban' || k == 'direct_debit' || v.nil? }
      data.each do |k,v|
        patch_with_token "/api/v1/bank-accounts/#{account.id}", { "#{k}": v}.to_json, access_token.token
        expect(response).to have_http_status(200)
        expect(json['data']['attributes'][k.sub(/_/, '-')]).to eq v
      end

      data.each do |k,v|
        patch_with_token "/api/v1/bank-accounts/#{account.id}", { "#{k}": 'a' * 200}.to_json, access_token.token
        expect(response).to have_http_status(422)
        expect(json['errors'].first['source']['pointer']).to eq "/data/attributes/#{k}"
      end
    end

    it "deletes bank-account with #{token}", :retry => 3 do
      access_token  = send(token)

      delete_with_token "/api/v1/bank-accounts/#{account.id}-a", access_token.token
      expect(response).to have_http_status(404)

      delete_with_token "/api/v1/bank-accounts/#{account.id}", access_token.token
      expect(response).to have_http_status(204)
      expect(BankAccount.where(id: account.id)).to eq []
    end

  end

end
