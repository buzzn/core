# coding: utf-8
describe Meter::BaseResource do

  entity(:user) { Fabricate(:admin) }
  entity!(:real) { Fabricate(:meter) }
  entity!(:virtual) { Fabricate(:virtual_meter) }

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
      json = Meter::BaseResource.retrieve(user, meter.id).to_h
      expect(json.keys & base_keys).to match_array base_keys
    end
  end

  it 'retrieve all - ids + types' do
    expected = {'meter_real' => real.id, 'meter_virtual' => virtual.id}
    result = Meter::BaseResource.all(user)['array'].collect do |r|
      [r.type, r.id]
    end
    expect(Hash[result]).to eq expected
  end
    
  describe Meter::Real do

    it 'retrieve all - ids + types' do
      result = Meter::RealResource.all(user)['array'].collect do |r|
        [r.type, r.id]
      end
      expect(result).to eq [['meter_real', real.id]]
    end

    it "retrieve - id + type" do
      [Meter::BaseResource, Meter::RealResource].each do |type|
        json = type.retrieve(user, real.id).to_h
        expect(json['id']).to eq real.id
        expect(json['type']).to eq 'meter_real'
      end
      expect{Meter::RealResource.retrieve(user, virtual.id)}.to raise_error Buzzn::RecordNotFound
    end

    it 'retrieve' do
      json = Meter::BaseResource.retrieve(user, real.id).to_h
      expect(json.keys).to match_array base_keys + ['manufacturer_name']
    end

  end

  describe Meter::Virtual do
  
    it 'retrieve all - ids + types' do
      expected = ['meter_virtual', virtual.id]
      result = Meter::VirtualResource.all(user)['array'].collect do |r|
        [r.type, r.id]
      end
      expect(result).to eq [expected]
    end

    it "retrieve - id + type" do
      [Meter::BaseResource, Meter::VirtualResource].each do |type|
        json = type.retrieve(user, virtual.id).to_h
        expect(json['id']).to eq virtual.id
        expect(json['type']).to eq 'meter_virtual'
      end
      expect{Meter::VirtualResource.retrieve(user, real.id)}.to raise_error Buzzn::RecordNotFound
    end
      
    it 'retrieve' do
      json = Meter::BaseResource.retrieve(user, virtual.id).to_h
      expect(json.keys).to match_array base_keys
    end
  end
end
