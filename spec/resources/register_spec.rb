# coding: utf-8
describe Register::BaseResource do

  let(:user) { entities[:admin] ||= Fabricate(:admin) }
  let!(:real) { entities[:real] ||= Fabricate(:meter).registers.first }
  let!(:virtual) { entities[:virtual] ||= Fabricate(:virtual_meter).register }

  let(:base_keys) { [:id,
                     :type,
                     :direction,
                     :name ] }
  let(:common_single_keys) { base_keys + [
                               :low_power,
                               :decimal,
                               :pre_decimal,
                               :converter_constant,
                               :meter,
                               :address ] }

  it 'retrieve' do
    [real, virtual].each do |register|
      json = Register::BaseResource.retrieve(user, register.id).to_h
      expect(json.keys & common_single_keys).to match_array common_single_keys
    end
  end

  it 'retrieve all - ids + types' do
    expected = {Register::Real => real.id, Register::Virtual => virtual.id}
    result = Register::BaseResource.all(user).collect do |r|
      type = r.type.constantize
      type = type.superclass if type.superclass != Register::Base
      [type, r.id]
    end
    expect(Hash[result]).to eq expected
  end
    
  describe Register::RealResource do

    it 'retrieve all - ids + types' do
      result = Register::RealSingleResource.all(user).collect do |r|
        [r.type.constantize.superclass, r.id]
      end
      expect(result).to eq [[Register::Real, real.id]]
    end

    it "retrieve - id + type" do
      [Register::BaseResource, Register::RealSingleResource].each do |type|
        json = type.retrieve(user, real.id).to_h
        expect(json[:id]).to eq real.id
        expect(json[:type]).to eq 'register_real'
      end
      expect{Register::RealSingleResource.retrieve(user, virtual.id)}.to raise_error Buzzn::RecordNotFound
    end

    it 'retrieve' do
      keys = [:uid, :obis, :devices]
      json = Register::BaseResource.retrieve(user, real.id).to_h
      expect(json.keys).to match_array (keys + common_single_keys)
    end

    it 'retrieve all' do
      json = Register::RealCollectionResource.new(real).attributes
      expect(json.keys).to match_array base_keys
    end
  end

  describe Register::VirtualResource do
  
    it 'retrieve all - ids + types' do
      expected = [Register::Virtual, virtual.id]
      result = Register::VirtualResource.all(user).collect do |r|
        [r.type.constantize, r.id]
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
      json = Register::RealCollectionResource.new(real).attributes
      expect(json.keys).to match_array base_keys
    end
  end
end
