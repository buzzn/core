require 'buzzn/types/datasource'

describe Types::Datasource do

  entity(:register) { create(:meter, :real).input_register }

  context Types::Datasource::Current do

    it 'watt' do
      subject = Types::Datasource::Current.new(value: 123, unit: :W, register: register)
      result = subject.to_json.sub(/:[0-9]+/, ':0')
      expect(result).to eq "{\"timestamp\":0,\"value\":123,\"resource_id\":\"#{register.id}\",\"mode\":\"in\"}"
    end

    it 'watthour' do
      subject = Types::Datasource::Current.new(value: 123, unit: :Wh, register: register)
      result = subject.to_json.sub(/:[0-9]+/, ':0')
      expect(result).to eq "{\"timestamp\":0,\"value\":123,\"resource_id\":\"#{register.id}\",\"mode\":\"in\"}"
    end
  end
end
