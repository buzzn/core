describe "users" do

  let(:admin) { Fabricate(:admin_token) }

  let(:user_token) { Fabricate(:user_token) }

  let(:other) { Fabricate(:user_token) }

  let(:user) do
    user = User.find(user_token.resource_owner_id)
    Fabricate(:bank_account, contracting_party: user)
    user
  end

  let(:anonymous_denied_json) do
    {
      "errors" => [
        { "title"=>"Permission Denied",
          "detail"=>"retrieve User: permission denied for User: --anonymous--" }
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
        { "title"=>"Record Not Found",
          "detail"=>"User: bla-blub not found" }
      ]
    }
  end

  let(:not_found_json) do
    json = anonymous_not_found_json.dup
    json['errors'][0]['detail'] = "User: bla-blub not found by User: #{admin.resource_owner_id}"
    json
  end

  let(:empty_json) do
    {
      "data"=>[]
    }
  end

  let(:user_json) do
    {
      "data"=>{
        "id"=>user.id,
        "type"=>"users",
        "attributes"=>{
          "type"=>"user",
          "updatable"=>true,
          # TODO feels wrong any a user can delete her/him-self
          "deletable"=>true,
          "user-name"=>user.user_name,
          "title"=>user.profile.title,
          "first-name"=>user.first_name,
          "last-name"=>user.last_name,
          "gender"=>user.profile.gender,
          "phone"=>user.profile.phone,
          "email"=>user.email
        }
      }
    }
  end

  let(:users_json) do
    {
      "data"=>[
        {
          "id"=>user.id,
          "type"=>"users",
          "attributes"=>{
            "type"=>"user",
            "updatable"=>false,
            "deletable"=>false
          }
        }
      ]
    }
  end

  let(:admin_users_json) do
    {
      "data"=> User.all.collect do |u|
        {
          "id"=>u.id,
          "type"=>"users",
          "attributes"=>{
            "type"=>"user",
            "updatable"=>false,
            "deletable"=>false
          }
        }
      end
    }
  end

  let(:filtered_admin_users_json) do
    {
      "data"=>[
        {
          "id"=>admin.resource_owner_id,
          "type"=>"users",
          "attributes"=>{
            "type"=>"user",
            "updatable"=>false,
            "deletable"=>false
          }
        }
      ]
    }
  end

  context 'GET' do

    let(:admin_user_json) do
      json = user_json.dup
      json['data']['attributes']['deletable']=true
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
      GET "/api/v1/users/#{user.id}", user_token
      expect(response).to have_http_status(200)
      expect(json.to_yaml).to eq user_json.to_yaml

      GET "/api/v1/users/#{user.id}", admin
      expect(response).to have_http_status(200)
      expect(json.to_yaml).to eq admin_user_json.to_yaml
    end

    it '200 all' do
      user # setup
      admin # setup
      other # setup

      GET "/api/v1/users", user_token
      expect(response).to have_http_status(200)
      expect(json).to eq users_json

      GET "/api/v1/users", admin
      expect(response).to have_http_status(200)
      expect(json['data']).to match_array admin_users_json['data']
    end

    it '200 all filtered' do
      user # setup
      admin # setup
      other # setup

      admin_user = User.find(admin.resource_owner_id)

      GET "/api/v1/users", user_token, filter: admin_user.first_name
      expect(response).to have_http_status(200)
      expect(json.to_yaml).to eq empty_json.to_yaml

      GET "/api/v1/users", admin, filter: admin_user.first_name
      expect(response).to have_http_status(200)
      expect(json.to_yaml).to eq filtered_admin_users_json.to_yaml
    end
  end

  context 'me' do

    it '403' do
      GET "/api/v1/users/me"
      expect(json).to eq anonymous_denied_json
      expect(response).to have_http_status(403)
    end

    it '200' do
      GET "/api/v1/users/me", user_token
      expect(json.to_yaml).to eq user_json.to_yaml
      expect(response).to have_http_status(200)
    end

  end

  context 'bank_account' do

    let(:bank_account) { user.bank_accounts.first}

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
      json['errors'][0]['detail'].sub! 'User:', "BankAccount: #{bank_account.id}"
      json
    end

    let(:bank_account_json) do
      { "data"=>
        [
          {
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
        ]
      }
    end

    let(:empty_bank_account_json) do
      {"data"=>[]}
    end

    context 'GET' do
      it '403' do
        GET "/api/v1/users/#{user.id}/bank-accounts"
        expect(response).to have_http_status(403)
        expect(json).to eq anonymous_denied_json

        GET "/api/v1/users/#{user.id}/bank-accounts", other
        expect(response).to have_http_status(403)
        expect(json).to eq denied_json

        # TODO use an user which can see other user but not bank_account
        #GET "/api/v1/users/#{user.id}/bank-account", user_token
        #expect(response).to have_http_status(403)
        #expect(json).to eq bank_account_denied_json
      end

      it '404' do
        GET "/api/v1/users/bla-blub/bank-accounts", admin
        expect(response).to have_http_status(404)
        expect(json).to eq not_found_json
      end

      it '200' do
        GET "/api/v1/users/#{user.id}/bank-accounts", user_token
        expect(response).to have_http_status(200)
        expect(json).to eq(bank_account_json)

        GET "/api/v1/users/#{user.id}/bank-accounts", admin
        expect(response).to have_http_status(200)
        expect(json).to eq(bank_account_json)

        user.bank_accounts.each{|bank_account| bank_account.delete}
        GET "/api/v1/users/#{user.id}/bank-accounts", admin
        expect(response).to have_http_status(200)
        expect(json).to eq empty_bank_account_json
      end

    end
  end

  context 'meters' do

    let(:meter1) do
      meter = Fabricate(:input_meter)
      user.add_role(:manager, meter.input_register)
      meter
    end

    let(:meter2) do
      meter = Fabricate(:output_meter)
      user.add_role(:manager, meter.output_register)
      meter
    end

    let(:meter3) { Fabricate(:meter) }

    let(:user_meters_json) do
      {
        "data"=>[
          { "id"=>meter1.id,
            "type"=>"meter-reals",
            "attributes"=>{
              "type"=>"meter_real",
              "manufacturer-name"=>meter1.manufacturer_name,
              "manufacturer-product-name"=>meter1.manufacturer_product_name,
              "manufacturer-product-serialnumber"=>meter1.manufacturer_product_serialnumber,
              "metering-type"=>nil,
              "meter-size"=>nil,
              "ownership"=>nil,
              "direction-label"=>"one_way_meter",
              "build-year"=>nil,
              "updatable"=>false,
              "deletable"=>false,
              "smart"=>false
            },
            "relationships"=>{
              "registers"=>{"data"=>[]}
            }
          },
          { "id"=>meter2.id,
            "type"=>"meter-reals",
            "attributes"=>{
              "type"=>"meter_real",
              "manufacturer-name"=>meter2.manufacturer_name,
              "manufacturer-product-name"=>meter2.manufacturer_product_name,
              "manufacturer-product-serialnumber"=>meter2.manufacturer_product_serialnumber,
              "metering-type"=>nil,
              "meter-size"=>nil,
              "ownership"=>nil,
              "direction-label"=>"one_way_meter",
              "build-year"=>nil,
              "updatable"=>false,
              "deletable"=>false,
              "smart"=>false
            },
            "relationships"=>{"registers"=>{"data"=>[]}}
          }
        ]
      }
    end

    let(:filtered_admin_meters_json) do
      {
        "data"=>[
          "id"=>meter3.id,
          "type"=>"meter-reals",
          "attributes"=>{
            "type"=>"meter_real",
            "manufacturer-name"=>meter3.manufacturer_name,
            "manufacturer-product-name"=>meter3.manufacturer_product_name,
            "manufacturer-product-serialnumber"=>meter3.manufacturer_product_serialnumber,
            "metering-type"=>"smart_meter",
            "meter-size"=>'edl40',
            "ownership"=>'buzzn_systems',
            "direction-label"=>'one_way_meter',
            "build-year"=>'2011-07-02',
            "updatable"=>false,
            "deletable"=>false,
            "smart"=>false
          },
          "relationships"=>{"registers"=>{"data"=>[]}}
        ]
      }
    end

    let(:admin_meters_json) do
      json = user_meters_json.dup
      json['data'] += filtered_admin_meters_json['data']
      json
    end

    context 'GET' do
      it '403' do
        GET "/api/v1/users/#{user.id}/meters"
        expect(response).to have_http_status(403)
        expect(json).to eq anonymous_denied_json

        GET "/api/v1/users/#{user.id}/meters", other
        expect(response).to have_http_status(403)
        expect(json).to eq denied_json
      end

      it '404' do
        GET "/api/v1/users/bla-blub/meters", admin
        expect(response).to have_http_status(404)
        expect(json).to eq not_found_json
      end

      it '200' do
        # TODO use user which can see user but not meters
        GET "/api/v1/users/#{user.id}/meters", user_token
        expect(response).to have_http_status(200)
        expect(json).to eq(empty_json)

        meter1 # setup
        meter2 # setup
        meter3 # setup

        GET "/api/v1/users/#{user.id}/meters", user_token
        expect(response).to have_http_status(200)
        # sort it and yaml it for better debugging
        expect(json['data'].sort{ |i, j| i['id'] <=> j['id']}.to_yaml).to eq(user_meters_json['data'].sort{ |i, j| i['id'] <=> j['id']}.to_yaml)

        GET "/api/v1/users/#{user.id}/meters", admin
        expect(response).to have_http_status(200)
        expect(json['data']).to match_array(admin_meters_json['data'])
      end

      it '200 filtered' do
        meter1 # setup
        meter2 # setup
        meter3 # setup

        GET "/api/v1/users/#{user.id}/meters", user_token, filter: meter3.manufacturer_product_serialnumber
        expect(response).to have_http_status(200)
        expect(json.to_yaml).to eq(empty_json.to_yaml)

        GET "/api/v1/users/#{user.id}/meters", admin, filter: meter3.manufacturer_product_serialnumber
        expect(response).to have_http_status(200)
        expect(json.to_yaml).to eq(filtered_admin_meters_json.to_yaml)
      end
    end
  end
end
