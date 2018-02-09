describe Admin::LocalpoolResource do

  entity(:admin) { Fabricate(:admin) }
  entity!(:localpool) { Fabricate(:localpool, bank_account: create(:bank_account)) }

  let(:base_attributes) do %w(id type updated_at
                           name
                           description
                           slug
                           start_date
                           show_object
                           show_production
                           show_energy
                           show_contact
                           updatable
                           deletable
                           incompleteness
                           bank_account
                           power_sources) end

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

  context 'power_sources' do

    def add_register_with_label(pool, label)
      meter = create(:meter, :real, register_direction: :output, group: pool.object)
      meter.output_register.send("#{label}!")
      pool.object.reload
    end

    entity!(:pool) { pools.first }
    subject        { pool.power_sources }
    before         { pool.object.meters.clear }

    context 'when group has no registers' do
      it { is_expected.to eq [] }
    end

    context 'when group has a production pv and consumption register' do
      before do
        add_register_with_label(pool, :consumption)
        add_register_with_label(pool, :production_pv)
      end
      it { is_expected.to eq ['pv'] }
    end

    context 'when group has a production wind and water register' do
      before do
        add_register_with_label(pool, :production_wind)
        add_register_with_label(pool, :production_water)
      end
      it { is_expected.to eq ['wind', 'water'] }
    end
  end

  context 'tariffs' do
    it 'retrieve all' do
      size = localpool.tariffs.size
      attributes = ['name',
                    'baseprice_cents_per_month',
                    'energyprice_cents_per_kwh',
                    'begin_date',
                    'last_date',
                    'id',
                    'type',
                    'updated_at',
                    'updatable',
                    'deletable',
                    'number_of_contracts']
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
      pool.object.update(owner: nil)
    end

    context 'as person' do

      it 'invalid' do
        expect(pool.incompleteness[:owner]).to eq(['must be filled'])
        pool.object.owner = person
        person.remove_role(Role::GROUP_OWNER, pool.object)
        person.add_role(Role::GROUP_OWNER, pool.object)
      end

    end

    context 'as organization' do

      it 'invalid' do
        expect(pool.incompleteness[:owner]).to eq(['must be filled'])
        pool.object.owner = organization
        expect(pool.incompleteness[:owner]).to eq({contact: ['must be filled'],
                                                   address: ['must be filled']})
        organization.contact = person
        organization.contact.remove_role(Role::GROUP_OWNER, pool.object)
        organization.contact.add_role(Role::GROUP_OWNER, pool.object)
      end
    end
  end

  context 'grid registers' do

    entity!(:pool) { pools.first }

    context 'grid_consumption_register' do

      context 'without register' do
        before { pool.object.meters.clear }
        it 'is incomplete' do
          expect(pool.incompleteness[:grid_consumption_register]).to eq ['must be filled']
        end
      end

      context 'with register' do
        entity(:input_register) do
          r = create(:meter, :real, group: localpool).input_register
          r.update(label: :grid_consumption)
          r
        end

        context 'without metering_point_id' do
          before do
            input_register.update(metering_point_id: nil)
            pool.object.meters << input_register.meter
          end
          it 'is incomplete' do
            expect(pool.incompleteness[:grid_consumption_register]).to eq ['missing metering_point_id']
          end
        end

        context 'with metering_point_id' do
          before do
            input_register.update(metering_point_id: 'DE123423123')
            pool.object.meters << input_register.meter
          end
          it 'is complete' do
            expect(pool.incompleteness[:grid_consumption_register]).to be_nil
          end
        end
      end
    end

    context 'grid_feeding_register' do

      context 'without register' do
        before { pool.object.meters.clear }
        it 'is incomplete' do
          expect(pool.incompleteness[:grid_feeding_register]).to eq ['must be filled']
        end
      end

      context 'with register' do
        entity(:output_register) do
          r = create(:meter, :real, register_direction: :output, group: localpool).output_register
          r.update(label: :grid_feeding)
          r
        end

        context 'without metering_point_id' do
          before do
            output_register.update(metering_point_id: nil)
            pool.object.meters << output_register.meter
          end
          it 'is incomplete' do
            expect(pool.incompleteness[:grid_feeding_register]).to eq ['missing metering_point_id']
          end
        end

        context 'with metering_point_id' do
          before do
            output_register.update(metering_point_id: 'DE123423123')
            pool.object.meters << output_register.meter
          end
          it 'is complete' do
            expect(pool.incompleteness[:grid_feeding_register]).to be_nil
          end
        end
      end
    end
  end
end
