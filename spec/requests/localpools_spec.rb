describe "localpools" do

  def app
    LocalpoolRoda # this defines the active application for this test
  end

  entity(:admin) { Fabricate(:admin_token) }

  entity(:user) { Fabricate(:user_token) }

  entity(:other) { Fabricate(:user_token) }

  let(:denied_json) do
    {
      "errors" => [
        {
          "detail"=>"retrieve Group::Localpool: permission denied for User: #{user.resource_owner_id}"
        }
      ]
    }
  end

  let(:not_found_json) do
    {
      "errors" => [
        {
          "detail"=>"Group::Localpool: bla-blub not found by User: #{admin.resource_owner_id}" }
      ]
    }
  end

  let(:nested_not_found_json) do
    {
      "errors" => [
        {
          "detail"=>"Buzzn::RecordNotFound" }
      ]
    }
  end

  entity(:manager) { Fabricate(:user) }
  entity!(:localpool) do
    localpool = Fabricate(:localpool)
    manager.add_role(:manager, localpool)
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

  let(:empty_json) { [] }

  let(:localpools_json) do
    Group::Localpool.all.collect do |localpool|
      {
        "id"=>localpool.id,
        "type"=>"group_localpool",
        "name"=>localpool.name,
        "description"=>localpool.description,
        "readable"=>"member",
        "updatable"=>true,
        "deletable"=>true
      }
    end
  end

  let(:localpool_json) do
    {
      "id"=>localpool_no_contracts.id,
      "type"=>"group_localpool",
      "name"=>localpool_no_contracts.name,
      "description"=>localpool_no_contracts.description,
      "readable"=>localpool_no_contracts.readable,
      "updatable"=>true,
      "deletable"=>true,
      "meters"=>localpool_no_contracts.meters.collect do |meter|
        {
          "id"=>meter.id,
          "type"=>"meter_virtual",
          "manufacturer_name"=>meter.manufacturer_name,
          "manufacturer_product_name"=>meter.manufacturer_product_name,
          "manufacturer_product_serialnumber"=>meter.manufacturer_product_serialnumber,
          "metering_type"=>meter.metering_type,
          "meter_size"=>nil,
          "ownership"=>nil,
          "direction_label"=>meter.direction,
          "build_year"=>nil,
          "updatable"=>true,
          "deletable"=>true,
        }
      end,
      "managers"=>[],
      "energy_producers"=>[],
      "energy_consumers"=>[],
      "localpool_processing_contract"=>nil,
      "metering_point_operator_contract"=>nil,
      "localpool_power_taker_contracts"=>[],
      "prices"=>[],
      "billing_cycles"=>[]
    }
  end

  context 'GET' do
    it '403' do
      localpool.update(readable: :member)
      GET "/#{localpool.id}", user
      expect(response).to have_http_status(403)
      expect(json).to eq denied_json
    end

    it '404' do
      GET "/bla-blub", admin
      expect(response).to have_http_status(404)
      expect(json).to eq not_found_json
    end

    it '200' do
      localpool_no_contracts
      GET "/#{localpool_no_contracts.id}", admin
      expect(response).to have_http_status(200)
      expect(json.to_yaml).to eq localpool_json.to_yaml
    end

    it '200 all' do
      Group::Localpool.update_all(readable: :member)
      GET ""
      expect(response).to have_http_status(200)
      expect(json).to eq empty_json

      GET "?include=", admin
      expect(response).to have_http_status(200)
      expect(sort(json)).to eq sort(localpools_json)
    end
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
          "mode"=>contract.contractor.mode,
          "updatable"=>true,
          "deletable"=>true
        },
        "customer"=>{
          "id"=>contract.customer.id,
          "type"=>"user",
          "user_name"=>contract.customer.user_name,
          "title"=>contract.customer.profile.title,
          "first_name"=>contract.customer.first_name,
          "last_name"=>contract.customer.last_name,
          "gender"=>contract.customer.profile.gender,
          "phone"=>contract.customer.profile.phone,
          "email"=>contract.customer.email,
          "updatable"=>true,
          "deletable"=>true
        },
        "signing_user"=>{
          "id"=>contract.signing_user.id,
          "type"=>"user",
          "user_name"=>contract.signing_user.user_name,
          "title"=>contract.signing_user.profile.title,
          "first_name"=>contract.signing_user.first_name,
          "last_name"=>contract.signing_user.last_name,
          "gender"=>contract.signing_user.profile.gender,
          "phone"=>contract.signing_user.profile.phone,
          "email"=>contract.signing_user.email,
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

    let(:denied_json) do
      {
        "errors" => [
          {
            "detail"=>"retrieve Contract::LocalpoolProcessing: #{localpool.localpool_processing_contract.id} permission denied for User: #{user.resource_owner_id}"
          }
        ]
      }
    end

    context 'GET' do
      it '403' do
        localpool.update(readable: :world)
        GET "/#{localpool.id}/localpool-processing-contract", user
        expect(response).to have_http_status(403)
        expect(json).to eq denied_json
      end

      it '404' do
        GET "/#{localpool_no_contracts.id}/localpool-processing-contract", admin
        expect(response).to have_http_status(404)
        expect(json).to eq nested_not_found_json
      end

      it '200' do
        GET "/#{localpool.id}/localpool-processing-contract", admin

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
          "user_name"=>contract.customer.user_name,
          "title"=>contract.customer.profile.title,
          "first_name"=>contract.customer.first_name,
          "last_name"=>contract.customer.last_name,
          "gender"=>contract.customer.profile.gender,
          "phone"=>contract.customer.profile.phone,
          "email"=>contract.customer.email,
          "updatable"=>true,
          "deletable"=>true
        },
        "signing_user"=>{
          "id"=>contract.signing_user.id,
          "type"=>"user",
          "user_name"=>contract.signing_user.user_name,
          "title"=>contract.signing_user.profile.title,
          "first_name"=>contract.signing_user.first_name,
          "last_name"=>contract.signing_user.last_name,
          "gender"=>contract.signing_user.profile.gender,
          "phone"=>contract.signing_user.profile.phone,
          "email"=>contract.signing_user.email,
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

    let(:denied_json) do
      {
        "errors" => [
          {
            "detail"=>"retrieve Contract::MeteringPointOperator: #{localpool.metering_point_operator_contract.id} permission denied for User: #{user.resource_owner_id}"
          }
        ]
      }
    end

    context 'GET' do
      it '403' do
        localpool.update(readable: :world)
        GET "/#{localpool.id}/metering-point-operator-contract", user
        expect(response).to have_http_status(403)
        expect(json).to eq denied_json
      end

      it '404' do
        GET "/bla-blub/metering-point-operator-contract", admin
        expect(response).to have_http_status(404)
        expect(json).to eq not_found_json

        GET "/#{localpool_no_contracts.id}/metering-point-operator-contract", admin
        expect(response).to have_http_status(404)
        expect(json).to eq nested_not_found_json
      end

      it '200' do
        GET "/#{localpool.id}/metering-point-operator-contract", admin

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
              "cycle"=>p.cycle,
              "source"=>p.source,
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
      it '200' do
        localpool.update(readable: :world)

        GET "/#{localpool.id}/power-taker-contracts", user
        expect(json.to_yaml).to eq empty_json.to_yaml
        expect(response).to have_http_status(200)

        GET "/#{localpool.id}/power-taker-contracts", admin
        expect(json.to_yaml).to eq power_taker_contracts_json.to_yaml
        expect(response).to have_http_status(200)
      end
    end
  end

  context 'managers' do

    context 'GET' do
      it '403' do
        localpool.update(readable: :member)
        GET "/#{localpool.id}/managers", user
        expect(response).to have_http_status(403)
        expect(json).to eq denied_json
      end

      let(:managers_json) do
        [
          {
            "id"=>manager.id,
            "type"=>"user",
            "user_name"=>manager.user_name,
            "title"=>nil,
            "first_name"=>manager.profile.first_name,
            "last_name"=>manager.profile.last_name,
            "gender"=>nil,
            "phone"=>manager.profile.phone,
            "email"=>manager.email,
            "updatable"=>true,
            "deletable"=>true,
            "bank_accounts"=>[]
          }
        ]
      end
      
      it "200" do
        GET "/#{localpool.id}/managers", admin
          
        expect(response).to have_http_status(200)
        expect(json.to_yaml).to eq(managers_json.to_yaml)
      end
    end
  end

end
