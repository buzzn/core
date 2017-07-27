describe Admin::LocalpoolRoda do

  def app
    Admin::LocalpoolRoda # this defines the active application for this test
  end

  context 'contracts' do

    entity(:admin) { Fabricate(:admin_token) }

    entity(:localpool) { Fabricate(:localpool) }

    entity(:person) do
      person = Fabricate(:person)
      Fabricate(:bank_account, contracting_party: person)
      Fabricate(:address, addressable: person)
      person.reload
      person
    end

    entity(:organization) do
      orga = Fabricate(:metering_point_operator, contact: person)
      Fabricate(:bank_account, contracting_party: orga)
      Fabricate(:address, addressable: orga)
      orga.reload
      orga
    end

    entity(:user) do
      token = Fabricate(:user_token)
      user = User.find(token.resource_owner_id)
      user.add_role(:localpool_member, localpool)
      token
    end

    let(:denied_json) do
      {
        "errors" => [
          {
            "detail"=>"retrieve Contract::Base: permission denied for User: #{user.resource_owner_id}" }
        ]
      }
    end

    let(:not_found_json) do
      {
        "errors" => [
          {
            "detail"=>"Contract::Localpool: bla-blub not found by User: #{admin.resource_owner_id}" }
        ]
      }
    end

    entity(:metering_point_operator_contract) do
      Fabricate(:metering_point_operator_contract,
                localpool: localpool,
                contractor: organization,
                customer: person)
    end

    entity(:localpool_power_taker_contract) do
      Fabricate(:localpool_power_taker_contract,
                customer: person,
                contractor: organization,
                register: Fabricate(:input_register,
                                    group: localpool,
                                    meter: Fabricate.build(:meter)))
    end

    let(:person_json) do
      person_json = {
        "id"=>person.id,
        "type"=>"person",
        'updated_at'=>person.updated_at.as_json,
        "prefix"=>person.attributes['prefix'],
        "title"=>person.attributes['title'],
        "first_name"=>person.first_name,
        "last_name"=>person.last_name,
        "phone"=>person.phone,
        "fax"=>person.fax,
        "email"=>person.email,
        "preferred_language"=>person.attributes['preferred_language'],
        "image"=>person.image.md.url,
        "updatable"=>true,
        "deletable"=>false,
        'address'=>{
          "id"=>person.address.id,
          "type"=>"address",
          'updated_at'=>person.address.updated_at.as_json,
          "address"=>nil,
          "street_name"=>person.address.street_name,
          "street_number"=>person.address.street_number,
          "city"=>person.address.city,
          "state"=>person.address.state,
          "zip"=>person.address.zip,
          "country"=>person.address.country,
          "longitude"=>nil,
          "latitude"=>nil,
          "addition"=>person.address.addition,
          "time_zone"=>"Berlin",
          "updatable"=>true,
          "deletable"=>false
        }
      }
      def person_json.dup
        json = super
        json['address'] = json['address'].dup
        json
      end
      person_json
    end

    let(:organization_json) do
      orga_json = {
        "id"=>organization.id,
        "type"=>"organization",
        'updated_at'=>organization.updated_at.as_json,
        "name"=>organization.name,
        "phone"=>organization.phone,
        "fax"=>organization.fax,
        "website"=>organization.website,
        "email"=>organization.email,
        "description"=>organization.description,
        "mode"=>"metering_point_operator",
        "updatable"=>true,
        "deletable"=>false,
        'address'=>{
          "id"=>organization.address.id,
          "type"=>"address",
          'updated_at'=>organization.address.updated_at.as_json,
          "address"=>nil,
          "street_name"=>organization.address.street_name,
          "street_number"=>organization.address.street_number,
          "city"=>organization.address.city,
          "state"=>organization.address.state,
          "zip"=>organization.address.zip,
          "country"=>organization.address.country,
          "longitude"=>nil,
          "latitude"=>nil,
          "addition"=>organization.address.addition,
          "time_zone"=>"Berlin",
          "updatable"=>true,
          "deletable"=>false
        },
        'contact'=>person_json
      }
      def orga_json.dup
        json = super
        json['address'] = json['address'].dup
        json['contact'] = json['contact'].dup
        json
      end
      orga_json
    end

    context 'GET' do
      let(:localpool_power_taker_contract_json) do
        contract = localpool_power_taker_contract
        {
          "id"=>contract.id,
          "type"=>"contract_localpool_power_taker",
          'updated_at'=>contract.updated_at.as_json,
          "status"=>"waiting_for_approval",
          "full_contract_number"=>contract.full_contract_number,
          "customer_number"=>contract.customer_number,
          "signing_user"=>contract.signing_user,
          "signing_date"=>contract.signing_date.to_s,
          "cancellation_date"=>nil,
          "end_date"=>nil,
          "updatable"=>true,
          "deletable"=>false,
          "begin_date"=>contract.begin_date.to_s,
          "tariffs"=>{
            'array'=>[
              {
                "id"=>contract.tariffs[0].id,
                "type"=>'contract_tariff',
                'updated_at'=>nil,
                "name"=>contract.tariffs[0].name,
                "begin_date"=>contract.tariffs[0].begin_date.to_s,
                "end_date"=>nil,
                "energyprice_cents_per_kwh"=>contract.tariffs[0].energyprice_cents_per_kwh,
                "baseprice_cents_per_month"=>contract.tariffs[0].baseprice_cents_per_month,
              }
            ]
          },
          "payments"=>{
            'array'=> contract.payments.collect do |p|
              {
                "id"=>p.id,
                "type"=>'contract_payment',
                'updated_at'=>nil,
                "begin_date"=>p.begin_date.to_s,
                "end_date"=>p.end_date ? p.end_date.to_s : nil,
                "price_cents"=>p.price_cents,
                "cycle"=>p.cycle,
                "source"=>p.source,
              }
            end
          },
          "contractor"=>organization_json.dup,
          "customer"=>person_json.dup,
          "customer_bank_account"=>{
            "id"=>contract.customer_bank_account.id,
            "type"=>"bank_account",
            'updated_at'=>contract.customer_bank_account.updated_at.as_json,
            "holder"=>contract.customer_bank_account.holder,
            "bank_name"=>contract.customer_bank_account.bank_name,
            "bic"=>contract.customer_bank_account.bic,
            "iban"=>contract.customer_bank_account.iban,
            "direct_debit"=>contract.customer_bank_account.direct_debit
          },
          "contractor_bank_account"=>{
            "id"=>contract.contractor_bank_account.id,
            "type"=>"bank_account",
            'updated_at'=>contract.contractor_bank_account.updated_at.as_json,
            "holder"=>contract.contractor_bank_account.holder,
            "bank_name"=>contract.contractor_bank_account.bank_name,
            "bic"=>contract.contractor_bank_account.bic,
            "iban"=>contract.contractor_bank_account.iban,
            "direct_debit"=>contract.contractor_bank_account.direct_debit
          },
          'register'=> {
            "id"=>contract.register.id,
            "type"=>"register_real",
            'updated_at'=>contract.register.updated_at.as_json,
            "direction"=>'in',
            "name"=>contract.register.name,
            "pre_decimal_position"=>6,
            "post_decimal_position"=>2,
            "low_load_ability"=>false,
            "label"=>'CONSUMPTION',
            "last_reading"=>0,
            "observer_min_threshold"=>100,
            "observer_max_threshold"=>5000,
            "observer_enabled"=>false,
            "observer_offline_monitoring"=>false,
            "metering_point_id"=>contract.register.metering_point_id,
            "obis"=>contract.register.obis,
          }
        }
      end

      let(:metering_point_operator_contract_json) do
        contract = metering_point_operator_contract
        {
          "id"=>contract.id,
          "type"=>"contract_metering_point_operator",
          'updated_at'=>contract.updated_at.as_json,
          "status"=>"waiting_for_approval",
          "full_contract_number"=>contract.full_contract_number,
          "customer_number"=>contract.customer_number,
          "signing_user"=>contract.signing_user,
          "signing_date"=>contract.signing_date.as_json,
          "cancellation_date"=>nil,
          "end_date"=>nil,
          "updatable"=>true,
          "deletable"=>false,
          "begin_date"=>contract.begin_date.to_s,
          "metering_point_operator_name"=>contract.metering_point_operator_name,
          "tariffs"=>{
            'array'=>[
              {
                "id"=>contract.tariffs[0].id,
                "type"=>'contract_tariff',
                'updated_at'=>nil,
                "name"=>contract.tariffs[0].name,
                "begin_date"=>contract.tariffs[0].begin_date.to_s,
                "end_date"=>nil,
                "energyprice_cents_per_kwh"=>contract.tariffs[0].energyprice_cents_per_kwh,
                "baseprice_cents_per_month"=>contract.tariffs[0].baseprice_cents_per_month,
              }
            ]
          },
          "payments"=>{
            'array'=> contract.payments.collect do |p|
              {
                "id"=>p.id,
                "type"=>'contract_payment',
                'updated_at'=>nil,
                "begin_date"=>p.begin_date.to_s,
                "end_date"=>p.end_date ? p.end_date.to_s : nil,
                "price_cents"=>p.price_cents,
                "cycle"=>p.cycle,
                "source"=>p.source,
              }
            end
          },
          "contractor"=>organization_json.dup,
          "customer"=>person_json.dup,
          "customer_bank_account"=>{
            "id"=>contract.customer_bank_account.id,
            "type"=>"bank_account",
            'updated_at'=>contract.customer_bank_account.updated_at.as_json,
            "holder"=>contract.customer_bank_account.holder,
            "bank_name"=>contract.customer_bank_account.bank_name,
            "bic"=>contract.customer_bank_account.bic,
            "iban"=>contract.customer_bank_account.iban,
            "direct_debit"=>contract.customer_bank_account.direct_debit
          },
          "contractor_bank_account"=>{
            "id"=>contract.contractor_bank_account.id,
            "type"=>"bank_account",
            'updated_at'=>contract.contractor_bank_account.updated_at.as_json,
            "holder"=>contract.contractor_bank_account.holder,
            "bank_name"=>contract.contractor_bank_account.bank_name,
            "bic"=>contract.contractor_bank_account.bic,
            "iban"=>contract.contractor_bank_account.iban,
            "direct_debit"=>contract.contractor_bank_account.direct_debit
          }
        }
      end

      # NOTE picking a sample contract is enough for the 404 and 403 tests

      let(:denied_json) do
        {
          "errors" => [
            {
              "detail"=>"retrieve Contract::MeteringPointOperator: #{metering_point_operator_contract.id} permission denied for User: #{user.resource_owner_id}" }
          ]
        }
      end

      it '403' do
        GET "/#{localpool.id}/contracts/#{metering_point_operator_contract.id}", user
        expect(json).to eq denied_json
        expect(response).to have_http_status(403)
      end

      it '404' do
        GET "/#{localpool.id}/contracts/bla-blub", admin
        expect(response).to have_http_status(404)
        expect(json).to eq not_found_json
      end

      [:metering_point_operator, :localpool_power_taker].each do |type|

        context "as #{type}" do

          let(:contract) { send "#{type}_contract" }

          let(:contract_json) { send "#{type}_contract_json" }

          it '200' do
            GET "/#{localpool.id}/contracts/#{contract.id}", admin, include: 'tariffs,payments,contractor:[address, contact:address],customer:[address, contact:address],customer_bank_account,contractor_bank_account,register'
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

      context 'GET' do

        let("contract") { [metering_point_operator_contract, localpool_power_taker_contract].sample }

        let("customer_json") do
          json = person_json.dup
          json.delete('address')
          json['sales_tax_number']=nil
          json['tax_rate']=nil
          json['tax_number']=nil
          json
        end

        it '200' do
          GET "/#{localpool.id}/contracts/#{contract.id}/customer", admin
          expect(response).to have_http_status(200)
          expect(json.to_yaml).to eq(customer_json.to_yaml)
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

      context 'GET' do

        let("contract") { [metering_point_operator_contract, localpool_power_taker_contract].sample }

        let("contractor_json") do
          json = organization_json.dup
          json.delete('address')
          json.delete('contact')
          json['sales_tax_number']=nil
          json['tax_rate']=nil
          json['tax_number']=nil
          json
        end

        it '200' do
          GET "/#{localpool.id}/contracts/#{contract.id}/contractor", admin
          expect(response).to have_http_status(200)
          expect(json.to_yaml).to eq(contractor_json.to_yaml)
        end
      end
    end
  end
end
