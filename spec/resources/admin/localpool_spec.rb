describe Admin::LocalpoolResource do

  entity(:admin) { create(:account, :buzzn_operator) }
  entity!(:localpool) { create(:group, :localpool, bank_account: create(:bank_account)) }

  entity!(:pools) { Admin::LocalpoolResource.all(admin) }

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
      it { is_expected.to match_array ['wind', 'water'] }
    end
  end

  context 'owner' do

    entity!(:pool) { pools.first }

    entity!(:person) { create(:person) }

    entity!(:organization) { create(:organization, contact: nil) }

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
        expect(pool.incompleteness[:owner]).to eq(nil)
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
