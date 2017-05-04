describe Buzzn::Services::MessageEncryptor do

  it 'produces ActiveSupport::MessageEncryptor instances' do
    instance1 = Buzzn::Services::MessageEncryptor.new
    instance2 = Buzzn::Services::MessageEncryptor.new
    expect(instance1.object_id).not_to eq instance2.object_id
    expect(instance1).not_to eq instance2
  end
end
