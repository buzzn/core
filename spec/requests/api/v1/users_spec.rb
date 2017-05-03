describe "users" do

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
    []
  end

  let(:user_json) do
    {
      "id"=>user.id,
      "type"=>"user",
      "updatable"=>true,
      # TODO feels wrong any a user can delete her/him-self
      "deletable"=>true,
      "user_name"=>user.user_name,
      "title"=>user.profile.title,
      "first_name"=>user.first_name,
      "last_name"=>user.last_name,
      "gender"=>user.profile.gender,
      "phone"=>user.profile.phone,
      "email"=>user.email
    }
  end

  let(:users_json) do
    [
      {
        "id"=>user.id,
        "type"=>"user",
        "updatable"=>false,
        "deletable"=>false
      }
    ]
  end

  let(:admin_users_json) do
    User.all.collect do |u|
      {
        "id"=>u.id,
        "type"=>"user",
        "updatable"=>false,
        "deletable"=>false
      }
      end
  end

  let(:filtered_admin_users_json) do
    [
      {
        "id"=>admin.resource_owner_id,
        "type"=>"user",
        "updatable"=>false,
        "deletable"=>false
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
      GET "/api/v1/users/#{user.id}", user_token
      expect(response).to have_http_status(200)
      expect(json.to_yaml).to eq user_json.to_yaml

      GET "/api/v1/users/#{user.id}", admin
      expect(response).to have_http_status(200)
      expect(json.to_yaml).to eq admin_user_json.to_yaml
    end

    it '200 all' do
      GET "/api/v1/users", user_token
      expect(response).to have_http_status(200)
      expect(json).to eq users_json

      GET "/api/v1/users", admin
      expect(response).to have_http_status(200)
      expect(json).to match_array admin_users_json
    end

    it '200 all filtered' do
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
      [
        {
          "id"=>bank_account.id,
          "type"=>"bank_account",
          "holder"=>bank_account.holder,
          "bank_name"=>bank_account.bank_name,
          "bic"=>bank_account.bic,
          "iban"=>bank_account.iban,
          "direct_debit"=>bank_account.direct_debit
        }
      ]
    end

    let(:empty_bank_account_json) do
      []
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

    entity!(:meter1) do
      meter = Fabricate(:input_meter)
      user.add_role(:manager, meter.input_register)
      meter
    end

    entity!(:meter2) do
      meter = Fabricate(:output_meter)
      user.add_role(:manager, meter.output_register)
      meter
    end

    entity!(:meter3) { Fabricate(:meter) }

    let(:user_meters_json) do
      [
        { "id"=>meter1.id,
          "type"=>"meter_real",
          "manufacturer_name"=>meter1.manufacturer_name,
          "manufacturer_product_name"=>meter1.manufacturer_product_name,
          "manufacturer_product_serialnumber"=>meter1.manufacturer_product_serialnumber,
          "metering_type"=>meter1.metering_type,
          "meter_size"=>nil,
          "ownership"=>nil,
          "direction_label"=>meter1.direction,
          "build_year"=>nil,
          "updatable"=>false,
          "deletable"=>false,
          "smart"=>false,
          "registers"=>[]
        },
        { "id"=>meter2.id,
          "type"=>"meter_real",
          "manufacturer_name"=>meter2.manufacturer_name,
          "manufacturer_product_name"=>meter2.manufacturer_product_name,
          "manufacturer_product_serialnumber"=>meter2.manufacturer_product_serialnumber,
          "metering_type"=>meter2.metering_type,
          "meter_size"=>nil,
          "ownership"=>nil,
          "direction_label"=>meter2.direction,
          "build_year"=>nil,
          "updatable"=>false,
          "deletable"=>false,
          "smart"=>false,
          "registers"=>[]
        }
      ]
    end

    let(:filtered_admin_meters_json) do
      [
        {
          "id"=>meter3.id,
          "type"=>"meter_real",
          "manufacturer_name"=>meter3.manufacturer_name,
          "manufacturer_product_name"=>meter3.manufacturer_product_name,
          "manufacturer_product_serialnumber"=>meter3.manufacturer_product_serialnumber,
          "metering_type"=>meter3.metering_type,
          "meter_size"=>meter3.meter_size,
          "ownership"=>meter3.ownership,
          "direction_label"=>meter3.direction,
          "build_year"=>'2011-07-02',
          "updatable"=>false,
          "deletable"=>false,
          "smart"=>false,
          "registers"=>[]
        }
      ]
    end

    let(:admin_meters_json) do
      json = user_meters_json.dup
      json += filtered_admin_meters_json
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
        begin
          user.profile.update(readable: :world)

          # TODO use user which can see user but not meters
          GET "/api/v1/users/#{user.id}/meters", other
          expect(response).to have_http_status(200)
          expect(json).to eq(empty_json)

        ensure
          user.profile.update(readable: nil)
        end

        GET "/api/v1/users/#{user.id}/meters", user_token
        expect(response).to have_http_status(200)
        # sort and yaml it for better debugging
        expect(json.sort{ |i, j| i['id'] <=> j['id']}.to_yaml).to eq(user_meters_json.sort{ |i, j| i['id'] <=> j['id']}.to_yaml)

        GET "/api/v1/users/#{user.id}/meters", admin
        expect(response).to have_http_status(200)
        # sort and yaml it for better debugging
        expect(json.sort{ |i, j| i['id'] <=> j['id']}.to_yaml).to eq(admin_meters_json.sort{ |i, j| i['id'] <=> j['id']}.to_yaml)
      end

      it '200 filtered' do
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
