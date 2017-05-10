describe "contracts" do

  def app
    CoreRoda # this defines the active application for this test
  end

  entity(:admin) { Fabricate(:admin_token) }

  entity(:user) { Fabricate(:user_token) }

  let(:anonymous_denied_json) do
    {
      "errors" => [
        {
          "detail"=>"retrieve Contract::Base: permission denied for User: --anonymous--" }
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
          "detail"=>"Contract::Base: bla-blub not found" }
      ]
    }
  end

  let(:not_found_json) do
    json = anonymous_not_found_json.dup
    json['errors'][0]['detail'] = "Contract::Base: bla-blub not found by User: #{admin.resource_owner_id}"
    json
  end

  entity(:metering_point_operator_contract) do
    group  = Fabricate(:localpool_forstenried)
    mpoc_forstenried = Fabricate(:mpoc_forstenried, signing_user: Fabricate(:user), localpool: group, customer: Fabricate(:user))
    group.metering_point_operator_contract
  end

  context 'GET' do

    let(:metering_point_operator_contract_json) do
      {
        "id"=>contract.id,
        "type"=>"contract_metering_point_operator",
        "status"=>"waiting_for_approval",
        "full_contract_number"=>"90041/0",
        "customer_number"=>"40021/1",
        "signing_date"=>"2014-10-01",
        "cancellation_date"=>nil,
        "end_date"=>nil,
        "updatable"=>true,
        "deletable"=>true,
        "begin_date"=>"2014-12-01",
        "metering_point_operator_name"=>"buzzn systems UG",
        "tariffs"=>[
          {
            "id"=>contract.tariffs[0].id,
            "type"=>'contract_tariff',
            "name"=>"metering_standard",
            "begin_date"=>"2014-12-01",
            "end_date"=>nil,
            "energyprice_cents_per_kwh"=>0,
            "baseprice_cents_per_month"=>30000,
          }
        ],
        "payments"=>contract.payments.collect do |p|
          {
            "id"=>p.id,
            "type"=>'contract_payment',
            "begin_date"=>p.begin_date.to_s,
            "end_date"=>p.end_date ? p.end_date.to_s : nil,
            "price_cents"=>p.price_cents,
            "cycle"=>p.cycle,
            "source"=>p.source,
          }
        end,
        "contractor"=>{
          "id"=>contract.contractor.id,
          "type"=>"organization",
          "name"=>contract.contractor.name,
          "phone"=>contract.contractor.phone,
          "fax"=>contract.contractor.fax,
          "website"=>contract.contractor.website,
          "email"=>contract.contractor.email,
          "description"=>contract.contractor.description,
          "mode"=>"metering_point_operator",
          "updatable"=>true,
          "deletable"=>true
        },
        "customer"=>{
          "id"=>contract.customer.id,
          "type"=>"user",
          "updatable"=>true,
          "deletable"=>true
        },
        "signing_user"=>{
          "id"=>contract.signing_user.id,
          "type"=>"user",
          "updatable"=>true,
          "deletable"=>true
        },
        "customer_bank_account"=>nil,
        "contractor_bank_account"=>{
          "id"=>contract.contractor_bank_account.id,
          "type"=>"bank_account",
          "holder"=>contract.contractor_bank_account.holder,
          "bank_name"=>contract.contractor_bank_account.bank_name,
          "bic"=>contract.contractor_bank_account.bic,
          "iban"=>contract.contractor_bank_account.iban,
          "direct_debit"=>contract.contractor_bank_account.direct_debit
        }
      }
    end

    # NOTE picking a sample contract is enough for the 404 and 403 tests

    let(:contract) { metering_point_operator_contract }

    it '403' do
      GET "/api/v1/contracts/#{contract.id}"
      expect(response).to have_http_status(403)
      expect(json).to eq anonymous_denied_json

      GET "/api/v1/contracts/#{contract.id}", user
      expect(response).to have_http_status(403)
      expect(json).to eq denied_json
    end

    it '404' do
      GET "/api/v1/contracts/bla-blub"
      expect(response).to have_http_status(404)
      expect(json).to eq anonymous_not_found_json

      GET "/api/v1/contracts/bla-blub", admin
      expect(response).to have_http_status(404)
      expect(json).to eq not_found_json
    end

    [:metering_point_operator].each do |type|

      let(:contract) { send "#{type}_contract" }

      let(:contract_json) { send "#{type}_contract_json" }

      context "as #{type}" do
        it '200' do
          GET "/api/v1/contracts/#{contract.id}", admin
          expect(response).to have_http_status(200)
          expect(json.to_yaml).to eq contract_json.to_yaml
        end
      end
    end
  end

  context 'customer' do

    # note: as customer is part of Contract::Base picking a sample contract is
    #       sufficient for the tests
    let(:customer_not_found_json) do
      {
        "errors" => [
          {
            # TODO fix bad error response
            "detail"=>"Buzzn::RecordNotFound" }
        ]
      }
    end

    #TODO flesh out the organization which is currently an user

    context 'GET' do

      it '403' do
        GET "/api/v1/contracts/#{metering_point_operator_contract.id}/customer"
        expect(response).to have_http_status(403)
        expect(json).to eq anonymous_denied_json

        GET "/api/v1/contracts/#{metering_point_operator_contract.id}/customer", user
        expect(response).to have_http_status(403)
        expect(json).to eq denied_json
      end

      it '404' do
        GET "/api/v1/contracts/bla-blub/customer", admin
        expect(response).to have_http_status(404)
        expect(json).to eq not_found_json

        # customer can not be nil
      end


      [:user, :organization].each do |type|

        context "as #{type}" do

          let("#{type}_contract") { metering_point_operator_contract }
          let("#{type}_customer") { send("#{type}_contract").customer}

          let("#{type}_customer_json") do
            customer =  send("#{type}_customer")
            {
              "id"=>customer.id,
              "type"=>"user",
              "updatable"=>false,
              "deletable"=>false,
              "user_name"=>customer.user_name,
              "title"=>nil,
              "first_name"=>customer.first_name,
              "last_name"=>customer.last_name,
              "gender"=>nil,
              "phone"=>customer.profile.phone,
              "email"=>customer.profile.email,
              "sales_tax_number"=>nil,
              "tax_rate"=>nil,
              "tax_number"=>nil
            }
          end

          it '200' do
            contract = send "#{type}_contract"
            GET "/api/v1/contracts/#{contract.id}/customer", admin
            expect(response).to have_http_status(200)
            expect(json.to_yaml).to eq(send("#{type}_customer_json").to_yaml)
          end
        end
      end
    end
  end

  context 'contractor' do

    # note: as contractor is part of Contract::Base picking a sample contract is
    #       sufficient for the tests
    let(:contractor_not_found_json) do
      {
        "errors" => [
          {
            # TODO fix bad error response
            "detail"=>"Buzzn::RecordNotFound" }
        ]
      }
    end

    #TODO flesh out the user which is currently an organization

    context 'GET' do

      it '403' do
        GET "/api/v1/contracts/#{metering_point_operator_contract.id}/contractor"
        expect(response).to have_http_status(403)
        expect(json).to eq anonymous_denied_json

        GET "/api/v1/contracts/#{metering_point_operator_contract.id}/contractor", user
        expect(response).to have_http_status(403)
        expect(json).to eq denied_json
      end

      it '404' do
        GET "/api/v1/contracts/bla-blub/contractor", admin
        expect(response).to have_http_status(404)
        expect(json).to eq not_found_json

        # contractor can not be nil
      end


      [:user, :organization].each do |type|

        context "as #{type}" do

          let("#{type}_contract") { metering_point_operator_contract }
          let("#{type}_contractor") { send("#{type}_contract").contractor}

          let("#{type}_contractor_json") do
            contractor =  send("#{type}_contractor")
            {
              "id"=>contractor.id,
              "type"=>"organization",
              "name"=>contractor.name,
              "phone"=>contractor.phone,
              "fax"=>contractor.fax,
              "website"=>contractor.website,
              "email"=>contractor.email,
              "description"=>contractor.description,
              "mode"=>"metering_point_operator",
              "updatable"=>false,
              "deletable"=>false,
              "sales_tax_number"=>nil,
              "tax_rate"=>nil,
              "tax_number"=>nil,
              "address"=>nil
            }
          end

          it '200' do
            contract = send "#{type}_contract"

            GET "/api/v1/contracts/#{contract.id}/contractor", admin
            expect(response).to have_http_status(200)
            expect(json.to_yaml).to eq(send("#{type}_contractor_json").to_yaml)
          end
        end
      end
    end
  end
end
