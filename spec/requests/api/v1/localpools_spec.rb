describe "groups/localpools" do

<<<<<<< HEAD
  entity(:admin) { Fabricate(:admin_token) }

  entity(:user) { Fabricate(:user_token) }

  entity(:other) { Fabricate(:user_token) }
=======
  let(:admin) do
    entities[:admin] ||= Fabricate(:admin_token)
  end

  let(:user) do
    entities[:user] ||= Fabricate(:user_token)
  end

  let(:other) do
    entities[:other] ||= Fabricate(:user_token)
  end
>>>>>>> adds groups/localpool/:id/localpool-power-taker-contracts endpoint

  let(:anonymous_denied_json) do
    {
      "errors" => [
        { "title"=>"Permission Denied",
          "detail"=>"retrieve Group::Localpool: permission denied for User: --anonymous--" }
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
          "detail"=>"Group::Localpool: bla-blub not found" }
      ]
    }
  end

  let(:nested_not_found_json) do
    {
      "errors" => [
        { "title"=>"Record Not Found",
          "detail"=>"Buzzn::RecordNotFound" }
      ]
    }
  end

  let(:not_found_json) do
    json = anonymous_not_found_json.dup
    json['errors'][0]['detail'] = "Group::Localpool: bla-blub not found by User: #{admin.resource_owner_id}"
    json
  end

<<<<<<< HEAD
  entity(:localpool) do
    localpool = Fabricate(:localpool)
    3.times.each do
      c = Fabricate(:localpool_power_taker_contract)
      c.register.group = localpool
      c.register.save
    end
    Fabricate(:localpool_processing_contract, localpool: localpool)
    Fabricate(:metering_point_operator_contract, localpool: localpool)
    localpool
  end

  entity(:localpool_no_contracts) { Fabricate(:localpool) }
=======
  let(:localpool) do
    entities[:localpool] ||=
      begin
        localpool = Fabricate(:localpool)
        3.times.each do
          c = Fabricate(:localpool_power_taker_contract)
          c.register.group = localpool
          c.register.save
        end
        Fabricate(:localpool_processing_contract, localpool: localpool)
        Fabricate(:metering_point_operator_contract, localpool: localpool)
        localpool
      end
  end

  let(:localpool_no_contracts) do
    entities[:localpool_no_contracts] ||= Fabricate(:localpool)
  end
>>>>>>> adds groups/localpool/:id/localpool-power-taker-contracts endpoint

  let(:empty_json) do
    {
      'data'=>[]
    }
  end

  context 'localpool-processing-contract' do

    let(:processing_json) do
      contract = localpool.localpool_processing_contract
      {
        "id"=>contract.id,
        "type"=>"contract_localpool_processing",
        "status"=>"waiting_for_approval",
        "full_contract_number"=>"#{contract.contract_number}/#{contract.contract_number_addition}",
        "customer_number"=>contract.customer_number,
        "signing_date"=>contract.signing_date.to_s,
        "cancellation_date"=>nil,
        "end_date"=>nil,
        "updatable"=>true,
        "deletable"=>true,
        "first_master_uid"=>contract.first_master_uid,
        "second_master_uid"=>nil,
        "begin_date"=>contract.begin_date.to_s,
        "tariffs"=>contract.tariffs.collect do |t|
          {
            "id"=>t.id,
            "type"=>'contract_tariff',
            "name"=>t.name,
            "begin_date"=>t.begin_date.to_s,
            "end_date"=>nil,
            "energyprice_cents_per_kwh"=>t.energyprice_cents_per_kwh,
            "baseprice_cents_per_month"=>t.baseprice_cents_per_month,
          }
        end,
        "payments"=>contract.payments.collect do |p|
          {
            "id"=>p.id,
            "type"=>'contract_payment',
            "begin_date"=>p.begin_date.to_s,
            "end_date"=>nil,
            "price_cents"=>p.price_cents,
            "cycle"=>nil,
            "source"=>nil,
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
          "mode"=>contract.contractor.mode,
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
        "customer_bank_account"=>{
          "id"=>contract.customer_bank_account.id,
          "type"=>"bank_account",
          "holder"=>contract.customer_bank_account.holder,
          "bank_name"=>contract.customer_bank_account.bank_name,
          "bic"=>contract.customer_bank_account.bic,
          "iban"=>contract.customer_bank_account.iban,
          "direct_debit"=>contract.customer_bank_account.direct_debit
        },
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

    context 'GET' do
      it '403' do
        localpool.update(readable: :member)
        GET "/api/v1/groups/localpools/#{localpool.id}/localpool-processing-contract"
        expect(response).to have_http_status(403)
        expect(json).to eq anonymous_denied_json

        localpool.update(readable: :member)
        GET "/api/v1/groups/localpools/#{localpool.id}/localpool-processing-contract", user
        expect(response).to have_http_status(403)
        expect(json).to eq denied_json
      end

      it '404' do
        GET "/api/v1/groups/localpools/bla-blub/localpool-processing-contract", admin
        expect(response).to have_http_status(404)
        expect(json).to eq not_found_json

        GET "/api/v1/groups/localpools/#{localpool_no_contracts.id}/localpool-processing-contract", admin
        expect(response).to have_http_status(404)
        expect(json).to eq nested_not_found_json
      end

      it '200' do
        GET "/api/v1/groups/localpools/#{localpool.id}/localpool-processing-contract", admin
        
        expect(json.to_yaml).to eq processing_json.to_yaml
        expect(response).to have_http_status(200)

      end
    end
  end
  
  context 'metering-point-operator-contract' do


    let(:metering_point_json) do
      contract = localpool.metering_point_operator_contract
      {
        "id"=>contract.id,
        "type"=>"contract_metering_point_operator",
        "status"=>"waiting_for_approval",
        "full_contract_number"=>"#{contract.contract_number}/#{contract.contract_number_addition}",
        "customer_number"=>contract.customer_number,
        "signing_date"=>contract.signing_date.to_s,
        "cancellation_date"=>nil,
        "end_date"=>nil,
        "updatable"=>true,
        "deletable"=>true,
        "begin_date"=>contract.begin_date.to_s,
        "metering_point_operator_name"=>contract.metering_point_operator_name,
        "tariffs"=>[],
        "payments"=>[],
        "contractor"=>{
          "id"=>contract.contractor.id,
          "type"=>"organization",
          "name"=>contract.contractor.name,
          "phone"=>contract.contractor.phone,
          "fax"=>contract.contractor.fax,
          "website"=>contract.contractor.website,
          "email"=>contract.contractor.email,
          "description"=>contract.contractor.description,
          "mode"=>contract.contractor.mode,
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
        "customer_bank_account"=>{
          "id"=>contract.customer_bank_account.id,
          "type"=>"bank_account",
          "holder"=>contract.customer_bank_account.holder,
          "bank_name"=>contract.customer_bank_account.bank_name,
          "bic"=>contract.customer_bank_account.bic,
          "iban"=>contract.customer_bank_account.iban,
          "direct_debit"=>contract.customer_bank_account.direct_debit
        },
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

    context 'GET' do
      it '403' do
        localpool.update(readable: :member)
        GET "/api/v1/groups/localpools/#{localpool.id}/metering-point-operator-contract"
        expect(response).to have_http_status(403)
        expect(json).to eq anonymous_denied_json

        localpool.update(readable: :member)
        GET "/api/v1/groups/localpools/#{localpool.id}/metering-point-operator-contract", user
        expect(response).to have_http_status(403)
        expect(json).to eq denied_json
      end

      it '404' do
        GET "/api/v1/groups/localpools/bla-blub/metering-point-operator-contract", admin
        expect(response).to have_http_status(404)
        expect(json).to eq not_found_json
        
        GET "/api/v1/groups/localpools/#{localpool_no_contracts.id}/metering-point-operator-contract", admin
        expect(response).to have_http_status(404)
        expect(json).to eq nested_not_found_json
      end
      
      it '200' do
        GET "/api/v1/groups/localpools/#{localpool.id}/metering-point-operator-contract", admin
        
        expect(json.to_yaml).to eq metering_point_json.to_yaml
        expect(response).to have_http_status(200)
      end
    end
  end
  
  context 'power-taker-contracts' do

    let(:power_taker_contracts_json) do
      localpool.localpool_power_taker_contracts.collect do |contract|
        {
          "id"=>contract.id,
          "type"=>"contract_localpool_power_taker",
          "status"=>"waiting_for_approval",
          "full_contract_number"=>"#{contract.contract_number}/#{contract.contract_number_addition}",
          "customer_number"=>contract.customer_number,
          "signing_date"=>contract.signing_date.to_s,
          "cancellation_date"=>nil,
          "end_date"=>nil,
          "updatable"=>true,
          "deletable"=>true,
          "tariffs"=>contract.tariffs.collect do |t|
            {
              "id"=>t.id,
              "type"=>'contract_tariff',
              "name"=>t.name,
              "begin_date"=>t.begin_date.to_s,
              "end_date"=>nil,
              "energyprice_cents_per_kwh"=>t.energyprice_cents_per_kwh,
              "baseprice_cents_per_month"=>t.baseprice_cents_per_month,
            }
          end,
          "payments"=>contract.payments.collect do |p|
            {
              "id"=>p.id,
              "type"=>'contract_payment',
              "begin_date"=>p.begin_date.to_s,
              "end_date"=>nil,
              "price_cents"=>p.price_cents,
              "cycle"=>nil,
              "source"=>nil,
            }
          end,
          "contractor"=>{
            "id"=>contract.contractor.id,
            "type"=>"user",
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
          "customer_bank_account"=>{
            "id"=>contract.customer_bank_account.id,
            "type"=>"bank_account",
            "holder"=>contract.customer_bank_account.holder,
            "bank_name"=>contract.customer_bank_account.bank_name,
            "bic"=>contract.customer_bank_account.bic,
            "iban"=>contract.customer_bank_account.iban,
            "direct_debit"=>contract.customer_bank_account.direct_debit
          },
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
    end

    context 'GET' do
      it '403' do
        localpool.update(readable: :member)
        GET "/api/v1/groups/localpools/#{localpool.id}/power-taker-contracts"
        expect(response).to have_http_status(403)
        expect(json).to eq anonymous_denied_json

        localpool.update(readable: :member)
        GET "/api/v1/groups/localpools/#{localpool.id}/power-taker-contracts", user
        expect(response).to have_http_status(403)
        expect(json).to eq denied_json
      end

      it '404' do
        GET "/api/v1/groups/localpools/bla-blub/power-taker-contracts", admin
        expect(response).to have_http_status(404)
        expect(json).to eq not_found_json
      end

      it '200' do
        GET "/api/v1/groups/localpools/#{localpool.id}/power-taker-contracts", admin
        
        expect(json.to_yaml).to eq power_taker_contracts_json.to_yaml
        expect(response).to have_http_status(200)
      end
    end
  end
end
