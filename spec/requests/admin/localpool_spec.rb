describe Admin::LocalpoolRoda do

  def app
    Admin::LocalpoolRoda # this defines the active application for this test
  end

  entity(:admin) { Fabricate(:admin_token) }

  entity(:user) { Fabricate(:user_token) }

  entity(:other) { Fabricate(:user_token) }

  let(:denied_json) do
    {
      "errors" => [
        {
          "detail"=>"retrieve Group::Localpool: #{localpool.id} permission denied for User: #{other.resource_owner_id}"
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

  entity(:manager) { Fabricate(:user) }
  entity!(:localpool) do
    localpool = Fabricate(:localpool)
    manager.add_role(:manager, localpool)
    c = Fabricate(:localpool_power_taker_contract)
    c.localpool = localpool
    c.register.group = localpool
    c.register.save
    c.save
    Fabricate(:localpool_processing_contract, localpool: localpool)
    Fabricate(:metering_point_operator_contract, localpool: localpool)
    User.find(user.resource_owner_id).add_role(:localpool_member, localpool)
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
        "slug"=>localpool.slug,
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
      "slug"=>localpool_no_contracts.slug,
      "description"=>localpool_no_contracts.description,
      "updatable"=>true,
      "deletable"=>true,
      "meters"=>{
        'array'=> localpool_no_contracts.meters.collect do |meter|
          {
            "id"=>meter.id,
            "type"=>"meter_virtual",
            "product_name"=>meter.product_name,
            "product_serialnumber"=>meter.product_serialnumber,
            'ownership'=>nil,
            'section'=>nil,
            'build_year'=>nil,
            'calibrated_until'=>nil,
            "edifact_metering_type"=>meter.edifact_metering_type,
            "edifact_meter_size"=>nil,
            'edifact_tariff'=>nil,
            'edifact_measurement_method'=>nil,
            'edifact_mounting_method'=>nil,
            'edifact_voltage_level'=>nil,
            'edifact_cycle_interval'=>nil,
            'edifact_data_logging'=>nil,
            'sent_data_dso'=>nil,
            "updatable"=>true,
            "deletable"=>true
          }
        end
      }
    }
  end

  context 'GET' do
    it '403 permission denied' do
      GET "/#{localpool.id}", other
      expect(response).to have_http_status(403)
      expect(json).to eq denied_json
    end

    it '404' do
      GET "/bla-blub", admin
      expect(response).to have_http_status(404)
      expect(json).to eq not_found_json
    end

    it '200' do
      GET "/#{localpool_no_contracts.id}", admin, include: :meters
      expect(response).to have_http_status(200)
      expect(json.to_yaml).to eq localpool_json.to_yaml
    end

    it '200 all' do
      GET ""
      expect(response).to have_http_status(200)
      expect(json['array']).to eq empty_json

      GET "?include=", admin
      expect(response).to have_http_status(200)
      expect(sort(json['array'])).to eq sort(localpools_json)
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
        "signing_user"=>contract.signing_user,
        "signing_date"=>contract.signing_date.to_s,
        "cancellation_date"=>nil,
        "end_date"=>nil,
        "updatable"=>true,
        "deletable"=>false,
        "first_master_uid"=>contract.first_master_uid,
        "second_master_uid"=>nil,
        "begin_date"=>contract.begin_date.to_s,
        "tariffs"=>{
          'array'=> contract.tariffs.collect do |t|
            {
              "id"=>t.id,
              "type"=>'contract_tariff',
              "name"=>t.name,
              "begin_date"=>t.begin_date.to_s,
              "end_date"=>nil,
              "energyprice_cents_per_kwh"=>t.energyprice_cents_per_kwh,
              "baseprice_cents_per_month"=>t.baseprice_cents_per_month,
            }
          end
        },                   
        "payments"=>{
          'array'=> contract.payments.collect do |p|
            {
              "id"=>p.id,
              "type"=>'contract_payment',
              "begin_date"=>p.begin_date.to_s,
              "end_date"=>nil,
              "price_cents"=>p.price_cents,
              "cycle"=>p.cycle,
              "source"=>p.source,
            }
          end
        },
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
          "deletable"=>false
        },
        "customer"=>{
          "id"=>contract.customer.id,
          "type"=>"person",
          "prefix"=>contract.customer.attributes['prefix'],
          "title"=>contract.customer.title,
          "first_name"=>contract.customer.first_name,
          "last_name"=>contract.customer.last_name,
          "phone"=>contract.customer.phone,
          "fax"=>contract.customer.fax,
          "email"=>contract.customer.email,
          "share_with_group"=>true,
          "share_publicly"=>false,
          "preferred_language"=>contract.customer.attributes['preferred_language'],
          "image"=>nil,
          "updatable"=>true,
          "deletable"=>false
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
            "detail"=>"retrieve Contract::LocalpoolProcessingResource: permission denied for User: #{user.resource_owner_id}"
          }
        ]
      }
    end

    context 'GET' do
      
      let(:nested_not_found_json) do
        {
          "errors" => [
            {
              "detail"=>"Admin::LocalpoolResource: localpool_processing_contract not found by User: #{admin.resource_owner_id}" }
          ]
        }
      end

      it '403' do
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
        GET "/#{localpool.id}/localpool-processing-contract", admin, include: 'tariffs,payments,contractor,customer,customer_bank_account,contractor_bank_account'
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
        "signing_user"=>contract.signing_user,
        "signing_date"=>contract.signing_date.to_s,
        "cancellation_date"=>nil,
        "end_date"=>nil,
        "updatable"=>true,
        "deletable"=>false,
        "begin_date"=>contract.begin_date.to_s,
        "metering_point_operator_name"=>contract.metering_point_operator_name,
        "tariffs"=> { 'array'=>[] },
        "payments"=> { 'array' => [] },
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
          "deletable"=>false
        },
        "customer"=>{
          "id"=>contract.customer.id,
          "type"=>"person",
          "prefix"=>contract.customer.attributes['prefix'],
          "title"=>contract.customer.title,
          "first_name"=>contract.customer.first_name,
          "last_name"=>contract.customer.last_name,
          "phone"=>contract.customer.phone,
          "fax"=>contract.customer.fax,
          "email"=>contract.customer.email,
          "share_with_group"=>true,
          "share_publicly"=>false,
          "preferred_language"=>contract.customer.attributes['preferred_language'],
          "image"=>nil,
          "updatable"=>true,
          "deletable"=>false
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
            "detail"=>"retrieve Contract::MeteringPointOperatorResource: permission denied for User: #{user.resource_owner_id}"
          }
        ]
      }
    end

    context 'GET' do
      
      let(:nested_not_found_json) do
        {
          "errors" => [
            {
              "detail"=>"Admin::LocalpoolResource: metering_point_operator_contract not found by User: #{admin.resource_owner_id}" }
          ]
        }
      end

      it '403' do
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
        GET "/#{localpool.id}/metering-point-operator-contract", admin, include: 'tariffs,payments,contractor,customer,customer_bank_account,contractor_bank_account'

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
          "signing_user"=>contract.signing_user,
          "signing_date"=>contract.signing_date.to_s,
          "cancellation_date"=>nil,
          "end_date"=>nil,
          "updatable"=>true,
          "deletable"=>false,
        }
      end
    end

    context 'GET' do
      it '200' do
        GET "/#{localpool.id}/power-taker-contracts", user
        expect(json['array'].to_yaml).to eq empty_json.to_yaml
        expect(response).to have_http_status(200)

        GET "/#{localpool.id}/power-taker-contracts", admin
        expect(sort(json['array']).to_yaml).to eq sort(power_taker_contracts_json).to_yaml 
        expect(response).to have_http_status(200)
      end
    end
  end

  context 'managers' do

    context 'GET' do

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
            "image"=>manager.profile.image.md.url,
            "updatable"=>true,
            "deletable"=>true,
            "bank_accounts"=> { 'array'=>[] }
          }
        ]
      end
      
      it "200" do
        GET "/#{localpool.id}/managers", admin, include: :bank_accounts
          
        expect(response).to have_http_status(200)
        expect(json['array'].to_yaml).to eq(managers_json.to_yaml)
      end
    end
  end

end
