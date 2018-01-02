require 'buzzn/services/cache'

describe Services::Cache do

  let(:subject) { Import.global('services.cache') }

  it 'puts json and returns cache-item' do
    item = subject.put('key', '{}', 10)
    expect(item.to_json).to eq '{}'
    expect(item.time_to_live).to eq 10
    item = subject.get('key')
    expect(item.to_json).to eq '{}'
    expect(item.time_to_live).to eq 10
  end

  it 'expires after time-to-live' do
    item = subject.put('key', '{}', 2)
    expect(item).not_to be_nil
    # can not use Timecop as Redis does not know about it
    sleep 1
    item = subject.get('key')
    expect(item).not_to be_nil
    expect(item.time_to_live).to eq 1
    sleep 1
    item = subject.get('key')
    expect(item).to be_nil
  end

end
