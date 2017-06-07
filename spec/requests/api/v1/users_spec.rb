describe "users" do

  def app
    CoreRoda # this defines the active application for this test
  end

  entity!(:admin) { Fabricate(:admin_token) }

  entity!(:user_token) { Fabricate(:user_token) }

  entity!(:other) { Fabricate(:user_token) }

  entity(:user) do
    user = User.find(user_token.resource_owner_id)
    Fabricate(:bank_account, contracting_party: user)
    user
  end

  let(:anonymous_denied_json) do
    {
      "errors" => [
        {
          "detail"=>"retrieve User: permission denied for User: --anonymous--"
        }
      ]
    }
  end

  let(:denied_json) do
    json = anonymous_denied_json.dup
    json['errors'][0]['detail'].sub! /--anonymous--/, other.resource_owner_id
    json
  end

  let(:anonymous_not_found_json) do
    {
      "errors" => [
        {
          "detail"=>"User: bla-blub not found"
        }
      ]
    }
  end

  let(:not_found_json) do
    json = anonymous_not_found_json.dup
    json['errors'][0]['detail'] = "User: bla-blub not found by User: #{admin.resource_owner_id}"
    json
  end

  let(:empty_json) do
    []
  end

  let(:user_json) do
    {
      "id"=>user.id,
      "type"=>"user",
      "user_name"=>user.user_name,
      "title"=>user.profile.title,
      "first_name"=>user.first_name,
      "last_name"=>user.last_name,
      "gender"=>user.profile.gender,
      "phone"=>user.profile.phone,
      "email"=>user.email,
      "image"=>user.profile.image.md.url,
      "updatable"=>true,
      # TODO feels wrong that any user can delete her/him-self
      "deletable"=>true,
      "bank_accounts"=>{
        'array'=> user.bank_accounts.reload.collect do |bank_account|
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

  let(:users_json) do
    [
      {
        "id"=>user.id,
        "type"=>"user",
        "user_name"=>user.user_name,
        "title"=>user.profile.title,
        "first_name"=>user.first_name,
        "last_name"=>user.last_name,
        "gender"=>user.profile.gender,
        "phone"=>user.profile.phone,
        "email"=>user.email,
        "image"=>user.profile.image.md.url,
        "updatable"=>true,
        "deletable"=>true,
        "bank_accounts"=> user.bank_accounts.reload.collect do |bank_account|
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
    ]
  end

  let(:admin_users_json) do
    User.all.collect do |user|
      {
        "id"=>user.id,
        "type"=>"user",
        "user_name"=>user.user_name,
        "title"=>user.profile.title,
        "first_name"=>user.first_name,
        "last_name"=>user.last_name,
        "gender"=>user.profile.gender,
        "phone"=>user.profile.phone,
        "email"=>user.email,
        "image"=>user.profile.image.md.url,
        "updatable"=>true,
        "deletable"=>true,
        "bank_accounts"=> user.bank_accounts.reload.collect do |bank_account|
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
      end
  end

  let(:filtered_admin_users_json) do
    user = User.find(admin.resource_owner_id)
    [
      {
        "id"=>user.id,
        "type"=>"user",
        "user_name"=>user.user_name,
        "title"=>user.profile.title,
        "first_name"=>user.first_name,
        "last_name"=>user.last_name,
        "gender"=>user.profile.gender,
        "phone"=>user.profile.phone,
        "email"=>user.email,
        "image"=>user.profile.image.md.url,
        "updatable"=>true,
        "deletable"=>true,
        "bank_accounts"=> user.bank_accounts.reload.collect do |bank_account|
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
    ]
  end

  context 'GET' do

    let(:admin_user_json) do
      json = user_json.dup
      json['deletable']=true
      json
    end

    it '403' do
      GET "/api/v1/users/#{user.id}"
      expect(response).to have_http_status(403)
      expect(json).to eq anonymous_denied_json

      GET "/api/v1/users/#{user.id}", other
      expect(response).to have_http_status(403)
      expect(json).to eq denied_json
    end

    it '404' do
      GET "/api/v1/users/bla-blub"
      expect(response).to have_http_status(404)
      expect(json).to eq anonymous_not_found_json

      GET "/api/v1/users/bla-blub", admin
      expect(response).to have_http_status(404)
      expect(json).to eq not_found_json
    end

    it '200' do
      GET "/api/v1/users/#{user.id}", user_token, include: :bank_accounts
      expect(response).to have_http_status(200)
      expect(json.to_yaml).to eq user_json.to_yaml

      GET "/api/v1/users/#{user.id}", admin, include: :bank_accounts
      expect(response).to have_http_status(200)
      expect(json.to_yaml).to eq admin_user_json.to_yaml
    end

    it '200 all' do
      user.reload

      GET "/api/v1/users", user_token, include: :bank_accounts
      expect(response).to have_http_status(200)
      expect(json['array']).to eq users_json

      GET "/api/v1/users", admin, include: :bank_accounts
      expect(response).to have_http_status(200)
      expect(sort(json['array']).to_yaml).to eq sort(admin_users_json).to_yaml
    end

    it '200 all filtered' do
      admin_user = User.find(admin.resource_owner_id)

      GET "/api/v1/users", user_token, include: :bank_accounts, filter: admin_user.first_name
      expect(response).to have_http_status(200)
      expect(json['array'].to_yaml).to eq empty_json.to_yaml

      GET "/api/v1/users", admin, include: :bank_accounts, filter: admin_user.first_name
      expect(response).to have_http_status(200)
      expect(json['array'].to_yaml).to eq filtered_admin_users_json.to_yaml
    end
  end

  context 'GET me' do

    let(:me_json) do
      json = user_json.dup
      banks = json.delete('bank_accounts')
      json['sales_tax_number']=nil
      json['tax_rate']=nil
      json['tax_number']=nil
      json['bank_accounts'] =
        if user.bank_accounts.reload.size > 0
          banks
        else
          []
        end
      json
    end

    it '403' do
      GET "/api/v1/users/me"
      expect(json).to eq anonymous_denied_json
      expect(response).to have_http_status(403)
    end

    it '200' do
      user.reload

      GET "/api/v1/users/me", user_token, include: :bank_accounts
      expect(json.to_yaml).to eq me_json.to_yaml
      expect(response).to have_http_status(200)
    end
  end
end
