describe Admin::LocalpoolRoda do

  def app
    Admin::LocalpoolRoda # this defines the active application for this test
  end

  context 'users' do

    entity!(:admin) { Fabricate(:admin_token) }

    entity!(:user_token) { Fabricate(:user_token) }

    entity!(:other) { Fabricate(:user_token) }

    entity!(:group) { Fabricate(:localpool) }

    entity!(:user) do
      User.find(other.resource_owner_id).add_role(:localpool_member, group)
      user = User.find(user_token.resource_owner_id)
      user.add_role(:localpool_owner, group)
      Fabricate(:bank_account, contracting_party: user)
      user
    end

    let(:denied_json) do
      {
        "errors" => [
          {
            "detail"=>"retrieve User: #{user.id} permission denied for User: #{other.resource_owner_id}"
          }
        ]
      }
    end

    let(:not_found_json) do
      {
        "errors" => [
          {
            "detail"=>"User: bla-blub not found by User: #{admin.resource_owner_id}"
          }
        ]
      }
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
        "deletable"=>false,
        "bank_accounts"=>{
          'array'=> user.bank_accounts.collect do |bank_account|
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
      group.users.collect do |user|
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
          "deletable"=>false,
          "bank_accounts"=> {
            'array'=> user.bank_accounts.collect do |bank_account|
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
    end

    let(:admin_users_json) do
      group.users.collect do |user|
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
          "bank_accounts"=> {
            'array'=> user.bank_accounts.collect do |bank_account|
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
    end

    let(:filtered_admin_users_json) do
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
          "bank_accounts"=>{
            'array'=>user.bank_accounts.collect do |bank_account|
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
      ]
    end

    context 'GET' do

      let(:admin_user_json) do
        json = user_json.dup
        json['deletable']=true
        json
      end

      it '403' do
        GET "/#{group.id}/users/#{user.id}", other
        expect(response).to have_http_status(403)
        expect(json).to eq denied_json
      end

      it '404' do
        GET "/#{group.id}/users/bla-blub", admin
        expect(response).to have_http_status(404)
        expect(json).to eq not_found_json
      end

      it '200' do
        GET "/#{group.id}/users/#{user.id}", user_token, include: :bank_accounts
        expect(response).to have_http_status(200)
        expect(json.to_yaml).to eq user_json.to_yaml

        GET "/#{group.id}/users/#{user.id}", admin, include: :bank_accounts
        expect(response).to have_http_status(200)
        expect(json.to_yaml).to eq admin_user_json.to_yaml
      end

      it '200 all' do
        GET "/#{group.id}/users", user_token, include: :bank_accounts
        expect(response).to have_http_status(200)
        expect(json['array']).to eq users_json

        GET "/#{group.id}/users", admin, include: :bank_accounts
        expect(response).to have_http_status(200)
        expect(sort(json['array']).to_yaml).to eq sort(admin_users_json).to_yaml
      end

      it '200 all filtered' do
        admin_user = User.find(admin.resource_owner_id)

        GET "/#{group.id}/users", user_token, include: :bank_accounts, filter: admin_user.first_name
        expect(response).to have_http_status(200)
        expect(json['array'].to_yaml).to eq empty_json.to_yaml

        GET "/#{group.id}/users", admin, include: :bank_accounts, filter: user.first_name
        expect(response).to have_http_status(200)
        expect(json['array'].to_yaml).to eq filtered_admin_users_json.to_yaml
      end
    end
  end
end
