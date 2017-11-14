describe Admin::LocalpoolResource do

  entity(:admin) { Fabricate(:admin) }
  entity!(:localpool) { Fabricate(:localpool) }

  let(:base_attributes) { ['id', 'type', 'updated_at',
                           'name',
                           'description',
                           'slug',
                           'start_date',
                           'show_object',
                           'show_production',
                           'show_energy',
                           'show_contact',
                           'updatable',
                           'deletable',
                           'incompleteness' ] }

  entity!(:pools) { Admin::LocalpoolResource.all(admin) }

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
                  'tariffs',
                  'admins',
                  'contracts',
                  'billing_cycles']
    attrs = pools.retrieve(localpool.id).to_h
    expect(attrs['id']).to eq localpool.id
    expect(attrs['type']).to eq 'group_localpool'
    expect(attrs.keys).to match_array base_attributes
  end

  context 'tariffs' do
    it 'retrieve all' do
      size = localpool.tariffs.size
      attributes = ['name',
                    'baseprice_cents_per_month',
                    'energyprice_cents_per_kwh',
                    'begin_date',
                    'end_date',
                    'id',
                    'type',
                    'updated_at',
                    'updatable',
                    'deletable']
      Fabricate(:tariff, group: localpool)
      result = pools.retrieve(localpool.id).tariffs
      expect(result.size).to eq size + 1
      expect(result.first.to_hash.keys).to match_array attributes
    end

  end

  context 'billing cycles' do

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

    entity!(:person) { Fabricate(:person) }

    entity!(:organization) do
      Fabricate(:other_organization)
    end

    before do
      #organization.update(contact: nil)
      pool.object.update(owner: nil)
    end

    context 'as person' do

      it 'invalid' do
        expect(pool.incompleteness[:owner]).to eq(["must be filled"])
        pool.object.owner = person
        person.remove_role(Role::GROUP_OWNER, pool.object)
        expect(pool.incompleteness[:owner]).to eq(["BUG: missing GROUP_ADMIN role"])
        person.add_role(Role::GROUP_OWNER, pool.object)
        expect(pool.incompleteness[:owner]).to eq(["BUG: missing GROUP_ADMIN role"])
      end

    end

    context 'as organization' do

      it 'invalid' do
        expect(pool.incompleteness[:owner]).to eq(["must be filled"])
        pool.object.owner = organization
        expect(pool.incompleteness[:owner]).to eq({contact:["must be filled"]})
        organization.contact = person
        organization.contact.remove_role(Role::GROUP_OWNER, pool.object)
        expect(pool.incompleteness[:owner]).to eq(["BUG: missing GROUP_ADMIN role"])
        organization.contact.add_role(Role::GROUP_OWNER, pool.object)
        expect(pool.incompleteness[:owner]).to eq(["BUG: missing GROUP_ADMIN role"])
      end
    end
  end

  context 'grid registers' do

    entity!(:pool) { pools.first }

    context 'grid_consumption_register' do

      context 'without register' do
        before { pool.object.update(grid_consumption_register: nil) }
        it 'is incomplete' do
          expect(pool.incompleteness[:grid_consumption_register]).to eq ["must be filled"]
        end
      end

      context 'with register' do
        entity(:input_register) { Fabricate(:input_meter).input_register}

        context 'without metering_point_id' do
          before do
            input_register.update(metering_point_id: nil)
            pool.object.update(grid_consumption_register: input_register)
          end
          it 'is incomplete' do
            expect(pool.incompleteness[:grid_consumption_register]).to eq ["missing metering_point_id"]
          end
        end

        context 'with metering_point_id' do
          before do
            input_register.update(metering_point_id: 'DE123423123')
            pool.object.update(grid_consumption_register: input_register)
          end
          it 'is complete' do
            expect(pool.incompleteness[:grid_consumption_register]).to be_nil
          end
        end
      end
    end

    context 'grid_feeding_register' do

      context 'without register' do
        before { pool.object.update(grid_feeding_register: nil) }
        it 'is incomplete' do
          expect(pool.incompleteness[:grid_feeding_register]).to eq ["must be filled"]
        end
      end

      context 'with register' do
        entity(:output_register) { Fabricate(:output_meter).output_register }

        context 'without metering_point_id' do
          before do
            output_register.update(metering_point_id: nil)
            pool.object.update(grid_feeding_register: output_register)
          end
          it 'is incomplete' do
            expect(pool.incompleteness[:grid_feeding_register]).to eq ["missing metering_point_id"]
          end
        end

        context 'with metering_point_id' do
          before do
            output_register.update(metering_point_id: 'DE123423123')
            pool.object.update(grid_feeding_register: output_register)
          end
          it 'is complete' do
            expect(pool.incompleteness[:grid_feeding_register]).to be_nil
          end
        end
      end
    end
  end
end
