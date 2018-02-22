require_relative 'test_admin_localpool_roda'
describe Admin::LocalpoolRoda do

  def app
    TestAdminLocalpoolRoda # this defines the active application for this test
  end

  context 'contracts' do

    entity(:person) { create(:person, :with_bank_account) }

    entity(:localpool) { create(:localpool, owner: person) }

    entity(:organization) do
      create(:organization, :with_bank_account, :with_address, contact: person)
    end

    before do
      $user.person.reload.add_role(Role::GROUP_MEMBER, localpool)
    end

    entity(:metering_point_operator_contract) do
      create(:contract, :metering_point_operator,
             localpool: localpool,
             contractor: organization)
    end

    entity(:localpool_power_taker_contract) do
      create(:contract, :localpool_powertaker,
             customer: organization,
             localpool: localpool)
    end

    let(:person_json) do
      person_json = {
        'id'=>person.id,
        'type'=>'person',
        'updated_at'=>person.updated_at.as_json,
        'prefix'=>person.attributes['prefix'],
        'title'=>person.attributes['title'],
        'first_name'=>person.first_name,
        'last_name'=>person.last_name,
        'phone'=>person.phone,
        'fax'=>person.fax,
        'email'=>person.email,
        'preferred_language'=>person.attributes['preferred_language'],
        'image'=>person.image.medium.url,
        'customer_number' => nil,
        'updatable'=>true,
        'deletable'=>false,
        'address'=>{
          'id'=>person.address.id,
          'type'=>'address',
          'updated_at'=>person.address.updated_at.as_json,
          'street'=>person.address.street,
          'city'=>person.address.city,
          'zip'=>person.address.zip,
          'country'=>person.address.attributes['country'],
          'updatable'=>true,
          'deletable'=>false
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
        'id'=>organization.id,
        'type'=>'organization',
        'updated_at'=>organization.updated_at.as_json,
        'name'=>organization.name,
        'phone'=>organization.phone,
        'fax'=>organization.fax,
        'website'=>organization.website,
        'email'=>organization.email,
        'description'=>organization.description,
        'customer_number' => nil,
        'updatable'=>true,
        'deletable'=>false,
        'address'=>{
          'id'=>organization.address.id,
          'type'=>'address',
          'updated_at'=>organization.address.updated_at.as_json,
          'street'=>organization.address.street,
          'city'=>organization.address.city,
          'zip'=>organization.address.zip,
          'country'=>organization.address.attributes['country'],
          'updatable'=>true,
          'deletable'=>false
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
        register = contract.market_location.register
        meter = register.meter
        {
          'id'=>contract.id,
          'type'=>'contract_localpool_power_taker',
          'updated_at'=>contract.updated_at.as_json,
          'full_contract_number'=>contract.full_contract_number,
          'signing_date'=>contract.signing_date.to_s,
          'begin_date'=>contract.begin_date.to_s,
          'termination_date'=>nil,
          'last_date'=>nil,
          'status'=>contract.status.to_s,
          'updatable'=>true,
          'deletable'=>false,
          'forecast_kwh_pa'=>contract.forecast_kwh_pa,
          'renewable_energy_law_taxation'=>contract.attributes['renewable_energy_law_taxation'],
          'third_party_billing_number'=>contract.third_party_billing_number,
          'third_party_renter_number'=>contract.third_party_renter_number,
          'old_supplier_name'=>contract.old_supplier_name,
          'old_customer_number'=>contract.old_customer_number,
          'old_account_number'=>contract.old_account_number,
          'mandate_reference' => nil,
          'localpool' => {
            'id'=>contract.localpool.id,
            'type'=>'group_localpool',
            'updated_at'=>contract.localpool.updated_at.as_json,
            'name'=>contract.localpool.name,
            'slug'=>contract.localpool.slug,
            'description'=>contract.localpool.description,
          },
          'tariffs'=>{
            'array'=>contract.tariffs.collect do |tariff|
              {
                'id'=>contract.tariff.id,
                'type'=>'contract_tariff',
                'updated_at'=>nil,
                'name'=>contract.tariff.name,
                'begin_date'=>contract.tariff.begin_date.to_s,
                'last_date'=>nil,
                'energyprice_cents_per_kwh'=>contract.tariff.energyprice_cents_per_kwh,
                'baseprice_cents_per_month'=>contract.tariffs.baseprice_cents_per_month,
                'updatable' => false,
                'deletable' => false,
              }
            end
          },
          'payments'=>{
            'array'=> contract.payments.collect do |p|
              {
                'id'=>p.id,
                'type'=>'contract_payment',
                'updated_at'=>nil,
                'begin_date'=>p.begin_date.to_s,
                'end_date'=>p.end_date ? p.end_date.to_s : nil,
                'price_cents'=>p.price_cents,
                'cycle'=>p.cycle,
              }
            end
          },
          'contractor'=>person_json.dup,
          'customer'=>organization_json.dup,
          'customer_bank_account'=>{
            'id'=>contract.customer_bank_account.id,
            'type'=>'bank_account',
            'updated_at'=>contract.customer_bank_account.updated_at.as_json,
            'holder'=>contract.customer_bank_account.holder,
            'bank_name'=>contract.customer_bank_account.bank_name,
            'bic'=>contract.customer_bank_account.bic,
            'iban'=>contract.customer_bank_account.iban,
            'direct_debit'=>contract.customer_bank_account.direct_debit,
            'updatable'=> true,
            'deletable'=> false,
          },
          'contractor_bank_account'=>{
            'id'=>contract.contractor_bank_account.id,
            'type'=>'bank_account',
            'updated_at'=>contract.contractor_bank_account.updated_at.as_json,
            'holder'=>contract.contractor_bank_account.holder,
            'bank_name'=>contract.contractor_bank_account.bank_name,
            'bic'=>contract.contractor_bank_account.bic,
            'iban'=>contract.contractor_bank_account.iban,
            'direct_debit'=>contract.contractor_bank_account.direct_debit,
            'updatable'=> true,
            'deletable'=> false,
          },
          'market_location' => {
            'id' => contract.market_location.id,
            'type' => 'market_location',
            'updated_at'=> contract.market_location.updated_at.as_json,
            'name' => contract.market_location.name,
            'kind' => 'consumption',
            'updatable' => false,
            'deletable' => false,
            'register' => {
              'id'=>register.id,
              'type'=>'register_real',
              'updated_at'=>register.updated_at.as_json,
              'label'=>'CONSUMPTION',
              'last_reading'=>0,
              'observer_min_threshold'=>nil,
              'observer_max_threshold'=>nil,
              'observer_enabled'=>nil,
              'observer_offline_monitoring'=>nil,
              'meter_id' => meter.id,
              'updatable'=> true,
              'deletable'=> false,
              'createables'=>['readings'],
              'direction'=>'in',
              'pre_decimal_position'=>6,
              'post_decimal_position'=>1,
              'low_load_ability'=>false,
              'metering_point_id'=>register.metering_point_id,
              'obis'=>register.obis,
              'meter' => {
                'id'=>meter.id,
                'type'=>'meter_real',
                'updated_at'=> meter.updated_at.as_json,
                'product_serialnumber'=>meter.product_serialnumber,
                'sequence_number' => meter.sequence_number,
                'updatable'=>false,
                'deletable'=>false,
                'product_name'=>meter.product_name,
                'manufacturer_name'=>meter.attributes['manufacturer_name'],
                'manufacturer_description'=>meter.attributes['manufacturer_description'],
                'location_description'=>meter.attributes['location_description'],
                'direction_number'=>meter.attributes['direction_number'],
                'converter_constant'=>meter.converter_constant,
                'ownership'=>meter.attributes['ownership'],
                'build_year'=>meter.build_year,
                'calibrated_until'=>meter.calibrated_until ? meter.calibrated_until.to_s : nil,
                'edifact_metering_type'=>meter.attributes['edifact_metering_type'],
                'edifact_meter_size'=>meter.attributes['edifact_meter_size'],
                'edifact_tariff'=>meter.attributes['edifact_tariff'],
                'edifact_measurement_method'=>meter.attributes['edifact_measurement_method'],
                'edifact_mounting_method'=>meter.attributes['edifact_mounting_method'],
                'edifact_voltage_level'=>meter.attributes['edifact_voltage_level'],
                'edifact_cycle_interval'=>meter.attributes['edifact_cycle_interval'],
                'edifact_data_logging'=>meter.attributes['edifact_data_logging'],
                'sent_data_dso'=> meter.sent_data_dso.to_s,
                'data_source'=>meter.registers.first.data_source.to_s,
              }
            }
          }
        }
      end

      let(:metering_point_operator_contract_json) do
        contract = metering_point_operator_contract
        {
          'id'=>contract.id,
          'type'=>'contract_metering_point_operator',
          'updated_at'=>contract.updated_at.as_json,
          'full_contract_number'=>contract.full_contract_number,
          'signing_date'=>contract.signing_date.as_json,
          'begin_date'=>contract.begin_date.to_s,
          'termination_date'=>nil,
          'last_date'=>nil,
          'status'=>contract.status.to_s,
          'updatable'=>true,
          'deletable'=>false,
          'metering_point_operator_name'=>contract.metering_point_operator_name,
          'localpool' => {
            'id'=>contract.localpool.id,
            'type'=>'group_localpool',
            'updated_at'=>contract.localpool.updated_at.as_json,
            'name'=>contract.localpool.name,
            'slug'=>contract.localpool.slug,
            'description'=>contract.localpool.description,
          },
          'tariffs'=>{
            'array'=> contract.tariffs.collect do |tariff|
              {
                'id'=>contract.tariff.id,
                'type'=>'contract_tariff',
                'updated_at'=>nil,
                'name'=>contract.tariff.name,
                'begin_date'=>contract.tariff.begin_date.to_s,
                'last_date'=>nil,
                'energyprice_cents_per_kwh'=>contract.tariff.energyprice_cents_per_kwh,
                'baseprice_cents_per_month'=>contract.tariff.baseprice_cents_per_month,
                'updatable' => false,
                'deletable' => false,
              }
            end
          },
          'payments'=>{
            'array'=> contract.payments.collect do |p|
              {
                'id'=>p.id,
                'type'=>'contract_payment',
                'updated_at'=>nil,
                'begin_date'=>p.begin_date.to_s,
                'end_date'=>p.end_date ? p.end_date.to_s : nil,
                'price_cents'=>p.price_cents,
                'cycle'=>p.cycle,
              }
            end
          },
          'contractor'=>organization_json.dup,
          'customer'=>person_json.dup,
          'customer_bank_account'=>{
            'id'=>contract.customer_bank_account.id,
            'type'=>'bank_account',
            'updated_at'=>contract.customer_bank_account.updated_at.as_json,
            'holder'=>contract.customer_bank_account.holder,
            'bank_name'=>contract.customer_bank_account.bank_name,
            'bic'=>contract.customer_bank_account.bic,
            'iban'=>contract.customer_bank_account.iban,
            'direct_debit'=>contract.customer_bank_account.direct_debit,
            'updatable'=> true,
            'deletable'=> false,
          },
          'contractor_bank_account'=>{
            'id'=>contract.contractor_bank_account.id,
            'type'=>'bank_account',
            'updated_at'=>contract.contractor_bank_account.updated_at.as_json,
            'holder'=>contract.contractor_bank_account.holder,
            'bank_name'=>contract.contractor_bank_account.bank_name,
            'bic'=>contract.contractor_bank_account.bic,
            'iban'=>contract.contractor_bank_account.iban,
            'direct_debit'=>contract.contractor_bank_account.direct_debit,
            'updatable'=> true,
            'deletable'=> false,
          }
        }
      end

      # NOTE picking a sample contract is enough for the 404 and 403 tests

      it '401' do
        GET "/localpools/#{localpool.id}/contracts/#{metering_point_operator_contract.id}", $admin
        expire_admin_session do
          GET "/localpools/#{localpool.id}/contracts/#{metering_point_operator_contract.id}", $admin
          expect(response).to be_session_expired_json(401)

          GET "/localpools/#{localpool.id}/contracts", $admin
          expect(response).to be_session_expired_json(401)
        end
      end

      it '403' do
        GET "/localpools/#{localpool.id}/contracts/#{metering_point_operator_contract.id}", $user
        expect(response).to be_denied_json(403, metering_point_operator_contract)
      end

      it '404' do
        GET "/localpools/#{localpool.id}/contracts/bla-blub", $admin
        expect(response).to be_not_found_json(404, Contract::Localpool)
      end

      [:metering_point_operator, :localpool_power_taker].each do |type|

        context "as #{type}" do

          let(:contract) { send "#{type}_contract" }

          let(:contract_json) { send "#{type}_contract_json" }

          it '200' do
            GET "/localpools/#{localpool.id}/contracts/#{contract.id}", $admin, include: 'localpool,tariffs,payments,contractor:[address, contact:address],customer:[address, contact:address],customer_bank_account,contractor_bank_account,market_location:[register:meter]'
            expect(response).to have_http_status(200)
            expect(json.to_yaml).to eq contract_json.to_yaml
          end
        end
      end
    end

    context 'customer' do

      context 'GET' do

        let('contract') { metering_point_operator_contract }

        let('customer_json') do
          json = person_json.dup
          json.delete('address')
          json
        end

        it '401' do
          GET "/localpools/#{localpool.id}/contracts/#{contract.id}/customer", $admin
          expire_admin_session do
            GET "/localpools/#{localpool.id}/contracts/#{contract.id}/customer", $admin
            expect(response).to be_session_expired_json(401)
          end
        end

        it '200' do
          GET "/localpools/#{localpool.id}/contracts/#{contract.id}/customer", $admin
          expect(response).to have_http_status(200)
          expect(json.to_yaml).to eq(customer_json.to_yaml)
        end
      end
    end

    context 'contractor' do

      context 'GET' do

        let('contract') { metering_point_operator_contract }

        let('contractor_json') do
          json = organization_json.dup
          json.delete('address')
          json.delete('contact')
          json
        end

        it '401' do
          GET "/localpools/#{localpool.id}/contracts/#{contract.id}/contractor", $admin
          expire_admin_session do
            GET "/localpools/#{localpool.id}/contracts/#{contract.id}/contractor", $admin
            expect(response).to be_session_expired_json(401)
          end
        end

        it '200' do
          GET "/localpools/#{localpool.id}/contracts/#{contract.id}/contractor", $admin
          expect(response).to have_http_status(200)
          expect(json.to_yaml).to eq(contractor_json.to_yaml)
        end
      end
    end
  end
end
