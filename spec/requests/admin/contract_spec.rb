require_relative 'test_admin_localpool_roda'
require_relative 'contract_shared'

describe Admin::LocalpoolRoda, :request_helper do

  def app
    TestAdminLocalpoolRoda # this defines the active application for this test
  end

  context 'contracts' do
    include_context 'contract entities'

    context 'GET' do
      let(:localpool_power_taker_contract_json) do
        contract = localpool_power_taker_contract
        register = contract.register_meta.register
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
          'documentable'=>true,
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
          'contractor'=>organization_json.dup,
          'customer'=>person2_json.dup,
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
            'id' => contract.register_meta.id,
            'type' => 'market_location',
            'updated_at'=> contract.register_meta.updated_at.as_json,
            'name' => contract.register_meta.register.meta.name,
            'kind' => 'consumption',
            'market_location_id' => nil,
            'updatable' => false,
            'deletable' => false,
            'register' => {
              'id'=>register.id,
              'type'=>'register_real',
              'updated_at'=>register.updated_at.as_json,
              'label'=>'CONSUMPTION',
              'direction'=>'in',
              'last_reading'=>0,
              'observer_min_threshold'=>nil,
              'observer_max_threshold'=>nil,
              'observer_enabled'=>nil,
              'observer_offline_monitoring'=>nil,
              'meter_id' => meter.id,
              'updatable'=> true,
              'deletable'=> false,
              'createables'=>['readings', 'contracts'],
              'pre_decimal_position'=>6,
              'post_decimal_position'=>1,
              'low_load_ability'=>false,
              'metering_point_id'=>register.meter.metering_location&.metering_location_id,    'obis'=>register.obis,
              'meter' => {
                'id'=>meter.id,
                'type'=>'meter_real',
                'updated_at'=> meter.updated_at.as_json,
                'product_serialnumber'=>meter.product_serialnumber,
                'sequence_number' => meter.sequence_number,
                'datasource'=>meter.datasource.to_s,
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
          'documentable'=>true,
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
          'contractor'=>buzzn_json,
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
        expect(response).to have_http_status(403)
      end

      it '404' do
        GET "/localpools/#{localpool.id}/contracts/bla-blub", $admin
        expect(response).to have_http_status(404)
      end

      context 'without a type' do
        let!(:contract1) { metering_point_operator_contract }
        let!(:contract2) { localpool_processing_contract }
        let!(:contract3) { localpool_power_taker_contract }

        it '200' do
          GET "/localpools/#{localpool.id}/contracts", $admin
          expect(response).to have_http_status(200)
          expect(json['array'].count).to eq(3)
        end
      end

      context 'with a type' do
        let!(:contract1) { metering_point_operator_contract }
        let!(:contract2) { localpool_processing_contract }
        let!(:contract3) { localpool_power_taker_contract }

        [:contract_localpool_processing, :contract_metering_point_operator, :contract_power_taker].each do |type|
          it "200 for #{type}" do
            GET "/localpools/#{localpool.id}/contracts", $admin, 'type' => type.to_s
            expect(response).to have_http_status(200)
            expect(json['array'].count).to eq(1)
            expect(json['array'].first['type']).to eq(type.to_s)
          end
        end
      end

      [:metering_point_operator, :localpool_power_taker].each do |type|

        context "as #{type}" do

          let(:contract) { send "#{type}_contract" }

          let(:contract_json) { send "#{type}_contract_json" }

          it "200 for #{type}" do
            GET "/localpools/#{localpool.id}/contracts/#{contract.id}", $admin, include: 'localpool,tariffs,payments,contractor:[address, contact:address],customer:[address, contact:address],customer_bank_account,contractor_bank_account,market_location:[register:meter]'
            expect(response).to have_http_status(200)
            expect(json.to_yaml).to eq contract_json.to_yaml
          end

        end
      end
    end

    context 'PATCH Localpool Processing' do
      let(:contract) { localpool_processing_contract }
      let('path') { "/localpools/#{localpool.id}/contracts/#{contract.id}" }

      let('update_tax_number_json') do
        {
          'tax_number' => '777388834',
          'updated_at' => contract.updated_at
        }
      end

      context 'unauthenticated' do

        it '403' do
          PATCH path, nil, update_tax_number_json
          expect(response).to have_http_status(403)
        end

      end

      context 'authenticated' do
        it 'updates the tax data' do
          expect(contract.tax_data.tax_number).to be nil
          PATCH path, $admin, update_tax_number_json
          expect(response).to have_http_status(200)
          expect(json['tax_number']).to eq '777388834'
          contract.tax_data.reload
          expect(contract.tax_data.tax_number).to eq '777388834'
        end
      end

    end

    context 'POST contract' do

      let('path') { "/localpools/#{localpool.id}/contracts" }

      let('invalid_type_json') do
        {
          'type' => 'contract_with_the_devil'
        }
      end

      let('missing_type_json') do
        {
          'foo' => 'somedata'
        }
      end

      context 'unauthenticated' do

        it '403' do
          POST path
          expect(response).to have_http_status(403)
        end

      end

      context 'authenticated' do

        it '400 for an invalid type' do
          POST path, $admin, invalid_type_json
          expect(response).to have_http_status(400)
        end

        it '400 for an missing type' do
          POST path, $admin, missing_type_json
          expect(response).to have_http_status(400)
        end

      end

    end

    context 'POST Localpool Processing' do

      # we need a clean pool without any contracts
      let(:person) { create(:person, :with_bank_account) }
      let(:localpool) { create(:group, :localpool, :with_address, owner: person) }

      let('path') { "/localpools/#{localpool.id}/contracts" }

      let('missing_everything_json') do
        {
          'type' => 'contract_localpool_processing',
        }
      end

      let('signing_date_json') {{'signing_date' => Date.today.to_s}}
      let('tax_number_json') {{'tax_number' => '777888999'}}

      let('missing_tax_number_json') do
        missing_everything_json.merge(signing_date_json)
      end

      let('missing_signing_date_json') do
        missing_everything_json.merge(tax_number_json)
      end

      let('valid_localpool_processing') do
        missing_everything_json.merge(tax_number_json).merge(signing_date_json)
      end

      context 'authenticated' do

        context 'invalid data' do

          it 'fails with 422 for incomplete data: everything' do
            POST path, $admin, missing_everything_json
            expect(response).to have_http_status(422)
            expect(json['signing_date']).to eq ['is missing']
            expect(json['tax_number']).to eq ['is missing']
          end

          it 'fails with 422 for incomplete data: tax_number' do
            POST path, $admin, missing_tax_number_json
            expect(response).to have_http_status(422)
            expect(json['tax_number']).to eq ['is missing']
          end

          it 'fails with 422 for incomplete data: signing_date' do
            POST path, $admin, missing_signing_date_json
            expect(response).to have_http_status(422)
            expect(json['signing_date']).to eq ['is missing']
          end

        end

        context 'valid date' do

          it 'creates a new localpool processing contract' do
            POST path, $admin, valid_localpool_processing
            expect(response).to have_http_status(201)
            expect(json['tax_number']).to eq valid_localpool_processing['tax_number']
          end

          it 'fails for two localpool processing contracts' do
            POST path, $admin, valid_localpool_processing
            expect(response).to have_http_status(201)
            POST path, $admin, valid_localpool_processing
            expect(response).to have_http_status(422)
          end

        end

      end

    end

    context 'customer' do

      context 'GET' do

        let('contract') { metering_point_operator_contract }

        let('customer_json') do
          json = organization_json.dup
          json.delete('address')
          json.delete('contact')
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

        let(:contractor_json) do
          contractor_json = buzzn_json.dup
          contractor_json.delete('address')
          contractor_json
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

    context 'document' do

      context 'generate' do
        let('contract') { localpool_processing_contract }
        let('path') { "/localpools/#{localpool.id}/contracts/#{contract.id}/documents/generate" }

        context 'unauthenticated' do
          it '403' do
            POST path
            expect(response).to have_http_status(403)
          end
        end

        context 'authenticated' do

          # we only want POSTs, change that to 405?
          it '405' do
            GET path, $admin
            expect(response).to have_http_status(405)

            PATCH path, $admin
            expect(response).to have_http_status(405)

            PUT path, $admin
            expect(response).to have_http_status(405)

            DELETE path, $admin
            expect(response).to have_http_status(405)
          end

          it '201' do
            POST path, $admin
            expect(response).to have_http_status(201)
          end

        end

      end

    end

  end
end
