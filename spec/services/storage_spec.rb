describe Buzzn::Services::Storage do

  it 'produces a singleton Fog::Storage instance' do
    instance1 = Buzzn::Services::Storage.new
    instance2 = Buzzn::Services::Storage.new
    expect(instance1.object_id).to eq instance2.object_id
    expect(instance1).to eq instance2
  end
end
