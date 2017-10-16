describe Admin::LocalpoolResource do

  entity(:admin) { Fabricate(:admin) }
  entity!(:localpool) { Fabricate(:localpool) }

  let(:base_attributes) { ['id', 'type', 'updated_at',
                           'name',
                           'description',
                           'slug',
                           'start_date',
                           'updatable',
                           'deletable',
                           'incompleteness' ] }

  entity!(:pools) { Admin::LocalpoolResource.all(admin) }

  describe 'scores' do

    entity(:group) { localpool }

    [:day, :month, :year].each do |interval|
      describe interval do

        before { Score.delete_all }

        [:sufficiency, :closeness, :autarchy, :fitting].each do |type|

          describe type do

            let!(:out_of_range) do
                begin
                  interval_information = Buzzn::ScoreCalculator.new(nil, Time.new(123123)).send(:interval, interval)
                  Score.create(mode: type, interval: interval_information[0], interval_beginning: interval_information[1], interval_end: interval_information[2], value: (rand * 10).to_i, scoreable_type: Group::Base, scoreable_id: group.id)
                end
            end

            let!(:in_range) do
                begin
                  interval_information = Buzzn::ScoreCalculator.new(nil, Time.current.yesterday).send(:interval, interval)
                  Score.create(mode: type, interval: interval_information[0], interval_beginning: interval_information[1], interval_end: interval_information[2], value: (rand * 10).to_i, scoreable_type: Group::Base, scoreable_id: group.id)
                end
            end

            let(:attributes) { ['mode', 'interval', 'interval_beginning', 'interval_end', 'value'] }
            it 'now' do
              result = pools.retrieve(group.id)
                         .scores(interval: interval, mode: type)
              expect(result.size).to eq 1
              first = ScoreResource.send(:new, result.first)
              expect(first.to_hash.keys).to match_array attributes
            end

            it 'yesterday' do
              result = pools.retrieve(group.id)
                         .scores(interval: interval,
                                 mode: type,
                                 timestamp: Time.current.yesterday)
              expect(result.size).to eq 1
              first = ScoreResource.send(:new, result.first)
              expect(first.to_hash.keys).to match_array attributes
            end

          end
        end
      end
    end

  end

  it 'retrieve all - ids + types' do
    expected = Group::Localpool.all.collect do |l|
      ['group_localpool', l.id]
    end
    result = pools.collect do |r|
      [r.type, r.id]
    end
    expect(result.sort).to eq expected.sort
  end

  it 'retrieve' do
    attributes = ['localpool_processing_contract',
                  'metering_point_operator_contract',
                  'localpool_power_taker_contracts',
                  'prices',
                  'admins',
                  'contracts',
                  'billing_cycles']
    attrs = pools.retrieve(localpool.id).to_h
    expect(attrs['id']).to eq localpool.id
    expect(attrs['type']).to eq 'group_localpool'
    expect(attrs.keys).to match_array base_attributes
  end

  context 'prices' do
    it 'retrieve all' do
      size = localpool.prices.size
      attributes = ['name',
                    'baseprice_cents_per_month',
                    'energyprice_cents_per_kilowatt_hour',
                    'begin_date',
                    'id',
                    'type',
                    'updated_at',
                    'updatable',
                    'deletable']
      Fabricate(:price, localpool: localpool)
      result = pools.retrieve(localpool.id).prices
      expect(result.size).to eq size + 1
      expect(result.first.to_hash.keys).to match_array attributes
    end

    it 'create' do
      request_params = {
        name: "special",
        begin_date: Date.new(2016, 1, 1),
        energyprice_cents_per_kilowatt_hour: 23.66,
        baseprice_cents_per_month: 500
      }

      result = pools.retrieve(localpool.id).create_price(request_params)
      expect(result.is_a?(Admin::PriceResource)).to eq true
      expect(result.object.localpool).to eq localpool
    end
  end

  context 'billing cycles' do
    it 'create' do
      request_params = {
        name: 'abcd',
        begin_date: Date.new(2016, 1, 1),
        end_date: Date.new(2016, 9, 1)
      }

      result = pools.retrieve(localpool.id).create_billing_cycle(request_params)
      expect(result.is_a?(Admin::BillingCycleResource)).to eq true
      expect(result.object.localpool).to eq localpool
    end

    it 'retrieve all' do
      size = localpool.billing_cycles.size
      Fabricate(:billing_cycle, localpool: localpool)
      Fabricate(:billing_cycle, localpool: localpool)

      attributes = ['name',
                    'begin_date',
                    'end_date',
                    'id',
                    'type',
                    'updated_at']

      result = pools.retrieve(localpool.id).billing_cycles
      expect(result.size).to eq size + 2
      expect(result.first.to_hash.keys).to match_array attributes
    end
  end

  context 'owner' do

    entity!(:pool) { pools.first }

    entity!(:person_raw) { Fabricate(:person) }
    entity!(:person2_raw) { Fabricate(:person) }

    entity!(:person) do
      PersonResource.new(person_raw, current_user: admin.person)
    end

    entity!(:organization) do
      OrganizationResource.new(Fabricate(:other_organization, legal_representation: Fabricate(:person)), current_user: admin.person, current_roles: [Role::BUZZN_OPERATOR], permissions: pool.permissions.owner)
    end

    before do
      organization.object.contact = nil
      organization.object.save
      pool.object.person = nil
      pool.object.organization = nil
      pool.object.save
    end

    context 'as person' do

      entity!(:person2) do
        PersonResource.new(person2_raw, current_user: admin.person)
      end

      it 'invalid' do
        expect(pool.incompleteness).to eq({owner:["must be filled"]})
        pool.assign_owner(person)
        person.object.remove_role(Role::GROUP_OWNER, pool.object)
        expect(pool.incompleteness).to eq({owner:["BUG: missing GROUP_ADMIN role"]})
      end

      it 'setup roles' do
        pool.setup_roles(nil, person)
        expect(person.object.has_role?(Role::GROUP_OWNER, pool.object)).to eq true
        expect(person.object.roles.size).to eq 1

        pool.setup_roles(person, nil)
        expect(person.object.has_role?(Role::GROUP_OWNER, pool.object)).to eq false
        expect(person.object.roles.size).to eq 0
      end

      it 'create' do
        pool.create_person_owner(Fabricate.build(:person).attributes)
        expect(pool.incompleteness).to eq({})
        expect(pool.owner.object.has_role?(Role::GROUP_OWNER, pool.object)).to eq true
        expect(pool.owner.object.roles.size).to eq 1

        owner = pool.owner
        pool.create_person_owner(Fabricate.build(:person).attributes)
        expect(pool.incompleteness).to eq({})
        expect(owner.object.has_role?(Role::GROUP_OWNER, pool.object)).to eq false
        expect(owner.object.roles.size).to eq 0

        pool.create_organization_owner(Fabricate.build(:organization).attributes)
        expect(pool.incompleteness).to eq({owner:{contact:["must be filled"]}})
        expect(pool.owner.legal_representation).to be_nil
      end

      it 'assign' do
        pool.assign_owner(person)
        expect(pool.incompleteness).to eq({})

        owner = pool.owner

        expect(person.object.has_role?(Role::GROUP_OWNER, pool.object)).to eq true
        expect(person.object.roles.size).to eq 1

        pool.assign_owner(person2)
        expect(pool.incompleteness).to eq({})
        expect(person.object.has_role?(Role::GROUP_OWNER, pool.object)).to eq false
        expect(person.object.roles.size).to eq 0

        pool.assign_owner(organization)
        expect(pool.incompleteness).to eq({owner:{contact:["must be filled"]}})
        expect(organization.legal_representation.object.has_role?(Role::GROUP_OWNER, pool.object)).to eq true
        expect(organization.legal_representation.object.roles.size).to eq 1
        expect(person2.object.has_role?(Role::GROUP_OWNER, pool.object)).to eq false
        expect(person2.object.roles.size).to eq 0
      end
    end

    context 'as organization' do

      entity!(:organization2) do
        OrganizationResource.new(Fabricate(:other_organization, legal_representation: person2_raw), current_user: admin.person, current_roles: [Role::BUZZN_OPERATOR], permissions: pool.permissions.owner)
      end

      it 'invalid' do
        expect(pool.incompleteness).to eq({owner:["must be filled"]})
        pool.assign_owner(organization)
        organization.legal_representation.object.remove_role(Role::GROUP_OWNER, pool.object)
        expect(pool.incompleteness).to eq({owner:{contact:["must be filled"]}})
        organization.object.contact = person_raw
        expect(pool.incompleteness).to eq({owner:["BUG: missing GROUP_ADMIN role"]})
      end

      it 'setup roles' do
        pool.setup_roles(nil, organization)
        expect(organization.legal_representation.object.has_role?(Role::GROUP_OWNER, pool.object)).to eq true
        expect(organization.legal_representation.object.roles.size).to eq 1

        pool.setup_roles(organization, nil)
        expect(organization.legal_representation.object.has_role?(Role::GROUP_OWNER, pool.object)).to eq false
        expect(organization.legal_representation.object.roles.size).to eq 0
      end

      it 'create' do
        pool.create_organization_owner(Fabricate.build(:organization).attributes)
        expect(pool.incompleteness).to eq({owner:{contact:["must be filled"]}})
        expect(pool.owner.legal_representation).to be_nil

        pool.create_person_owner(Fabricate.build(:person).attributes)
        expect(pool.incompleteness).to eq({})
        expect(pool.owner.object.has_role?(Role::GROUP_OWNER, pool.object)).to eq true
        expect(pool.owner.object.roles.size).to eq 1
      end

      it 'assign' do
        pool.assign_owner(organization)
        expect(pool.incompleteness).to eq({owner:{contact:["must be filled"]}})
        expect(organization.legal_representation.object.has_role?(Role::GROUP_OWNER, pool.object)).to eq true
        expect(organization.legal_representation.object.roles.size).to eq 1

        pool.assign_owner(organization2)
        expect(pool.incompleteness).to eq({owner:{contact:["must be filled"]}})
        expect(organization.legal_representation.object.has_role?(Role::GROUP_OWNER, pool.object)).to eq false
        expect(organization.legal_representation.object.roles.size).to eq 0

        pool.assign_owner(person)
        expect(pool.incompleteness).to eq({})
        expect(organization2.legal_representation.object.has_role?(Role::GROUP_OWNER, pool.object)).to eq false
        expect(organization2.legal_representation.object.roles.size).to eq 0
        expect(person.object.has_role?(Role::GROUP_OWNER, pool.object)).to eq true
        expect(person.object.roles.size).to eq 1
      end
    end
  end
end
