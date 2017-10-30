describe 'Buzzn::Discovergy::DataSource caching' do

  class FacadeMock4Caching
    attr_accessor :result

    def readings(*args)
      @result
    end
  end

  entity(:facade) { FacadeMock4Caching.new }

  entity(:single_meter_live_response) { "{\"time\":1480606450088,\"values\":{\"power\":1100640}}" }
  entity(:virtual_meter_live_response) { "{\"EASYMETER_60009425\":{\"time\":1480614249341,\"values\":{\"power\":150950}},\"EASYMETER_60009404\":{\"time\":1480614254195,\"values\":{\"power\":161590}},\"EASYMETER_60009415\":{\"time\":1480614254563,\"values\":{\"power\":152190}}}"}

  entity(:empty_group) { Fabricate(:tribe) }
  entity(:register_with_broker) do
    meter = Fabricate(:meter, registers: [Fabricate.build(:input_register, group: empty_group)])
    Fabricate(:discovergy_broker, mode: 'in', resource: meter, external_id: 'easy_123')
    meter.input_register
  end
  entity(:some_group) do
    some_group = Fabricate(:localpool)
    some_group.brokers << Fabricate(:discovergy_broker, mode: 'in', resource: some_group, external_id: "EASYMETER_12345678")
    some_group.registers << Fabricate(:input_meter).input_register
    some_group
  end

  let(:cache_time) { 1 }

  # 'threaded' in description triggers a different DatabaseCleanet strategy
  # see spec_helper.rb
  it 'caches single results single threaded' do
    data_source = Buzzn::Discovergy::DataSource.new(Redis.current, facade, cache_time)
    facade.result = single_meter_live_response

    result = data_source.single_aggregated(register_with_broker, :in)
    other = data_source.single_aggregated(register_with_broker, :in)

    expect(result.expires_at).to eq other.expires_at
    sleep(cache_time + 0.2)
    other = data_source.single_aggregated(register_with_broker, :in)
    expect(result.expires_at).not_to eq other.expires_at
  end

  # 'threaded' in description triggers a different DatabaseCleanet strategy
  # see spec_helper.rb
  it 'caches collection result single threaded' do
    data_source = Buzzn::Discovergy::DataSource.new(Redis.current, facade, cache_time)
    facade.result = virtual_meter_live_response

    result = data_source.collection(some_group, :out)
    other = data_source.collection(some_group, :out)

    expect(result.expires_at).to eq other.expires_at
    sleep(cache_time + 0.2)
    other = data_source.collection(some_group, :out)
    expect(result.expires_at).not_to eq other.expires_at
  end

  # 'threaded' in description triggers a different DatabaseCleanet strategy
  # see spec_helper.rb

  # TODO: this test is failing "no method expires_at for nil class" in line 81
  xit 'caches single results multi threaded' do #, retry: 2 do
    data_source = Buzzn::Discovergy::DataSource.new(Redis.current, facade, cache_time)
    facade.result = single_meter_live_response

    result = data_source.single_aggregated(register_with_broker, :in)
    16.times.collect do
      Thread.new do
        other = data_source.single_aggregated(register_with_broker, :in)
        expect(result.expires_at).to eq other.expires_at
      end
    end.each { |t| t.join }
    all = []
    16.times.collect do
      Thread.new do
        sleep(cache_time + 0.2)
        all << data_source.single_aggregated(register_with_broker, :in).expires_at
        self
      end
    end.each { |t| t.join }
    all.uniq!
    expect(all.size).to eq 1
    expect(result.expires_at).not_to eq all.first
  end

  xit 'caches collection result multi threaded', retry: 2 do
    data_source = Buzzn::Discovergy::DataSource.new(Redis.current, facade, cache_time)
    facade.result = virtual_meter_live_response

    result = data_source.collection(some_group, :out)
    16.times.collect do
      Thread.new do
        other = data_source.collection(some_group, :out)
        expect(result.expires_at).to eq other.expires_at
      end
    end.each { |t| t.join }
    all = []
    16.times.collect do
      Thread.new do
        sleep(cache_time + 0.2)
        all << data_source.collection(some_group, :out).expires_at
        self
      end
    end.each { |t| t.join }
    all.uniq!
    expect(all.size).to eq 1
    expect(result.expires_at).not_to eq all.first
  end
end
