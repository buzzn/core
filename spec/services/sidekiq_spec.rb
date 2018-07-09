describe Services::SidekiqClient do
  it 'produces a singleton Services::SidekiqClient' do
    instance1 = Services::SidekiqClient.new
    instance2 = Services::SidekiqClient.new
    expect(instance1.object_id).to eq instance2.object_id
    expect(instance1).to eq instance2
  end
end

describe Services::SidekiqServer do
  it 'produces a singleton Services::SidekiqServer' do
    instance1 = Services::SidekiqServer.new
    instance2 = Services::SidekiqServer.new
    expect(instance1.object_id).to eq instance2.object_id
    expect(instance1).to eq instance2
  end
end
