describe "BankAccount API" do

  let(:admin) { Fabricate(:admin) }
  let(:output_register) { Fabricate(:output_meter).output_register }
  let(:user_with_register) do
    user = Fabricate(:user)
    output_register.managers.add(admin, user)
    user
  end

  let(:contract) do
    Fabricate(:power_giver_contract, register: output_register)
  end

  let(:account) do
    account = Fabricate(:bank_account)
    account.bank_accountable = contract
    account.save!
    account
  end

  let(:admin_token) do
    Fabricate(:full_access_token_as_admin, resource_owner_id: admin.id)
  end
  let(:simple_token) do
    Fabricate(:simple_access_token, resource_owner_id: user_with_register.id)
  end
  let(:full_token_community) do
    Fabricate(:full_access_token)
  end
  let(:full_token) do
    Fabricate(:full_access_token, resource_owner_id: user_with_register.id)
  end
  let(:smartmeter_token) do
    Fabricate(:smartmeter_access_token, resource_owner_id: user_with_register.id)
  end

  it 'denies access without token' do
    # patch_without_token "/api/v1/bank-accounts/#{account.id}", {}.to_json
    # expect(response).to have_http_status(401)
  end

  [:simple_token, :full_token_community, :smartmeter_token].each do |token|

  #   it "does not get bank-account with #{token}" do
  #     access_token  = send(token)
  #
  #     patch_with_token "/api/v1/bank-accounts/#{account.id}", {}.to_json, access_token.token
  #     expect(response).to have_http_status(403)
  #   end

  end

  [:full_token, :admin_token].each do |token|

    # it "updates bank-account with #{token}" do
    #   access_token  = send(token)
    #
    #   patch_with_token "/api/v1/bank-accounts/#{account.id}-a", access_token.token
    #   expect(response).to have_http_status(404)
    #
    #   data = Fabricate.build(:bank_account).attributes.reject {|k,v| k == 'encrypted_iban' || k == 'direct_debit' || v.nil? }
    #   data.each do |k,v|
    #     patch_with_token "/api/v1/bank-accounts/#{account.id}", { "#{k}": v}.to_json, access_token.token
    #     expect(response).to have_http_status(200)
    #     expect(json['data']['attributes'][k.sub(/_/, '-')]).to eq v
    #   end
    #
    #   data.each do |k,v|
    #     patch_with_token "/api/v1/bank-accounts/#{account.id}", { "#{k}": 'a' * 200}.to_json, access_token.token
    #     expect(response).to have_http_status(422)
    #     expect(json['errors'].first['source']['pointer']).to eq "/data/attributes/#{k}"
    #   end
    # end

  end

end
