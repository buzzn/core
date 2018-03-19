describe Operations::CreateReadingsForGroup do

  # TODO discuss if/how to stub the call
  class ReadingsStub
    def initialize(result = {})
      @result = result
    end
    def all(_group, _date_time)
      @result || {}
    end
  end

  let(:market_location) { create(:market_location)}
  let(:group)           { market_location.group }
  let(:date_time)       { Time.now }
  let(:create_readings) { Operations::CreateReadingsForGroup.new(single_reading: readings_stub) }

  context 'no readings returned' do
    let(:readings_stub) { ReadingsStub.new }
    it 'doesn\'t create readings' do
      expect {
        expect(create_readings.call(group: group, date_time: date_time)).to be_success
      }.not_to change(Reading::Single, :count)
    end
  end

  context 'readings returned' do
    let(:register)      { create(:register, :input, market_location: market_location) }
    let(:readings_stub) { ReadingsStub.new(register.id => 42_000) }
    it 'creates readings' do
      expect {
        expect(create_readings.call(group: group, date_time: date_time)).to be_success
      }.to change(Reading::Single, :count)
      expect(Reading::Single.last.value).to eq(42_000)
    end
  end
end
