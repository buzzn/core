# coding: utf-8
describe Meter::BaseResource do

  entity(:admin) { Fabricate(:admin) }
  entity(:localpool) { Fabricate(:localpool) }
  entity!(:real) do
    meter = Fabricate(:meter)
    meter.registers.first.update(group: localpool)
    meter
  end
  entity!(:virtual) do
    meter = Fabricate(:virtual_meter)
    meter.register.update(group: localpool)
    meter
  end

  let(:resources) { Admin::LocalpoolResource.all(admin).retrieve(localpool.id).meters }

  let(:base_keys) { ['id',
                     'type',
                     'manufacturer_product_name',
                     'manufacturer_product_serialnumber',
                     'metering_type',
                     'meter_size',
                     'ownership',
                     'direction_label',
                     'build_year',
                     'updatable',
                     'deletable',
                     'rules'] }

  it 'retrieve' do
    [real, virtual].each do |meter|
      attrs = resources.retrieve(meter.id).to_h
      expect(attrs.keys & base_keys).to match_array base_keys
    end
  end

  it 'retrieve all - ids + types' do
    expected = [['meter_real', real.id]] + Meter::Virtual.all.collect do |v|
      ['meter_virtual', v.id]
    end
    result = resources.collect do |r|
      [r.type, r.id]
    end
    expect(result).to match_array expected
  end
    
  describe Meter::Real do

    it 'retrieve all - ids + types' do
      result = resources.reals.collect do |r|
        [r.type, r.id]
      end
      expect(result).to eq [['meter_real', real.id]]
    end

    it 'retrieve' do
      attrs = resources.retrieve(real.id).to_h
      expect(attrs['id']).to eq real.id
      expect(attrs['type']).to eq 'meter_real'
      expect(attrs.keys).to match_array base_keys + ['manufacturer_name']
      expect{resources.virtuals.retrieve(real.id)}.to raise_error Buzzn::PermissionDenied
    end

  end

  describe Meter::Virtual do
  
    it 'retrieve all - ids + types' do
      expected = Meter::Virtual.all.collect do |v|
        ['meter_virtual', v.id]
      end
      result = resources.virtuals.collect do |r|
        [r.type, r.id]
      end
      expect(result).to match_array expected
    end
      
    it 'retrieve' do
      attrs = resources.retrieve(virtual.id).to_h
      expect(attrs['id']).to eq virtual.id
      expect(attrs['type']).to eq 'meter_virtual'
      expect(attrs.keys).to match_array base_keys
      expect{resources.reals.retrieve(virtual.id)}.to raise_error Buzzn::PermissionDenied
    end
  end
end
