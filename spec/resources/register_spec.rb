# coding: utf-8
describe Register::BaseResource do

  let(:user) { Fabricate(:admin) }
  let!(:real) { Fabricate(:meter).registers.first }
  let!(:virtual) { Fabricate(:virtual_meter).register }

  let(:base_attributes) { [:direction,
                           :name,
                           :readable,
                           :meter,
                           :address ] }

  it 'has all attributes' do
    [real, virtual].each do |register|
      json = Register::BaseResource.retrieve(user, register.id).to_h
      expect(json.keys & base_attributes).to match_array base_attributes
    end
  end

  it 'has scores' do
    [real, virtual].each do |register|
      register = Register::BaseResource.retrieve(user, register.id)
      expect(register.scores).to eq []
    end
  end

  it 'has comments' do
    [real, virtual].each do |register|
      register = Register::BaseResource.retrieve(user, register.id)
      expect(register.comments).to eq []
    end
  end

  it 'collects with right ids + types' do
    expected = {Register::Real => real.id, Register::Virtual => virtual.id}
    result = Register::BaseResource.all(user).collect do |r|
      type = r.type.constantize
      type = type.superclass if type.superclass != Register::Base
      [type, r.id]
    end
    expect(Hash[result]).to eq expected
  end
    
  describe Register::Real do

    it 'collects with right ids + types' do
      result = Register::RealResource.all(user).collect do |r|
        [r.type.constantize.superclass, r.id]
      end
      expect(result).to eq [[Register::Real, real.id]]
    end

    it "correct id + type" do
      [Register::BaseResource, Register::RealResource].each do |type|
        json = type.retrieve(user, real.id).to_h
        expect(json[:id]).to eq real.id
        expect(json[:type]).to eq 'register_real'
      end
      expect{Register::RealResource.retrieve(user, virtual.id)}.to raise_error Buzzn::RecordNotFound
    end

    it 'has all attributes' do
      attributes = [:uid, :obis, :devices]
      json = Register::BaseResource.retrieve(user, real.id).to_h
      expect(json.keys & attributes).to match_array attributes
      expect(json.keys.size).to eq (attributes.size + base_attributes.size + 2)
    end

  end

  describe Register::Virtual do
  
    it 'collects with right ids + types' do
      expected = [Register::Virtual, virtual.id]
      result = Register::VirtualResource.all(user).collect do |r|
        [r.type.constantize, r.id]
      end
      expect(result).to eq [expected]
    end

    it "correct id + type" do
      [Register::BaseResource, Register::VirtualResource].each do |type|
        json = type.retrieve(user, virtual.id).to_h
        expect(json[:id]).to eq virtual.id
        expect(json[:type]).to eq 'register_virtual'
      end
      expect{Register::VirtualResource.retrieve(user, real.id)}.to raise_error Buzzn::RecordNotFound
    end
      
    it 'has all attributes' do
      json = Register::BaseResource.retrieve(user, virtual.id).to_h
      expect(json.keys.size).to eq (base_attributes.size + 2)
    end
  end
end
