require_relative '../../../support/discovergy_helper'

describe Services::Datasource::Discovergy::SingleReading do

  context 'cached results for testing' do

    entity(:single_reading) do
      Import.global('services.datasource.discovergy.single_reading')
    end

    entity(:cache) do
      Import.global('services.cache')
    end

    let(:mock_result) do
      {
        time: 123456789,
        value: 23,
        value2: 42
      }
    end

    entity(:group) do
      create(:group, :localpool)
    end

    entity(:meter) do
      create(:meter, :real, group: group)
    end

    entity(:register) do
      meter.registers.first
    end

    entity(:now) do
      Time.now
    end

    it 'stores' do
      single_reading.next_api_request_single(register, now, mock_result)
      key = single_reading.next_key(register, now)
      item = cache.get(key)
      expect(item).to_not be_nil
      result = MultiJson.load(item.json)
      expect(result).to_not eql ''
      expect(Buzzn::Utils::Helpers.symbolize_keys_recursive(result)).to eql mock_result
    end

    it 'retrieves nil' do
      # invalidate
      key = single_reading.next_key(register, now)
      cache.put(key, '', 600)
      expect(single_reading.single(register, now)).to be_nil
    end

    it 'retrieves something' do
      mock_series = create_series(now, 2000, 15.minutes, 137*1000*1000, 50*1000*1000, 4)
      single_reading.next_api_request_single(register, now, mock_series)
      reading = single_reading.single(register, now)
      expect(reading.values.count).to eql 1
      expect(reading.values.first).to eql 13.7
    end

  end
end
