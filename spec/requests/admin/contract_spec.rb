require_relative 'test_admin_localpool_roda'
require_relative 'contract_shared'
require_relative '../../support/params_helper.rb'

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
          'created_at'=>contract.created_at.as_json,
          'updated_at'=>contract.updated_at.as_json,
          'full_contract_number'=>contract.full_contract_number,
          'signing_date'=>contract.signing_date.to_s,
          'begin_date'=>contract.begin_date.to_s,
          'termination_date'=>nil,
          'end_date'=>nil,
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
          'confirm_pricing_model' => nil,
          'power_of_attorney' => true,
          'other_contract' => nil,
          'move_in' => nil,
          'authorization' => nil,
          'original_signing_user' => nil,
          'metering_point_operator_name' => nil,
          'allowed_actions' => { 'create_billing' =>
                                 {
                                   'tariffs' => [ 'size cannot be less than 1' ],
                                   'register_meta' => {
                                     'registers' => ['all registers must have a device_setup or change_meter_2 reading or similar']
                                   }
                                 },
                                 'document' => {
                                   'lsn_a2' => {
                                     'current_tariff' => ['must be filled'],
                                     'current_payment' => ['must be filled']
                                   }
                                 },
                               },
          'share_register_with_group' => true,
          'share_register_publicly' => true,
          'energy_consumption_before_kwh_pa' => nil,
          'creditor_identification' => nil,
          'localpool' => {
            'id'=>contract.localpool.id,
            'type'=>'group_localpool',
            'created_at'=>contract.localpool.created_at.as_json,
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
                'created_at'=>contract.tariff.created_at,
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
                'created_at'=>p.created_at,
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
            'created_at'=>contract.customer_bank_account.created_at.as_json,
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
            'created_at'=>contract.contractor_bank_account.created_at.as_json,
            'updated_at'=>contract.contractor_bank_account.updated_at.as_json,
            'holder'=>contract.contractor_bank_account.holder,
            'bank_name'=>contract.contractor_bank_account.bank_name,
            'bic'=>contract.contractor_bank_account.bic,
            'iban'=>contract.contractor_bank_account.iban,
            'direct_debit'=>contract.contractor_bank_account.direct_debit,
            'updatable'=> true,
            'deletable'=> false,
          },
          'register_meta' => {
            'id' => contract.register_meta.id,
            'type' => 'register_meta',
            'created_at'=> contract.register_meta.created_at.as_json,
            'updated_at'=> contract.register_meta.updated_at.as_json,
            'name' => contract.register_meta.register.meta.name,
            'kind'=>'consumption',
            'label'=>'CONSUMPTION',
            'market_location_id' => nil,
            'observer_enabled'=>false,
            'observer_min_threshold'=>nil,
            'observer_max_threshold'=>nil,
            'observer_offline_monitoring'=>false,
            'updatable' => false,
            'deletable' => false,
            'registers' => { 'array' => [{
              'id'=>register.id,
              'type'=>'register_real',
              'created_at'=>register.created_at.as_json,
              'updated_at'=>register.updated_at.as_json,
              'direction'=>'in',
              'last_reading'=>0,
              'meter_id' => meter.id,
              'updatable'=> true,
              'deletable'=> false,
              'createables'=>['readings', 'contracts'],
              'pre_decimal_position'=>6,
              'post_decimal_position'=>1,
              'low_load_ability'=>false,
              'obis'=>register.obis,
              'meter' => {
                'id'=>meter.id,
                'type'=>'meter_real',
                'created_at'=> meter.created_at.as_json,
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
                'metering_location_id' => meter.metering_location_id,
                'legacy_buzznid'=>meter.legacy_buzznid
              }
            }]}
          }
        }
      end

      let(:metering_point_operator_contract_json) do
        contract = metering_point_operator_contract
        {
          'id'=>contract.id,
          'type'=>'contract_metering_point_operator',
          'created_at'=>contract.created_at.as_json,
          'updated_at'=>contract.updated_at.as_json,
          'full_contract_number'=>contract.full_contract_number,
          'signing_date'=>contract.signing_date.as_json,
          'begin_date'=>contract.begin_date.to_s,
          'termination_date'=>nil,
          'end_date'=>nil,
          'last_date'=>nil,
          'status'=>contract.status.to_s,
          'updatable'=>true,
          'deletable'=>false,
          'documentable'=>true,
          'allowed_actions'=> {
            'document' => {
              'metering_point_operator_contract' => true
            },
          },
          'metering_point_operator_name'=>contract.metering_point_operator_name,
          'localpool' => {
            'id'=>contract.localpool.id,
            'type'=>'group_localpool',
            'created_at'=>contract.localpool.created_at.as_json,
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
                'created_at'=>contract.tariff.created_at,
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
                'created_at'=>p.created_at,
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
            'created_at'=>contract.customer_bank_account.created_at.as_json,
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
            'created_at'=>contract.contractor_bank_account.created_at.as_json,
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
        let(:register_meta) { create(:meta) }
        it '200' do
          GET "/localpools/#{localpool.id}/contracts", $admin
          expect(response).to have_http_status(200)
          expect(json['array'].count).to eq(3)
        end

        it '200 with includes and an empty register_meta' do
          old = contract3.register_meta
          contract3.register_meta
          contract3.save
          GET "/localpools/#{localpool.id}/contracts?include=register_meta:[registers],customer:[address,contact:address]", $admin
          expect(response).to have_http_status(200)
          contract3.register_meta = old
          contract3.save
        end

        context 'with contexted tariffs includes' do
          before do
            contract3.tariffs = [ create(:tariff, group: localpool) ]
            contract3.save
          end
          it '200' do
            GET "/localpools/#{localpool.id}/contracts?include=contexted_tariffs:[tariff]", $admin
            expect(response).to have_http_status(200)
            lpc = json["array"].keep_if{|x| x["type"] == "contract_localpool_power_taker"}.first
            expect(lpc["contexted_tariffs"]["array"].count).to eql 1
            contexted_tariff = lpc["contexted_tariffs"]["array"][0]
            expect(contexted_tariff["tariff"]).not_to be_nil
          end
        end
      end

      context 'with a type' do
        let!(:contract1) { metering_point_operator_contract }
        let!(:contract2) { localpool_processing_contract }
        let!(:contract3) { localpool_power_taker_contract }

        [:contract_localpool_processing, :contract_metering_point_operator, :contract_localpool_power_taker].each do |type|
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
            GET "/localpools/#{localpool.id}/contracts/#{contract.id}", $admin, include: 'localpool,tariffs,payments,contractor:[address, contact:address],customer:[address, contact:address],customer_bank_account,contractor_bank_account,register_meta:[registers:meter]'
            expect(response).to have_http_status(200)
            expect(json.to_yaml).to eq contract_json.to_yaml
          end

        end
      end
    end

    context 'PATCH Metering Point Operator' do

      let(:contract) { metering_point_operator_contract }
      let('path') { "/localpools/#{localpool.id}/contracts/#{contract.id}" }

      let('update_begin_date_json') do
        {
          'begin_date' => Date.today + 2,
          'updated_at' => contract.updated_at
        }
      end

      context 'unauthenticated' do

        it '403' do
          PATCH path, nil, update_begin_date_json
          expect(response).to have_http_status(403)
        end

      end

      context 'authenticated' do
        it 'updates the begin date' do
          old_date = contract.begin_date
          PATCH path, $admin, update_begin_date_json
          expect(response).to have_http_status(200)
          contract.reload
          expect(contract.begin_date).not_to eq old_date
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

      let('update_both_tax_numbers_json') do
        {
          'tax_number' => '777388834',
          'sales_tax_number' => 'DE21355324',
          'creditor_identification' => 'DEXXX23XXX',
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

        context 'without a tax_number' do

          before do
            contract.tax_data.destroy
          end

          it 'updates/creates the tax data' do
            expect(contract.tax_data.tax_number).to be nil
            PATCH path, $admin, update_tax_number_json
            expect(response).to have_http_status(200)
            expect(json['tax_number']).to eq '777388834'
            contract.reload
            expect(contract.tax_data.tax_number).to eq '777388834'
          end

        end

        context 'with a tax_number' do

          it 'updates the tax data' do
            expect(contract.tax_data.tax_number).to be nil
            PATCH path, $admin, update_tax_number_json
            expect(response).to have_http_status(200)
            expect(json['tax_number']).to eq '777388834'
            contract.tax_data.reload
            expect(contract.tax_data.tax_number).to eq '777388834'
          end

        end

        context 'with both' do

          it 'updates the tax data' do
            expect(contract.tax_data.tax_number).to be nil
            PATCH path, $admin, update_both_tax_numbers_json
            expect(response).to have_http_status(200)
            expect(json['tax_number']).to eq update_both_tax_numbers_json['tax_number']
            expect(json['sales_tax_number']).to eq update_both_tax_numbers_json['sales_tax_number']
            contract.tax_data.reload
            expect(contract.tax_data.tax_number).to eq update_both_tax_numbers_json['tax_number']
            expect(contract.tax_data.sales_tax_number).to eq update_both_tax_numbers_json['sales_tax_number']
            expect(contract.tax_data.creditor_identification).to eq update_both_tax_numbers_json['creditor_identification']
          end

        end

      end

    end

    context 'PATCH Localpool PowerTaker' do

      let(:contract) { localpool_power_taker_contract }
      let(:path) { "/localpools/#{localpool.id}/contracts/#{contract.id}" }

      let(:today) { Date.today }
      let(:update_signing_date_json) do
        {
          'signing_date' => today.to_s,
          'updated_at' => contract.updated_at
        }
      end

      context 'unauthenticated' do

        it '403' do
          PATCH path, nil, update_signing_date_json
          expect(response).to have_http_status(403)
        end

      end

      context 'authenticated' do
        it 'updates the signing date' do
          old_date = contract.signing_date
          PATCH path, $admin, update_signing_date_json
          expect(response).to have_http_status(200)
          expect(json['signing_date']).to eq update_signing_date_json['signing_date']
          contract.reload
          expect(contract.signing_date.as_json).not_to eq old_date
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

    context 'POST contract' do

      # we need a clean pool without any contracts
      let(:person) { create(:person, :with_bank_account) }
      let(:localpool) { create(:group, :localpool, :with_address, owner: person) }

      let('path') { "/localpools/#{localpool.id}/contracts" }

      context 'authenticated' do

        context 'localpool metering point operator' do

          let('missing_everything_json') do
            {
              'type' => 'contract_metering_point_operator',
            }
          end

          let('begin_date_json') do
            {
              'begin_date' => Date.today.to_s
            }
          end

          let('with_begin_date_json') do
            missing_everything_json.merge(begin_date_json)
          end

          context 'invalid data' do

            it 'creates a metering point operator contract' do
              POST path, $admin, missing_everything_json
              expect(response).to have_http_status(422)
              expect(json['begin_date']).to eq [ "is missing" ]
            end

          end

          context 'valid data' do

            it 'creates a metering point operator contract' do
              POST path, $admin, with_begin_date_json
              expect(response).to have_http_status(201)
              expect(json['begin_date']).to eq begin_date_json['begin_date']
            end

            it 'does not create two metering point operator contract' do
              POST path, $admin, with_begin_date_json
              expect(response).to have_http_status(201)
              POST path, $admin, with_begin_date_json
              expect(response).to have_http_status(422)
              expect(json['only_active_contract']).to eql [ "another contract is already active" ]

            end

          end

        end

        context 'localpool processing' do

          let('missing_everything_json') do
            {
              'type' => 'contract_localpool_processing',
            }
          end

          let('begin_date_json') {{'begin_date' => Date.today.to_s}}
          let('tax_number_json') {{'tax_number' => '777888999'}}
          let('sales_tax_number_json') {{'sales_tax_number' => 'DE777888999'}}

          let('missing_begin_date_json') do
            missing_everything_json.merge(tax_number_json)
          end

          let('valid_localpool_processing') do
            missing_everything_json.merge(tax_number_json).merge(begin_date_json)
          end

          context 'invalid data' do

            it 'fails with 422 for incomplete data: everything' do
              POST path, $admin, missing_everything_json
              expect(response).to have_http_status(422)
              expect(json['begin_date']).to eq ['is missing']
            end

          end

          context 'valid data' do

            context 'tax number' do

              it 'creates a new localpool processing contract' do
                POST path, $admin, valid_localpool_processing
                expect(response).to have_http_status(201)
                expect(json['tax_number']).to eq valid_localpool_processing['tax_number']
              end

            end

            context 'sales tax number' do

              it 'creates a new localpool processing contract' do
                POST path, $admin, valid_localpool_processing
                expect(response).to have_http_status(201)
                expect(json['sales_tax_number']).to eq valid_localpool_processing['sales_tax_number']
              end

            end

            it 'fails for two localpool processing contracts' do
              POST path, $admin, valid_localpool_processing
              expect(response).to have_http_status(201)
              POST path, $admin, valid_localpool_processing
              expect(response).to have_http_status(422)
            end

          end

        end

        context 'powertaker' do

          let('base_request_json') do
            {
              'type' => 'contract_localpool_power_taker',
            }
          end

          let!(:localpool_processing_contract) do
            create(:contract, :localpool_processing, localpool: localpool)
          end

          context 'invalid data' do

            it 'fails with 422 for incomplete data: everything' do
              POST path, $admin, base_request_json
              expect(response).to have_http_status(422)
            end

          end

          context 'with create organization' do
            let(:address) { build(:address) }

            let(:person) do
              build(:person, :with_bank_account, address: address)
            end

            let(:organization) do
              build(:organization, :with_bank_account,
                    address: address,
                    contact: person,
                    legal_representation: person)
            end

            let(:address_json) do
              build_address_json(address)
            end

            let(:person_json) do
              build_person_json(person, address_json)
            end

            let(:legal_representation_json) do
              build_person_json(person, address_json)
            end

            let(:organization_json) do
              build_organization_json(organization: organization,
                                      address_json: address_json,
                                      contact_json: person_json,
                                      legal_representation_json: legal_representation_json)
            end

            let(:create_org_request_json) do
              base_request_json.merge(customer: organization_json.merge('type' => 'organization'),
                                      begin_date: Date.today.as_json,
                                      share_register_with_group: true,
                                      share_register_publicly: true,
                                      register_meta: { name: 'Secret Room', label: 'CONSUMPTION'})
            end

            context 'valid data' do

              it 'creates the contract and creates the powertaker' do
                POST path, $admin, create_org_request_json
                expect(response).to have_http_status(201)
              end

            end

          end

          context 'with create person' do
            let(:power_taker_person) { build(:person) }

            let(:power_taker_person_address_json) do
              build_address_json(power_taker_person.address)
            end

            let(:power_taker_person_json) do
              build_person_json(power_taker_person, power_taker_person_address_json)
            end

            let(:create_person_request_json) do
              base_request_json.merge(customer: power_taker_person_json.merge('type' => 'person'),
                                      begin_date: Date.today.as_json,
                                      share_register_with_group: true,
                                      share_register_publicly: true,
                                      register_meta: { name: 'Secret Room', label: 'CONSUMPTION'})
            end

            context 'valid data' do

              it 'creates the contract and creates the powertaker' do
                POST path, $admin, create_person_request_json
                expect(response).to have_http_status(201)
              end

            end

          end

          context 'with assignment' do
            let(:power_taker_person) { create(:person) }
            let(:power_taker_org) { create(:organization) }

            let(:assign_request_person_json) do
              base_request_json.merge(customer: { id: power_taker_person.id, type: 'person' },
                                      begin_date: Date.today.as_json,
                                      share_register_with_group: true,
                                      share_register_publicly: true,
                                      register_meta: { name: 'Secret Room', label: 'CONSUMPTION'})
            end

            let(:invalid_assign_request_person_json) do
              base_request_json.merge(customer: { id: 13371337, type: 'person' },
                                      begin_date: Date.today.as_json,
                                      share_register_with_group: true,
                                      share_register_publicly: true,
                                      register_meta: { name: 'Secret Room', label: 'CONSUMPTION'})
            end

            let(:assign_request_org_json) do
              base_request_json.merge(customer: { id: power_taker_org.id, type: 'organization' },
                                      begin_date: Date.today.as_json,
                                      share_register_with_group: true,
                                      share_register_publicly: true,
                                      register_meta: { name: 'Secret Room', label: 'CONSUMPTION'})
            end

            context 'valid data' do

              it 'creates the contract and assigns the person as the powertaker' do
                POST path, $admin, assign_request_person_json
                expect(response).to have_http_status(201)
                created_contract = Contract::LocalpoolPowerTaker.find(json['id'])
                expect(created_contract).not_to be_nil
                expect(created_contract.customer.id).to eq power_taker_person.id
                expect(created_contract.contractor.id).to eq localpool.owner.id
              end

              it 'creates the contract and assigns the organization as the powertaker' do
                POST path, $admin, assign_request_org_json
                expect(response).to have_http_status(201)
                created_contract = Contract::LocalpoolPowerTaker.find(json['id'])
                expect(created_contract).not_to be_nil
                expect(created_contract.customer.id).to eq power_taker_org.id
                expect(created_contract.contractor.id).to eq localpool.owner.id
              end

            end

            context 'invalid data' do

              it 'fails with 422 for invalid data: strange customer type' do
                POST path, $admin, base_request_json.merge(customer: { id: 1337, type: 'hokuspokus'})
                expect(response).to have_http_status(422)
              end

              it 'fails with 422 for invalid data: invalid id' do
                POST path, $admin, invalid_assign_request_person_json
                expect(response).to have_http_status(422)
              end

            end

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

    context 'tariffs' do

      let(:today) do
        Date.today
      end

      let(:contract) do
        localpool_processing_contract
        create(:contract, :localpool_powertaker,
               begin_date: today,
               signing_date: today,
               customer: person,
               contractor: Organization::Market.buzzn,
               localpool: localpool)
      end

      let(:tariff_1) do
        create(:tariff, group: localpool, begin_date: today)
      end

      let(:tariff_2) do
        create(:tariff, group: localpool, begin_date: today+30)
      end

      let(:tariff_3) do
        create(:tariff, group: localpool, begin_date: today+32)
      end

      let(:tariff_4) do
        create(:tariff, group: localpool, begin_date: today)
      end

      let(:path) { "/localpools/#{localpool.id}/contracts/#{contract.id}/tariffs" }

      context 'assign' do

        let(:update_tariffs_json) do
          {
            'updated_at' => contract.updated_at,
            'tariff_ids' => [tariff_1.id, tariff_2.id]
          }
        end

        context 'unauthenticated' do

          it '403' do
            PATCH path, nil, update_tariffs_json
            expect(response).to have_http_status(403)
          end

        end

        context 'authenticated' do

          it 'updates the tariffs' do
            PATCH path, $admin, update_tariffs_json
            expect(response).to have_http_status(200)
          end

        end

      end

      context 'request' do
        before do
          contract.tariffs = [ tariff_1, tariff_2, tariff_3, tariff_4 ]
          contract.save
        end

        context 'unauthenticated' do
          it 'is denied' do
            GET path
            expect(response).to have_http_status(403)
          end
        end

        context 'authenticated' do
          it 'fetches' do
            GET path, $admin
            expect(response).to have_http_status(200)
            expect(json["array"].count).to eql 4
          end
        end
      end

    end

    context 'document' do

      context 'generate' do

        [:localpool_processing_contract, :metering_point_operator_contract].each do |contract|

          context contract.to_s do

            let(:path) do
              "/localpools/#{localpool.id}/contracts/#{send(contract).id}/documents/generate"
            end

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

              context 'valid params' do

                let(:params) do
                  { template: send(contract).pdf_generators.first.name.split("::").last.underscore }
                end

                it '201' do
                  POST path, $admin, params
                  expect(response).to have_http_status(201)
                end
              end

              context 'invalid params' do

                context 'missing' do

                  let(:params) do
                    {}
                  end

                  it '422' do
                    POST path, $admin, params
                    expect(response).to have_http_status(422)
                  end

                end

                context 'wrong' do

                  let(:params) do
                    { template: 'haxhax' }
                  end

                  it '422' do
                    POST path, $admin, params
                    expect(response).to have_http_status(422)
                  end

                end

              end

            end
          end
        end
      end
    end
  end
end
