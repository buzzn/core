require_relative 'test_admin_localpool_roda'

describe Admin::LocalpoolRoda, :request_helper do

  def app
    TestAdminLocalpoolRoda # this defines the active application for this test
  end

  def serialized_bank_account(account)
    if account.present?
      { 'id'                    => account.id,
        'type'                  => 'bank_account',
        'updated_at'            => account.updated_at.as_json,
        'holder'                => account.holder,
        'bank_name'             => account.bank_name,
        'bic'                   => account.bic,
        'iban'                  => account.iban,
        'direct_debit'          => account.direct_debit,
        'updatable'             => false,
        'deletable'             => false }
    else
      nil
    end
  end

  def serialized_incompleteness(localpool)
    json = { 'owner' => ['must be filled'],
             'grid_feeding_register' => ['must be filled'],
             'grid_consumption_register' => ['must be filled'],
             'distribution_system_operator' => ['must be filled'],
             'transmission_system_operator' => ['must be filled'],
             'electricity_supplier' => ['must be filled'] }
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
        unless localpool.owner.legal_representation
          json['owner']['legal_representation'] = ['must be filled']
        end
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
    localpool = create(:group, :localpool)
    manager.add_role(Role::GROUP_ADMIN, localpool)
    c = create(:contract, :localpool_powertaker, localpool: localpool)
    c.register_meta.register.meta.production_pv!
    c = create(:contract, :localpool_powertaker, localpool: localpool)
    c.register_meta.register.meta.update(label: :production_pv)
    create(:contract, :localpool_processing, localpool: localpool)
    create(:contract, :metering_point_operator, localpool: localpool)
    localpool.contracts.each do |co|
      co.customer.update(customer_number: CustomerNumber.create)
    end
    create(:contract, :localpool_third_party, localpool: localpool)
    localpool.meters.each { |meter| meter.update(group: localpool) }
    $user.person.reload.add_role(Role::GROUP_MEMBER, localpool)
    localpool
  end

  entity(:localpool_no_contracts) do
    create(:group, :localpool,
           address: create(:address),
           bank_account: create(:bank_account)
          )
  end

  let(:empty_json) { [] }

  def serialize(localpool)
    allowed = {
      'create_metering_point_operator_contract' => {},
      'create_localpool_processing_contract' => {},
      'create_billing_cycle' => {}
    }
    unless localpool.address
      allowed['create_metering_point_operator_contract']['address'] = ['must be filled']
    end
    unless localpool.owner
      allowed['create_metering_point_operator_contract']['owner'] = ['must be filled']
      allowed['create_localpool_processing_contract']['owner'] = ['must be filled']
    end
    unless localpool.start_date
      allowed['create_billing_cycle']['start_date'] = ['must be filled']
    end
    if localpool.localpool_processing_contracts.any?
      allowed['create_localpool_processing_contract']['localpool_processing_contract'] = ['cannot be defined']
    end

    allowed = allowed.map do |k,v|
      if v.empty?
        [k, true]
      else
        [k, v]
      end
    end.to_h
    { 'id'=>localpool.id,
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
      'deletable'=>localpool.owner.nil?,
      'createables' => [
        'managers',
        'organizations',
        'localpool_processing_contracts',
        'metering_point_operator_contracts',
        'localpool_power_taker_contracts',
        'registers',
        'persons',
        'tariffs',
        'billing_cycles',
        'devices'
      ],
      'incompleteness' => serialized_incompleteness(localpool),
      'bank_account' => serialized_bank_account(localpool.bank_account),
      'power_sources' => (localpool.registers.empty? ? [] : ['pv']),
      'display_app_url' => (localpool.show_display_app ? "https://display.buzzn.io/#{localpool.slug}" : nil),
      'allowed_actions' => {
        'create_metering_point_operator_contract'=> allowed['create_metering_point_operator_contract'],
        'create_localpool_processing_contract'=> allowed['create_localpool_processing_contract'],
        'create_billing_cycle'=> allowed['create_billing_cycle']
      },
      'next_billing_cycle_begin_date' => localpool.start_date.as_json }
  end

  let(:localpools_json) do
    Group::Localpool.all.collect { |localpool| serialize(localpool) }
  end

  let(:localpool_json) do
    serialize(localpool_no_contracts)
      .merge('billing_cycles' => {
               'next_billing_cycle_begin_date' => localpool_no_contracts.start_date.as_json, 'array' => []
             })
  end

  context 'GET' do

    it '401' do
      GET "/localpools/#{localpool.id}", $admin
      expire_admin_session do
        GET "/localpools/#{localpool.id}", $admin
        expect(response).to be_session_expired_json(401)

        GET '/localpools', $admin
        expect(response).to be_session_expired_json(401)
      end
    end

    it '403' do
      GET "/localpools/#{localpool.id}", $other
      expect(response).to have_http_status(403)
    end

    it '404' do
      GET '/localpools/bla-blub', $admin
      expect(response).to have_http_status(404)
    end

    it '200' do
      GET "/localpools/#{localpool_no_contracts.id}", $admin, include: 'meters, address, billing_cycles'
      expect(response).to have_http_status(200)

      result = json
      expect(result).to has_nested_json(:meters)
      result.delete('meters')
      expect(result).to has_nested_json(:address, :id)
      result.delete('address')

      expect(result.to_yaml).to eq localpool_json.to_yaml
    end

    it '200 all' do
      GET '/localpools?include=', $admin
      expect(response).to have_http_status(200)
      expect(json.keys).to match_array ['array']
      expect(sort(json['array'])).to eq sort(localpools_json)
    end
  end

  context 'POST' do

    let(:wrong_json) do
      {
        'name'=>['size cannot be greater than 64'],
        'description'=>['size cannot be greater than 256'],
        'start_date'=>['must be a date']
      }
    end

    it '401' do
      GET '/localpools', $admin
      expire_admin_session do
        POST '/localpools', $admin
        expect(response).to be_session_expired_json(401)
      end
    end

    it '403' do
      POST '/localpools', $user, new_localpool
      expect(response).to have_http_status(403)
    end

    it '422' do
      POST '/localpools', $admin,
           name: 'Some Name' * 10,
           description: 'rain rain go away, come back again another day' * 100,
           start_date: 'today is the best'
      expect(json.to_yaml).to eq wrong_json.to_yaml
      expect(response).to have_http_status(422)
    end

    let(:created_json) do
      { 'type' => 'group_localpool',
        'name' => '12313213',
        'description' => 'superduper localpool location on the dark side of the moon',
        'start_date' => Date.today.as_json,
        'show_object' => false,
        'show_production' => true,
        'show_energy' => false,
        'show_contact' => true,
        'show_display_app' => true,
        'updatable'=>true,
        'deletable'=>true,
        'createables' => [
          'managers',
          'organizations',
          'localpool_processing_contracts',
          'metering_point_operator_contracts',
          'localpool_power_taker_contracts',
          'registers',
          'persons',
          'tariffs',
          'billing_cycles',
          'devices'
        ],
        'incompleteness' => serialized_incompleteness(nil),
        'bank_account' => nil,
        'power_sources' => [],
        'allowed_actions' => {
          'create_metering_point_operator_contract'=> {
            'address' => ['must be filled'],
            'owner' => ['must be filled']
          },
          'create_localpool_processing_contract' => {
            'owner' => ['must be filled']
          },
          'create_billing_cycle' => true
        },
        'next_billing_cycle_begin_date' => Date.today.as_json }
    end

    let(:new_localpool) do
      json = created_json.dup
      json.delete('type')
      json.delete('updatable')
      json.delete('deletable')
      json
    end

    let(:created_json_missing_start) do
      json = created_json.dup
      json['start_date'] = nil
      json['next_billing_cycle_begin_date'] = nil
      json['allowed_actions']['create_billing_cycle'] = {
        'start_date' => ['must be filled']
      }
      json
    end

    let(:new_localpool_missing_start) do
      json = created_json_missing_start.dup
      json.delete('type')
      json.delete('updatable')
      json.delete('deletable')
      json
    end

    context 'create'
    [[:new_localpool, :created_json], [:new_localpool_missing_start, :created_json_missing_start]].each do |tuple|

      let(:parameter) { send tuple[0]}
      let(:expected) { send tuple[1]}
      it "201 for #{tuple[0]}" do
        POST '/localpools', $admin, parameter

        expect(response).to have_http_status(201)
        result = json
        id = result.delete('id')
        expect(result.delete('updated_at')).not_to be_nil
        expect(Group::Localpool.find(id)).not_to be_nil
        result.delete('slug')
        result.delete('display_app_url')
        expect(result.to_yaml).to eq expected.to_yaml
      end
    end

  end

  context 'PATCH' do

    # make rubocop happy
    let(:wrong_json) do
      {
        'updated_at'=>['is missing'],
        'name'=>['size cannot be greater than 64'],
        'description'=>['size cannot be greater than 256'],
        'start_date'=>['must be a date'],
        'show_object'=>['must be boolean'],
        'show_production'=>['must be boolean'],
        'show_energy'=>['must be boolean'],
        'show_contact'=>['must be boolean'],
        'show_display_app'=>['must be boolean']
      }
    end

    let(:updated_json) do
      { 'id'=>localpool.id,
        'type'=>'group_localpool',
        'name'=>'a b c d',
        'slug' => localpool.slug,
        'description'=>'none',
        'start_date' => Date.yesterday.as_json,
        'show_object' => true,
        'show_production' => false,
        'show_energy' => true,
        'show_contact' => false,
        'show_display_app' => false,
        'updatable'=>true,
        'deletable'=>false,
        'createables' => [
          'managers',
          'organizations',
          'localpool_processing_contracts',
          'metering_point_operator_contracts',
          'localpool_power_taker_contracts',
          'registers',
          'persons',
          'tariffs',
          'billing_cycles',
          'devices'
        ],
        'incompleteness' => serialized_incompleteness(localpool),
        'bank_account' => nil,
        'power_sources' => ['pv'],
        'display_app_url' => nil,
        'allowed_actions' => {
          'create_metering_point_operator_contract'=> {'address' => ['must be filled']},
          'create_localpool_processing_contract'=> {'localpool_processing_contract' => ['cannot be defined']},
          'create_billing_cycle' => true
        },
        'next_billing_cycle_begin_date' => Date.yesterday.as_json }
    end

    it '401' do
      GET "/localpools/#{localpool.id}", $admin
      expire_admin_session do
        PATCH "/localpools/#{localpool.id}", $admin
        expect(response).to be_session_expired_json(401)
      end
    end

    it '404' do
      PATCH '/localpools/bla-blub', $admin
      expect(response).to have_http_status(404)
    end

    it '409' do
      PATCH "/localpools/#{localpool.id}", $admin,
            updated_at: DateTime.now
      expect(response).to have_http_status(409)
    end

    it '422' do
      PATCH "/localpools/#{localpool.id}", $admin,
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
      PATCH "/localpools/#{localpool.id}", $admin,
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

  context 'managers' do

    context 'GET' do

      let(:managers_json) do
        [{ 'id'=>manager.id,
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
           'bank_accounts'=> { 'array'=>[] } }]
      end

      it '401' do
        GET "/localpools/#{localpool.id}/managers", $admin
        expire_admin_session do
          GET "/localpools/#{localpool.id}/managers", $admin
          expect(response).to be_session_expired_json(401)
        end
      end

      it '200' do
        GET "/localpools/#{localpool.id}/managers", $admin, include: :bank_accounts

        expect(response).to have_http_status(200)
        expect(json['array'].to_yaml).to eq(managers_json.to_yaml)
      end
    end
  end

end
