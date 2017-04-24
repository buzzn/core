describe Buzzn::Services::MessageEncrypter do

  it 'produces ActiveSupport::MessageEncryptor instances' do
    instance1 = Buzzn::Services::MessageEncrypter.new
    instance2 = Buzzn::Services::MessageEncrypter.new
    expect(instance1.object_id).not_to eq instance2.object_id
    expect(instance1).not_to eq instance2
  end
end
