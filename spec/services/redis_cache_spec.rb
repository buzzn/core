describe Services::RedisSidekiq do

  it 'produces a singleton Redis instance' do
    redis1 = Services::RedisSidekiq.new
    redis2 = Services::RedisSidekiq.new
    expect(redis1.object_id).to eq redis2.object_id
    expect(redis1).to eq redis2
  end
end
