describe Admin::Roda do

  class TestAdminRoda < BaseRoda

    route do |r|
      r.on('test') { r.run Admin::Roda }
      r.run Me::Roda
    end

  end

  def app
    TestAdminRoda # this defines the active application for this test
  end

  entity!(:localpool) { create(:localpool, owner: create(:organization)) }

  entity!(:contract) do
    create(:contract, :localpool_powertaker, localpool: localpool)
  end

  let(:expired_json) do
    {'error' => 'This session has expired, please login again.'}
  end

  context 'persons' do

    context 'GET' do

      let(:person) do
        contract.customer
      end

      let(:expected_persons_json) do
        [
          {
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
            'updatable'=>false,
            'deletable'=>false,
          }
        ]
      end

      let(:expected_persons_with_nested_json) do
        json = expected_persons_json.first.dup
        register = contract.market_location.register
        contract_json = {
          'id'=>contract.id,
          'type'=>'contract_localpool_power_taker',
          'updated_at'=>contract.updated_at.as_json,
          'full_contract_number'=>contract.full_contract_number,
          'signing_date'=>contract.signing_date.to_s,
          'begin_date'=>contract.begin_date.to_s,
          'termination_date'=>nil,
          'last_date'=>nil,
          'status'=>contract.status.to_s,
          'updatable'=>false,
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
            'id'=>localpool.id,
            'type'=>'group_localpool',
            'updated_at'=>localpool.updated_at.as_json,
            'name'=>localpool.name,
            'slug'=>localpool.slug,
            'description'=>localpool.description,
          },
          'market_location' => {
            'id' => contract.market_location.id,
            'type' => 'market_location',
            'updated_at'=> contract.market_location.updated_at.as_json,
            'name' => contract.market_location.name,
            'kind' => 'consumption',
            'market_location_id' => nil,
            'updatable' => false,
            'deletable' => false,
            'register' => {
              'id'=>register.id,
              'type'=>'register_real',
              'updated_at'=>register.updated_at.as_json,
              'label'=>register.attributes['label'],
              'direction'=>register.attributes['direction'],
              'last_reading'=> 0,
              'observer_min_threshold'=>register.observer_min_threshold,
              'observer_max_threshold'=>register.observer_max_threshold,
              'observer_enabled'=>register.observer_enabled,
              'observer_offline_monitoring'=>register.observer_offline_monitoring,
              'meter_id' => register.meter_id,
              'updatable'=> false,
              'deletable'=> false,
              'createables'=>['readings'],
              'pre_decimal_position'=>register.pre_decimal_position,
              'post_decimal_position'=>register.post_decimal_position,
              'low_load_ability'=>register.low_load_ability,
              'metering_point_id'=>register.metering_point_id,
              'obis'=>register.obis
            }
          }
        }
        json['contracts'] = { 'array' => [contract_json] }
        [json]
      end

      let(:expected_person_json) do
        json = expected_persons_with_nested_json.first.dup
        contracts = json.delete('contracts')
        json['address'] = {
          'id'=>person.address.id,
          'type'=>'address',
          'updated_at'=>person.address.updated_at.as_json,
          'street'=>person.address.street,
          'city'=>person.address.city,
          'zip'=>person.address.zip,
          'country'=>person.address.attributes['country'],
          'updatable'=>false,
          'deletable'=>false
        }
        json['contracts'] = contracts
        json
      end

      it '200 all' do
        GET '/test/persons', $admin

        expect(response).to have_http_status(200)
        expect(json['array'].to_yaml).to eq(expected_persons_json.to_yaml)

        GET '/test/persons', $admin, include: 'contracts:[localpool,market_location:register]'

        expect(response).to have_http_status(200)
        expect(json['array'].to_yaml).to eq(expected_persons_with_nested_json.to_yaml)
      end

      it '200' do
        GET "/test/persons/#{person.id}", $admin, include: 'address,contracts:[localpool,market_location:register]'

        expect(response).to have_http_status(200)
        expect(json.to_yaml).to eq(expected_person_json.to_yaml)
      end

      it '401' do
        GET '/test/persons', $admin

        GET '/test/organizations', nil
        expect(response).to have_http_status(401)

        Timecop.travel(Time.now + 30 * 60) do
          GET '/test/persons', $admin

          expect(response).to have_http_status(401)
          expect(json).to eq(expired_json)
        end
      end
    end
  end

  context 'organizations' do

    context 'GET' do

      let(:organization) do
        contract.contractor
      end

      let(:organizations_json) do
        [
          {
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
            'updatable'=>false,
            'deletable'=>false,
          }
        ]
      end

      it '200' do
        GET '/test/organizations', $admin

        expect(response).to have_http_status(200)
        expect(json['array'].to_yaml).to eq(organizations_json.to_yaml)
      end

      it '401' do
        GET '/test/organizations', $admin

        GET '/test/organizations', nil
        expect(response).to have_http_status(401)

        Timecop.travel(Time.now + 30 * 60) do
          GET '/test/organizations', $admin

          expect(response).to have_http_status(401)
          expect(json).to eq(expired_json)
        end
      end
    end
  end

  context 'localpools' do

    context 'GET' do
      it '401' do
        GET '/test/localpools', $admin

        GET '/test/localpools', nil
        expect(response).to have_http_status(401)

        Timecop.travel(Time.now + 30 * 60) do
          GET '/test/localpools', $admin

          expect(response).to have_http_status(401)
          expect(json).to eq(expired_json)
        end
      end
    end
  end
end
