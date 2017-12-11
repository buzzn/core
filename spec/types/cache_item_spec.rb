require 'buzzn/types/cache_item'

describe Types::CacheItem do

  it 'generates digest' do
    subject = Types::CacheItem.new(json: '{}', time_to_live: 2)
    expect(subject.digest.length).to eq 44
    expect(subject.to_json).to eq '{}'
  end

  it 'keeps given digest' do
    subject = Types::CacheItem.new(json: '{}', digest: 'hallo', time_to_live: 2)
    expect(subject.digest).to eq 'hallo'
    expect(subject.to_json).to eq '{}'
  end
end
