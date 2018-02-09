require_relative 'test_admin_localpool_roda'
describe Admin::LocalpoolRoda do

  def app
    TestAdminLocalpoolRoda # this defines the active application for this test
  end

  def serialized_bank_account(account)
    if account.present?
      {
        'id'                    => account.id,
        'type'                  => 'bank_account',
        'updated_at'            => account.updated_at.as_json,
        'holder'                => account.holder,
        'bank_name'             => account.bank_name,
        'bic'                   => account.bic,
        'iban'                  => account.iban,
        'direct_debit'          => account.direct_debit,
        'updatable'             => false,
        'deletable'             => false
      }
    else
      nil
    end
  end

  def serialized_incompleteness(localpool)
    json = {
      'owner' => ['must be filled'],
      'grid_feeding_register' => ['must be filled'],
      'grid_consumption_register' => ['must be filled'],
      'distribution_system_operator' => ['must be filled'],
      'transmission_system_operator' => ['must be filled'],
      'electricity_supplier' => ['must be filled']
    }
    if localpool
      unless localpool.bank_account
        json['bank_account'] = ['must be filled']
      end
      unless localpool.address
        json['address'] = ['must be filled']
      end
      case localpool.owner
      when Organization
        json['owner'] = {}
        unless localpool.owner.contact
          json['owner']['contact'] = ['must be filled']
        end
        unless localpool.owner.address
          json['owner']['address'] = ['must be filled']
        end
        json.delete('owner') if json['owner'].empty?
      when Person
        json.delete('owner')
      end
    else
      json['bank_account'] = ['must be filled']
      json['address'] = ['must be filled']
    end
    json
  end

  entity(:manager) { create(:person) }
  entity!(:localpool) do
    localpool = create(:localpool)
    manager.add_role(Role::GROUP_ADMIN, localpool)
    c = create(:contract, :localpool_powertaker, localpool: localpool)
    c.register.update(label: :production_pv)
    c = create(:contract, :localpool_powertaker, localpool: localpool)
    c.register.update(label: :production_pv)
    create(:contract, :localpool_processing, localpool: localpool)
    create(:contract, :metering_point_operator, localpool: localpool)
    localpool.contracts.each do |c|
      c.customer.update(customer_number: CustomerNumber.create)
    end
    create(:contract, :localpool_third_party, localpool: localpool)
    localpool.meters.each { |meter| meter.update(group: localpool) }
    $user.person.reload.add_role(Role::GROUP_MEMBER, localpool)
    localpool
  end

  entity(:localpool_no_contracts) do
    create(:localpool,
           address: create(:address),
           bank_account: create(:bank_account)
    )
  end

  let(:empty_json) { [] }

  let(:localpools_json) do
    Group::Localpool.all.collect do |localpool|
      {
        'id'=>localpool.id,
        'type'=>'group_localpool',
        'updated_at'=>localpool.updated_at.as_json,
        'name'=>localpool.name,
        'slug'=>localpool.slug,
        'description'=>localpool.description,
        'start_date' => localpool.start_date.as_json,
        'show_object' => localpool.show_object,
        'show_production' => localpool.show_production,
        'show_energy' => localpool.show_energy,
        'show_contact' => localpool.show_contact,
        'show_display_app' => localpool.show_display_app,
        'updatable'=>true,
        'deletable'=>true,
        'incompleteness' => serialized_incompleteness(localpool),
        'bank_account' => serialized_bank_account(localpool.bank_account),
        'power_sources' => (localpool.registers.empty? ? [] : ['pv']),
        'display_app_url' => (localpool.show_display_app ? "https://display.buzzn.io/#{localpool.slug}" : nil)
      }
    end
  end

  let(:localpool_json) do
    {
      'id'=>localpool_no_contracts.id,
      'type'=>'group_localpool',
      'updated_at'=>localpool_no_contracts.updated_at.as_json,
      'name'=>localpool_no_contracts.name,
      'slug'=>localpool_no_contracts.slug,
      'description'=>localpool_no_contracts.description,
      'start_date' => localpool_no_contracts.start_date.as_json,
      'show_object' => nil,
      'show_production' => nil,
      'show_energy' => nil,
      'show_contact' => nil,
      'show_display_app' => nil,
      'updatable'=>true,
      'deletable'=>true,
      'incompleteness' => serialized_incompleteness(localpool_no_contracts),
      'bank_account' => serialized_bank_account(localpool_no_contracts.bank_account),
      'power_sources' => [],
      'display_app_url' => nil,
      'meters'=>{
        'array'=> localpool_no_contracts.meters.collect do |meter|
          {
            'id'=>meter.id,
            'type'=>'meter_virtual',
            'updated_at'=>meter.updated_at.as_json,
            'product_name'=>meter.product_name,
            'product_serialnumber'=>meter.product_serialnumber,
            'sequence_number' => meter.sequence_number,
            'updatable'=>true,
            'deletable'=>true
          }
        end
      },
      'address' => {
        'id'=>localpool_no_contracts.address.id,
        'type'=>'address',
        'updated_at'=>localpool_no_contracts.address.updated_at.as_json,
        'street'=>localpool_no_contracts.address.street,
        'city'=>localpool_no_contracts.address.city,
        'zip'=>localpool_no_contracts.address.zip,
        'country'=>localpool_no_contracts.address.attributes['country'],
        'updatable'=>true,
        'deletable'=>false
      }
    }
  end

  context 'GET' do

    it '401' do
      GET "/test/#{localpool.id}", $admin
      expire_admin_session do
        GET "/test/#{localpool.id}", $admin
        expect(response).to be_session_expired_json(401)

        GET '/test', $admin
        expect(response).to be_session_expired_json(401)
      end
    end

    it '403' do
      GET "/test/#{localpool.id}", $other
      expect(response).to be_denied_json(403, localpool, user: $other)
    end

    it '404' do
      GET '/test/bla-blub', $admin
      expect(response).to be_not_found_json(404, Group::Localpool)
    end

    it '200' do
      GET "/test/#{localpool_no_contracts.id}", $admin, include: 'meters, address'
      expect(response).to have_http_status(200)
      expect(json.to_yaml).to eq localpool_json.to_yaml
    end

    it '200 all' do
      GET '/test'
      expect(response).to have_http_status(200)
      expect(json['array']).to eq empty_json

      GET '/test?include=', $admin
      expect(response).to have_http_status(200)
      expect(json.keys).to match_array ['array', 'createable']
      expect(json['createable']).to eq true
      expect(sort(json['array'])).to eq sort(localpools_json)
    end
  end

  context 'POST' do

    let(:wrong_json) do
      {
        'errors'=>[
          {'parameter'=>'name',
           'detail'=>'size cannot be greater than 64'},
          {'parameter'=>'description',
           'detail'=>'size cannot be greater than 256'},
          {'parameter' => 'start_date',
           'detail' => 'must be a date'}
        ]
      }
    end

    it '401' do
      GET '/test', $admin
      expire_admin_session do
        POST '/test', $admin
        expect(response).to be_session_expired_json(401)
      end
    end

    it '403' do
      POST '/test', $user, new_localpool
      expect(response).to be_denied_json(403, Admin::LocalpoolResource, user: $user, prefix: :create)
    end

    it '422' do
      POST '/test', $admin,
           name: 'Some Name' * 10,
           description: 'rain rain go away, come back again another day' * 100,
           start_date: 'today is the best'
      expect(json.to_yaml).to eq wrong_json.to_yaml
      expect(response).to have_http_status(422)
    end

    let(:created_json) do
      {
        'type' => 'group_localpool',
        'name' => 'suPer Duper',
        'slug' => 'super-duper',
        'description' => 'superduper localpool location on the dark side of the moon',
        'start_date' => Date.today.as_json,
        'show_object' => false,
        'show_production' => true,
        'show_energy' => false,
        'show_contact' => true,
        'show_display_app' => true,
        'updatable'=>true,
        'deletable'=>true,
        'incompleteness' => serialized_incompleteness(nil),
        'bank_account' => nil,
        'power_sources' => [],
        'display_app_url' => 'https://display.buzzn.io/super-duper',
      }
    end

    let(:new_localpool) do
      json = created_json.dup
      json.delete('type')
      json.delete('updatable')
      json.delete('deletable')
      json
    end

    it '201' do
      POST '/test', $admin, new_localpool

      expect(response).to have_http_status(201)
      result = json
      id = result.delete('id')
      expect(result.delete('updated_at')).not_to be_nil
      expect(Group::Localpool.find(id)).not_to be_nil
      expect(result.to_yaml).to eq created_json.to_yaml
    end
  end

  context 'PATCH' do

    let(:wrong_json) do
      {
        'errors'=>[
          {'parameter'=>'updated_at',
           'detail'=>'is missing'},
          {'parameter'=>'name',
           'detail'=>'size cannot be greater than 64'},
          {'parameter'=>'description',
           'detail'=>'size cannot be greater than 256'},
          {'parameter' => 'start_date',
           'detail' => 'must be a date'},
          {'parameter' => 'show_object',
           'detail' => 'must be boolean'},
          {'parameter' => 'show_production',
           'detail' => 'must be boolean'},
          {'parameter' => 'show_energy',
           'detail' => 'must be boolean'},
          {'parameter' => 'show_contact',
           'detail' => 'must be boolean'},
          {'parameter' => 'show_display_app',
           'detail' => 'must be boolean'}
        ]
      }
    end

    let(:stale_json) do
      {
        'errors' => [
          {'detail'=>"Group::Localpool: #{localpool.id} was updated at: #{localpool.updated_at}"}]
      }
    end

    let(:updated_json) do
      {
        'id'=>localpool.id,
        'type'=>'group_localpool',
        'name'=>'a b c d',
        'slug' => 'a-b-c',
        'description'=>'none',
        'start_date' => Date.yesterday.as_json,
        'show_object' => true,
        'show_production' => false,
        'show_energy' => true,
        'show_contact' => false,
        'show_display_app' => false,
        'updatable'=>true,
        'deletable'=>true,
        'incompleteness' => serialized_incompleteness(localpool),
        'bank_account' => nil,
        'power_sources' => ['pv'],
        'display_app_url' => nil
      }
    end

    it '401' do
      GET "/test/#{localpool.id}", $admin
      expire_admin_session do
        PATCH "/test/#{localpool.id}", $admin
        expect(response).to be_session_expired_json(401)
      end
    end

    it '404' do
      PATCH '/test/bla-blub', $admin
      expect(response).to be_not_found_json(404, Group::Localpool)
    end

    it '409' do
      PATCH "/test/#{localpool.id}", $admin,
            updated_at: DateTime.now

      expect(response).to have_http_status(409)
      expect(json.to_yaml).to eq stale_json.to_yaml
    end

      it '422' do
        PATCH "/test/#{localpool.id}", $admin,
              name: 'NoName' * 20,
              description: 'something' * 100,
              start_date: 'today is it not',
              show_object: 'maybe',
              show_production: 'nope',
              show_energy: 'yep',
              show_contact: 'not',
              show_display_app: 'later'

        expect(response).to have_http_status(422)
        expect(json.to_yaml).to eq wrong_json.to_yaml
      end

      it '200' do
        old = localpool.updated_at
        PATCH "/test/#{localpool.id}", $admin,
              updated_at: localpool.updated_at,
              name: 'a b c d',
              description: 'none',
              start_date: Date.yesterday.as_json,
              show_object: true,
              show_production: false,
              show_energy: true,
              show_contact: false,
              show_display_app: false

        expect(response).to have_http_status(200)
        localpool.reload
        expect(localpool.name).to eq 'a b c d'
        expect(localpool.description).to eq 'none'
        expect(localpool.start_date).to eq Date.yesterday
        expect(localpool.show_object).to eq true
        expect(localpool.show_production).to eq false
        expect(localpool.show_energy).to eq true
        expect(localpool.show_contact).to eq false
        expect(localpool.show_display_app).to eq false

        result = json
        # TODO fix it: our time setup does not allow
        #expect(result.delete('updated_at')).to be > old.as_json
        expect(Time.parse(result.delete('updated_at'))).to be > old
        expect(result.to_yaml).to eq updated_json.to_yaml
       end
    end

  context 'localpool-processing-contract' do

    let(:expected_json) do
      contract = localpool.localpool_processing_contract
      {
        'id'=>contract.id,
        'type'=>'contract_localpool_processing',
        'updated_at'=>contract.updated_at.as_json,
        'full_contract_number'=>"#{contract.contract_number}/#{contract.contract_number_addition}",
        'signing_date'=>contract.signing_date.to_s,
        'begin_date'=>contract.begin_date.to_s,
        'termination_date'=>nil,
        'last_date'=>nil,
        'status' => contract.status.to_s,
        'updatable'=>true,
        'deletable'=>false,
        'tariffs'=>{
          'array'=> contract.tariffs.collect do |t|
            {
              'id'=>t.id,
              'type'=>'contract_tariff',
              'updated_at'=>t.updated_at.as_json,
              'name'=>t.name,
              'begin_date'=>t.begin_date.to_s,
              'last_date'=>nil,
              'energyprice_cents_per_kwh'=>t.energyprice_cents_per_kwh,
              'baseprice_cents_per_month'=>t.baseprice_cents_per_month,
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
              'last_date'=>nil,
              'price_cents'=>p.price_cents,
              'cycle'=>p.cycle,
            }
          end
        },
        'contractor'=>{
          'id'=>contract.contractor.id,
          'type'=>'organization',
          'updated_at'=>contract.contractor.updated_at.as_json,
          'name'=>contract.contractor.name,
          'phone'=>contract.contractor.phone,
          'fax'=>contract.contractor.fax,
          'website'=>contract.contractor.website,
          'email'=>contract.contractor.email,
          'description'=>contract.contractor.description,
          'customer_number' => nil,
          'updatable'=>true,
          'deletable'=>false
        },
        'customer'=>{
          'id'=>contract.customer.id,
          'type'=>'person',
          'updated_at'=>contract.customer.updated_at.as_json,
          'prefix'=>contract.customer.attributes['prefix'],
          'title'=>contract.customer.title,
          'first_name'=>contract.customer.first_name,
          'last_name'=>contract.customer.last_name,
          'phone'=>contract.customer.phone,
          'fax'=>contract.customer.fax,
          'email'=>contract.customer.email,
          'preferred_language'=>contract.customer.attributes['preferred_language'],
          'image'=>contract.customer.image.medium.url,
          'customer_number' => contract.customer.customer_number.id,
          'updatable'=>true,
          'deletable'=>false
        },
        'customer_bank_account'=> serialized_bank_account(contract.customer_bank_account).merge('updatable' => true),
        'contractor_bank_account'=> serialized_bank_account(contract.contractor_bank_account).merge('updatable' => true)
      }
    end

    context 'GET' do

      it '401' do
        GET "/test/#{localpool.id}/localpool-processing-contract", $admin
        expire_admin_session do
          GET "/test/#{localpool.id}/localpool-processing-contract", $admin
          expect(response).to be_session_expired_json(401)
        end
      end

      it '403' do
        GET "/test/#{localpool.id}/localpool-processing-contract", $user
        expect(response).to be_denied_json(403, Contract::LocalpoolProcessingResource)
      end

      it '404' do
        GET "/test/#{localpool_no_contracts.id}/localpool-processing-contract", $admin
        expect(response).to be_not_found_json(404, Admin::LocalpoolResource,
                                              :localpool_processing_contract)
      end

      it '200' do
        GET "/test/#{localpool.id}/localpool-processing-contract", $admin, include: 'tariffs,payments,contractor,customer,customer_bank_account,contractor_bank_account'
        expect(json.to_yaml).to eq expected_json.to_yaml
        expect(response).to have_http_status(200)

      end
    end
  end

  context 'metering-point-operator-contract' do

    let(:expected_json) do
      contract = localpool.metering_point_operator_contract
      {
        'id'=>contract.id,
        'type'=>'contract_metering_point_operator',
        'updated_at'=>contract.updated_at.as_json,
        'full_contract_number'=>"#{contract.contract_number}/#{contract.contract_number_addition}",
        'signing_date'=>contract.signing_date.to_s,
        'begin_date'=>contract.begin_date.to_s,
        'termination_date'=>nil,
        'last_date'=>nil,
        'status'=>contract.status.to_s,
        'updatable'=>true,
        'deletable'=>false,
        'metering_point_operator_name'=>contract.metering_point_operator_name,
        'tariffs'=> {
          'array'=>contract.tariffs.collect do |tariff|
            {
              'id'=>tariff.id,
              'type'=>'contract_tariff',
              'updated_at'=>contract.tariff.updated_at.as_json,
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
              'last_date'=>p.last_date ? p.last_date.to_s : nil,
              'price_cents'=>p.price_cents,
              'cycle'=>p.cycle,
            }
          end
        },
        'contractor'=>{
          'id'=>contract.contractor.id,
          'type'=>'organization',
          'updated_at'=>contract.contractor.updated_at.as_json,
          'name'=>contract.contractor.name,
          'phone'=>contract.contractor.phone,
          'fax'=>contract.contractor.fax,
          'website'=>contract.contractor.website,
          'email'=>contract.contractor.email,
          'description'=>contract.contractor.description,
          'customer_number' => nil,
          'updatable'=>true,
          'deletable'=>false,
          'address' => nil
        },
        'customer'=>{
          'id'=>contract.customer.id,
          'type'=>'person',
          'updated_at'=>contract.customer.updated_at.as_json,
          'prefix'=>contract.customer.attributes['prefix'],
          'title'=>contract.customer.title,
          'first_name'=>contract.customer.first_name,
          'last_name'=>contract.customer.last_name,
          'phone'=>contract.customer.phone,
          'fax'=>contract.customer.fax,
          'email'=>contract.customer.email,
          'preferred_language'=>contract.customer.attributes['preferred_language'],
          'image'=>contract.customer.image.medium.url,
          'customer_number' => contract.customer.customer_number.id,
          'updatable'=>true,
          'deletable'=>false,
          'address'=>{
            'id'=>contract.customer.address.id,
            'type'=>'address',
            'updated_at'=>contract.customer.address.updated_at.as_json,
            'street'=>contract.customer.address.street,
            'city'=>contract.customer.address.city,
            'zip'=>contract.customer.address.zip,
            'country'=>contract.customer.address.attributes['country'],
            'updatable'=>true,
            'deletable'=>false
          }
        },
        'customer_bank_account'=> serialized_bank_account(contract.customer_bank_account).merge('updatable' => true),
        'contractor_bank_account'=> serialized_bank_account(contract.contractor_bank_account).merge('updatable' => true)
      }
    end

    context 'GET' do

      it '401' do
        GET "/test/#{localpool.id}/metering-point-operator-contract", $admin
        expire_admin_session do
          GET "/test/#{localpool.id}/metering-point-operator-contract", $admin
          expect(response).to be_session_expired_json(401)
        end
      end

      it '403' do
        GET "/test/#{localpool.id}/metering-point-operator-contract", $user
        expect(response).to be_denied_json(403, Contract::MeteringPointOperatorResource)
      end

      it '404' do
        GET "/test/#{localpool_no_contracts.id}/metering-point-operator-contract", $admin
        expect(response).to be_not_found_json(404, Admin::LocalpoolResource,
                                              :metering_point_operator_contract)
      end

      it '200' do
        GET "/test/#{localpool.id}/metering-point-operator-contract", $admin, include: 'tariffs,payments,contractor:address,customer:address,customer_bank_account,contractor_bank_account'
        expect(json.to_yaml).to eq expected_json.to_yaml
        expect(response).to have_http_status(200)
      end
    end
  end

  context 'power-taker-contracts' do

    let(:expected_json) do
      localpool.localpool_power_taker_contracts.collect do |contract|
        json = {
          'id'=>contract.id,
          'type' => 'contract_localpool_power_taker',
          'updated_at'=>contract.updated_at.as_json,
          'full_contract_number'=>"#{contract.contract_number}/#{contract.contract_number_addition}",
          'signing_date'=>contract.signing_date.to_s,
          'begin_date'=>contract.begin_date.to_s,
          'termination_date'=>nil,
          'last_date'=>nil,
          'status' => contract.status.to_s,
          'updatable'=>true,
          'deletable'=>false
        }
        if contract.is_a?(Contract::LocalpoolPowerTaker)
          json.merge!(
            'forecast_kwh_pa'=>contract.forecast_kwh_pa,
            'renewable_energy_law_taxation'=>contract.attributes['renewable_energy_law_taxation'],
            'third_party_billing_number'=>contract.third_party_billing_number,
            'third_party_renter_number'=>contract.third_party_renter_number,
            'old_supplier_name'=>contract.old_supplier_name,
            'old_customer_number'=>contract.old_customer_number,
            'old_account_number'=>contract.old_account_number,
            'mandate_reference' => nil
          )
        else
          json['type'] = 'contract_localpool_third_party'
        end
        json['customer'] =
          if contract.customer
            {
              'id'=>contract.customer.id,
              'type'=>'person',
              'updated_at'=>contract.customer.updated_at.as_json,
              'prefix'=>contract.customer.attributes['prefix'],
              'title'=>contract.customer.title,
              'first_name'=>contract.customer.first_name,
              'last_name'=>contract.customer.last_name,
              'phone'=>contract.customer.phone,
              'fax'=>contract.customer.fax,
              'email'=>contract.customer.email,
              'preferred_language'=>contract.customer.attributes['preferred_language'],
              'image'=>contract.customer.image.medium.url,
              'customer_number' => contract.customer.customer_number.id,
              'updatable'=>true,
              'deletable'=>false,
            }
          end
        json
      end
    end

    context 'GET' do
      it '401' do
        GET "/test/#{localpool.id}/power-taker-contracts", $admin
        expire_admin_session do
          GET "/test/#{localpool.id}/power-taker-contracts", $admin
          expect(response).to be_session_expired_json(401)
        end
      end

      it '200' do
        GET "/test/#{localpool.id}/power-taker-contracts", $user
        expect(json['array'].to_yaml).to eq empty_json.to_yaml
        expect(response).to have_http_status(200)

        GET "/test/#{localpool.id}/power-taker-contracts", $admin, include: :customer
        expect(json['array'].to_yaml).to eq expected_json.to_yaml
        expect(response).to have_http_status(200)
      end
    end
  end

  context 'managers' do

    context 'GET' do

      let(:managers_json) do
        [
          {
            'id'=>manager.id,
            'type'=>'person',
            'updated_at'=>manager.updated_at.as_json,
            'prefix'=>manager.attributes['prefix'],
            'title'=>manager.title,
            'first_name'=>manager.first_name,
            'last_name'=>manager.last_name,
            'phone'=>manager.phone,
            'fax'=>manager.fax,
            'email'=>manager.email,
            'preferred_language'=>manager.attributes['preferred_language'],
            'image'=>manager.image.medium.url,
            'customer_number' => nil,
            'updatable'=>true,
            'deletable'=>true,
            'bank_accounts'=> { 'array'=>[] },
          }
        ]
      end

      it '401' do
        GET "/test/#{localpool.id}/managers", $admin
        expire_admin_session do
          GET "/test/#{localpool.id}/managers", $admin
          expect(response).to be_session_expired_json(401)
        end
      end

      it '200' do
        GET "/test/#{localpool.id}/managers", $admin, include: :bank_accounts

        expect(response).to have_http_status(200)
        expect(json['array'].to_yaml).to eq(managers_json.to_yaml)
      end
    end
  end

end
