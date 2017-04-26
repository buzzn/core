describe "groups/localpools" do

  let(:admin) do
    entities[:admin] ||= Fabricate(:admin_token)
  end

  let(:user) do
    entities[:user] ||= Fabricate(:user_token)
  end

  let(:other) do
    entities[:other] ||= Fabricate(:user_token)
  end

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

  let(:empty_json) do
    {
      'data'=>[]
    }
  end

  context 'localpool-processing-contract' do

    let(:processing_json) do
      contract = localpool.localpool_processing_contract
      {
        "data" => {
          "id"=>contract.id,
          "type"=>"contract-localpool-processings",
          "attributes"=>{
            "type"=>"contract_localpool_processing",
            "status"=>"waiting_for_approval",
            "full-contract-number"=>"#{contract.contract_number}/#{contract.contract_number_addition}",
            "customer-number"=>contract.customer_number,
            "signing-date"=>contract.signing_date.to_s,
            "cancellation-date"=>nil,
            "end-date"=>nil,
            "updatable"=>true,
            "deletable"=>true,
            "first-master-uid"=>contract.first_master_uid,
            "second-master-uid"=>nil,
            "begin-date"=>contract.begin_date.to_s
          },
          "relationships"=>{
            "tariffs"=>{
              "data"=>contract.tariffs.collect do |t|
                {
                  "id"=>t.id,
                  "name"=>t.name,
                  "begin-date"=>t.begin_date.to_s,
                  "end-date"=>nil,
                  "energyprice-cents-per-kwh"=>t.energyprice_cents_per_kwh,
                  "baseprice-cents-per-month"=>t.baseprice_cents_per_month,
                  "contract-id"=>contract.id,
                }
              end
            },
            "payments"=>{
              "data"=>contract.payments.collect do |p|
                {
                  "id"=>p.id,
                  "begin-date"=>p.begin_date.to_s,
                  "end-date"=>nil,
                  "price-cents"=>p.price_cents,
                  "cycle"=>nil,
                  "source"=>nil,
                  "contract-id"=>contract.id,
                }
              end
            },
            "contractor"=>{
              "data"=>{
                "id"=>contract.contractor.id,
                "type"=>"organizations"
              }
            },
            "customer"=>{
              "data"=>{
                "id"=>contract.customer.id,
                "type"=>"users"
              }
            },
            "signing-user"=>{
              "data"=>{
                "id"=>contract.signing_user.id,
                "type"=>"users"
              }
            },
            "customer-bank-account"=>{
              "data"=>{
                "id"=>contract.customer_bank_account.id,
                "type"=>"bank-accounts"
              }
            },
            "contractor-bank-account"=>{
              "data"=>{
                "id"=>contract.contractor_bank_account.id,
                "type"=>"bank-accounts"
              }
            }
          }
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
        "data" => {
          "id"=>contract.id,
          "type"=>"contract-metering-point-operators",
          "attributes"=>{
            "type"=>"contract_metering_point_operator",
            "status"=>"waiting_for_approval",
            "full-contract-number"=>"#{contract.contract_number}/#{contract.contract_number_addition}",
            "customer-number"=>contract.customer_number,
            "signing-date"=>contract.signing_date.to_s,
            "cancellation-date"=>nil,
            "end-date"=>nil,
            "updatable"=>true,
            "deletable"=>true,
            "begin-date"=>contract.begin_date.to_s,
            "metering-point-operator-name"=>contract.metering_point_operator_name
          },
          "relationships"=>{
            "tariffs"=>{
              "data"=>contract.tariffs.collect do |t|
                {
                  "id"=>t.id,
                  "name"=>t.name,
                  "begin-date"=>t.begin_date.to_s,
                  "end-date"=>nil,
                  "energyprice-cents-per-kwh"=>t.energyprice_cents_per_kwh,
                  "baseprice-cents-per-month"=>t.baseprice_cents_per_month,
                  "contract-id"=>contract.id,
                }
              end
            },
            "payments"=>{
              "data"=>contract.payments.collect do |p|
                {
                  "id"=>p.id,
                  "begin-date"=>p.begin_date.to_s,
                  "end-date"=>nil,
                  "price-cents"=>p.price_cents,
                  "cycle"=>nil,
                  "source"=>nil,
                  "contract-id"=>contract.id,
                }
              end
            },
            "contractor"=>{
              "data"=>{
                "id"=>contract.contractor.id,
                "type"=>"organizations"
              }
            },
            "customer"=>{
              "data"=>{
                "id"=>contract.customer.id,
                "type"=>"users"
              }
            },
            "signing-user"=>{
              "data"=>{
                "id"=>contract.signing_user.id,
                "type"=>"users"
              }
            },
            "customer-bank-account"=>{
              "data"=>{
                "id"=>contract.customer_bank_account.id,
                "type"=>"bank-accounts"
              }
            },
            "contractor-bank-account"=>{
              "data"=>{
                "id"=>contract.contractor_bank_account.id,
                "type"=>"bank-accounts"
              }
            }
          }
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
      {
        'data'=> localpool.localpool_power_taker_contracts.collect do |contract|
          {
            "id"=>contract.id,
            "type"=>"contract-localpool-power-takers",
            "attributes"=>{
              "type"=>"contract_localpool_power_taker",
              "status"=>"waiting_for_approval",
              "full-contract-number"=>"#{contract.contract_number}/#{contract.contract_number_addition}",
              "customer-number"=>contract.customer_number,
              "signing-date"=>contract.signing_date.to_s,
              "cancellation-date"=>nil,
              "end-date"=>nil,
              "updatable"=>true,
              "deletable"=>true
            },
            "relationships"=>{
              "tariffs"=>{
                "data"=>contract.tariffs.collect do |t|
                  {
                    "id"=>t.id,
                    "name"=>t.name,
                    "begin-date"=>t.begin_date.to_s,
                    "end-date"=>nil,
                    "energyprice-cents-per-kwh"=>t.energyprice_cents_per_kwh,
                    "baseprice-cents-per-month"=>t.baseprice_cents_per_month,
                    "contract-id"=>contract.id,
                  }
                end
              },
              "payments"=>{
                "data"=>contract.payments.collect do |p|
                  {
                    "id"=>p.id,
                    "begin-date"=>p.begin_date.to_s,
                    "end-date"=>nil,
                    "price-cents"=>p.price_cents,
                    "cycle"=>nil,
                    "source"=>nil,
                    "contract-id"=>contract.id,
                  }
                end
              },
              "contractor"=>{
                "data"=>{
                  "id"=>contract.contractor.id,
                  "type"=>"users"
                }
              },
              "customer"=>{
                "data"=>{
                  "id"=>contract.customer.id,
                  "type"=>"users"
                }
              },
              "signing-user"=>{
                "data"=>{
                  "id"=>contract.signing_user.id,
                  "type"=>"users"
                }
              },
              "customer-bank-account"=>{
                "data"=>{
                  "id"=>contract.customer_bank_account.id,
                  "type"=>"bank-accounts"
                }
              },
              "contractor-bank-account"=>{
                "data"=>{
                  "id"=>contract.contractor_bank_account.id,
                  "type"=>"bank-accounts"
                }
              }
            }
          }
        end
      }
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



