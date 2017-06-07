# coding: utf-8
describe Register::BaseResource do

  entity(:user) { Fabricate(:admin) }
  entity!(:real) { Fabricate(:meter).registers.first }
  entity!(:virtual) { Fabricate(:virtual_meter).register }

  let(:base_keys) { [:id,
                     :type,
                     :label,
                     :converter_constant,
                     :decimal,
                     :direction,
                     :last_reading,
                     :low_power,
                     :name,
                     :pre_decimal ] }
  let(:common_single_keys) { base_keys + [
                               :group ] }

  it 'retrieve' do
    [real, virtual].each do |register|
      json = Register::BaseResource.retrieve(user, register.id).to_h
      expect(json.keys & common_single_keys).to match_array common_single_keys
    end
  end

  it 'retrieve all - ids + types' do
    expected = {'register_real' => real.id, 'register_virtual' => virtual.id}
    result = Register::BaseResource.all(user)['array'].collect do |r|
      type = r.type
      [type, r.id]
    end
    expect(Hash[result]).to eq expected
  end
    
  describe Register::RealResource do

    it 'retrieve all - ids + types' do
      result = Register::RealResource.all(user)['array'].collect do |r|
        [r.type, r.id]
      end
      expect(result).to eq [['register_real', real.id]]
    end

    it "retrieve - id + type" do
      [Register::BaseResource, Register::RealResource].each do |type|
        json = type.retrieve(user, real.id).to_h
        expect(json[:id]).to eq real.id
        expect(json[:type]).to eq 'register_real'
      end
      expect{Register::RealResource.retrieve(user, virtual.id)}.to raise_error Buzzn::RecordNotFound
    end

    it 'retrieve' do
      keys = [:uid, :obis, :devices]
      json = Register::BaseResource.retrieve(user, real.id).to_h
      expect(json.keys).to match_array (keys + common_single_keys)
    end

    it 'retrieve all' do
      json = Register::RealResource.new(real).attributes
      expect(json.keys).to match_array base_keys + [:uid, :obis]
    end
  end

  describe Register::VirtualResource do
  
    it 'retrieve all - ids + types' do
      expected = ['register_virtual', virtual.id]
      result = Register::VirtualResource.all(user)['array'].collect do |r|
        [r.type, r.id]
      end
      expect(result).to eq [expected]
    end

    it "retrieve - id + type" do
      [Register::BaseResource, Register::VirtualResource].each do |type|
        json = type.retrieve(user, virtual.id).to_h
        expect(json[:id]).to eq virtual.id
        expect(json[:type]).to eq 'register_virtual'
      end
      expect{Register::VirtualResource.retrieve(user, real.id)}.to raise_error Buzzn::RecordNotFound
    end
      
    it 'retreive' do
      json = Register::BaseResource.retrieve(user, virtual.id).to_h
      expect(json.keys).to match_array common_single_keys
    end

    it 'retrieve all' do
      json = Register::VirtualResource.new(virtual).attributes
      expect(json.keys).to match_array base_keys
    end
  end
end
