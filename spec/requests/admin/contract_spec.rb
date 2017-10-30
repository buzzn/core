require_relative 'test_admin_localpool_roda'
describe Admin::LocalpoolRoda do

  def app
    TestAdminLocalpoolRoda # this defines the active application for this test
  end

  context 'contracts' do

    entity(:localpool) { Fabricate(:localpool) }

    entity(:person) do
      person = Fabricate(:person)
      Fabricate(:bank_account, contracting_party: person)
      person.update(address: Fabricate(:address))
      person.reload
      person
    end

    entity(:organization) do
      orga = Fabricate(:metering_point_operator, contact: person)
      Fabricate(:bank_account, contracting_party: orga)
      orga.update(address: Fabricate(:address))
      orga.reload
      orga
    end

    before do
      $user.person.reload.add_role(Role::GROUP_MEMBER, localpool)
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
                localpool: localpool,
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
        'customer_number' => nil,
        "updatable"=>true,
        "deletable"=>false,
        'address'=>{
          "id"=>person.address.id,
          "type"=>"address",
          'updated_at'=>person.address.updated_at.as_json,
          "street"=>person.address.street,
          "city"=>person.address.city,
          "state"=>person.address.attributes['state'],
          "zip"=>person.address.zip,
          "country"=>person.address.attributes['country'],
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
        'customer_number' => nil,
        "updatable"=>true,
        "deletable"=>false,
        'address'=>{
          "id"=>organization.address.id,
          "type"=>"address",
          'updated_at'=>organization.address.updated_at.as_json,
          "street"=>organization.address.street,
          "city"=>organization.address.city,
          "state"=>organization.address.attributes['state'],
          "zip"=>organization.address.zip,
          "country"=>organization.address.attributes['country'],
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
          "full_contract_number"=>contract.full_contract_number,
          "customer_number"=>contract.customer_number,
          "signing_date"=>contract.signing_date.to_s,
          "begin_date"=>contract.begin_date.to_s,
          "termination_date"=>nil,
          "end_date"=>nil,
          "status"=>'active',
          "updatable"=>true,
          "deletable"=>false,
          'forecast_kwh_pa'=>contract.forecast_kwh_pa,
          'renewable_energy_law_taxation'=>contract.attributes['renewable_energy_law_taxation'],
          'third_party_billing_number'=>contract.third_party_billing_number,
          'third_party_renter_number'=>contract.third_party_renter_number,
          'old_supplier_name'=>contract.old_supplier_name,
          'old_customer_number'=>contract.old_customer_number,
          'old_account_number'=>contract.old_account_number,
          'mandate_reference' => nil,
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
            "direct_debit"=>contract.customer_bank_account.direct_debit,
            'updatable'=> true,
            'deletable'=> false,
          },
          "contractor_bank_account"=>{
            "id"=>contract.contractor_bank_account.id,
            "type"=>"bank_account",
            'updated_at'=>contract.contractor_bank_account.updated_at.as_json,
            "holder"=>contract.contractor_bank_account.holder,
            "bank_name"=>contract.contractor_bank_account.bank_name,
            "bic"=>contract.contractor_bank_account.bic,
            "iban"=>contract.contractor_bank_account.iban,
            "direct_debit"=>contract.contractor_bank_account.direct_debit,
            'updatable'=> true,
            'deletable'=> false,
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
            'updatable'=> true,
            'deletable'=> false,
            "createables"=>["readings"],
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
          "full_contract_number"=>contract.full_contract_number,
          "customer_number"=>contract.customer_number,
          "signing_date"=>contract.signing_date.as_json,
          "begin_date"=>contract.begin_date.to_s,
          "termination_date"=>nil,
          "end_date"=>nil,
          "status"=>'active',
          "updatable"=>true,
          "deletable"=>false,
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
            "direct_debit"=>contract.customer_bank_account.direct_debit,
            'updatable'=> true,
            'deletable'=> false,
          },
          "contractor_bank_account"=>{
            "id"=>contract.contractor_bank_account.id,
            "type"=>"bank_account",
            'updated_at'=>contract.contractor_bank_account.updated_at.as_json,
            "holder"=>contract.contractor_bank_account.holder,
            "bank_name"=>contract.contractor_bank_account.bank_name,
            "bic"=>contract.contractor_bank_account.bic,
            "iban"=>contract.contractor_bank_account.iban,
            "direct_debit"=>contract.contractor_bank_account.direct_debit,
            'updatable'=> true,
            'deletable'=> false,
          }
        }
      end

      # NOTE picking a sample contract is enough for the 404 and 403 tests

      it '401' do
        GET "/test/#{localpool.id}/contracts/#{metering_point_operator_contract.id}", $admin
        expire_admin_session do
          GET "/test/#{localpool.id}/contracts/#{metering_point_operator_contract.id}", $admin
          expect(response).to be_session_expired_json(401)

          GET "/test/#{localpool.id}/contracts", $admin
          expect(response).to be_session_expired_json(401)
        end
      end

      it '403' do
        GET "/test/#{localpool.id}/contracts/#{metering_point_operator_contract.id}", $user
        expect(response).to be_denied_json(403, metering_point_operator_contract)
      end

      it '404' do
        GET "/test/#{localpool.id}/contracts/bla-blub", $admin
        expect(response).to be_not_found_json(404, Contract::Localpool)
      end

      [:metering_point_operator, :localpool_power_taker].each do |type|

        context "as #{type}" do

          let(:contract) { send "#{type}_contract" }

          let(:contract_json) { send "#{type}_contract_json" }

          it '200' do
            GET "/test/#{localpool.id}/contracts/#{contract.id}", $admin, include: 'tariffs,payments,contractor:[address, contact:address],customer:[address, contact:address],customer_bank_account,contractor_bank_account,register'
            expect(response).to have_http_status(200)
            expect(json.to_yaml).to eq contract_json.to_yaml
          end
        end
      end
    end

    context 'customer' do

      context 'GET' do

        let("contract") { [metering_point_operator_contract, localpool_power_taker_contract].sample }

        let("customer_json") do
          json = person_json.dup
          json.delete('address')
          json
        end

        it '401' do
          GET "/test/#{localpool.id}/contracts/#{contract.id}/customer", $admin
          expire_admin_session do
            GET "/test/#{localpool.id}/contracts/#{contract.id}/customer", $admin
            expect(response).to be_session_expired_json(401)
          end
        end

        it '200' do
          GET "/test/#{localpool.id}/contracts/#{contract.id}/customer", $admin
          expect(response).to have_http_status(200)
          expect(json.to_yaml).to eq(customer_json.to_yaml)
        end
      end
    end

    context 'contractor' do

      context 'GET' do

        let("contract") { [metering_point_operator_contract, localpool_power_taker_contract].sample }

        let("contractor_json") do
          json = organization_json.dup
          json.delete('address')
          json.delete('contact')
          json
        end

        it '401' do
          GET "/test/#{localpool.id}/contracts/#{contract.id}/contractor", $admin
          expire_admin_session do
            GET "/test/#{localpool.id}/contracts/#{contract.id}/contractor", $admin
            expect(response).to be_session_expired_json(401)
          end
        end

        it '200' do
          GET "/test/#{localpool.id}/contracts/#{contract.id}/contractor", $admin
          expect(response).to have_http_status(200)
          expect(json.to_yaml).to eq(contractor_json.to_yaml)
        end
      end
    end
  end
end
