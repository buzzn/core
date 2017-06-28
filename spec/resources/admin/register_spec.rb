# coding: utf-8
describe Register::BaseResource do

  entity(:admin) { Fabricate(:admin) }
  entity(:localpool) { Fabricate(:localpool) }
  entity!(:real) do
    register = Fabricate(:meter).registers.first
    register.update(group: localpool)
    register
  end
  entity!(:virtual) do
    register = Fabricate(:virtual_meter).register
    register.update(group: localpool)
    register
  end

  let(:resources) { Admin::LocalpoolResource.all(admin).retrieve(localpool.id).registers }

  let(:base_keys) { ['id',
                     'type',
                     'label',
                     'name',
                     'direction',
                     'last_reading',
                     'low_load_ability',
                     'observer_enabled',
                     'observer_max_threshold',
                     'observer_min_threshold',
                     'observer_offline_monitoring',
                     'post_decimal_position',
                     'pre_decimal_position' ] }

  it 'retrieve' do
    [real, virtual].each do |register|
      attrs = resources.retrieve(register.id).to_h
      expect(attrs.keys & base_keys).to match_array base_keys
    end
  end

  it 'retrieve all - ids + types' do
    expected = [['register_real', real.id]] + Register::Virtual.all.collect do |v|
      ['register_virtual', v.id]
    end
    result = resources.collect do |r|
      type = r.type
      [type, r.id]
    end
    expect(result).to match_array expected
  end
    
  describe Register::RealResource do

    it 'retrieve all - ids + types' do
      result = resources.reals.collect do |r|
        [r.type, r.id]
      end
      expect(result).to eq [['register_real', real.id]]
    end

    it 'retrieve' do
      attrs = resources.retrieve(real.id).to_h
      expect(attrs['id']).to eq real.id
      expect(attrs['type']).to eq 'register_real'
      expect(attrs.keys).to match_array base_keys +
                                        ['obis', 'metering_point_id']
      expect{resources.reals.retrieve(virtual.id)}.to raise_error Buzzn::PermissionDenied
    end
  end

  describe Register::VirtualResource do
  
    it 'retrieve all - ids + types' do
      expected = Register::Virtual.all.collect do |v|
        ['register_virtual', v.id]
      end
      result = resources.virtuals.collect do |r|
        [r.type, r.id]
      end
      expect(result).to match_array expected
    end

    it 'retrieve' do
      attrs = resources.retrieve(virtual.id).to_h
      expect(attrs['id']).to eq virtual.id
      expect(attrs['type']).to eq 'register_virtual'
      expect(attrs.keys).to match_array base_keys
      expect{resources.virtuals.retrieve(real.id)}.to raise_error Buzzn::PermissionDenied
    end
  end
end
