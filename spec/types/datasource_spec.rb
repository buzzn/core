require 'buzzn/types/datasource'

describe Types::Datasource do

  entity(:register_prod)  { create(:meter, :real, register_label: :production_wind).registers.first }
  entity(:register_c)     { create(:meter, :real, register_label: :consumption).registers.first }
  entity(:register_cc)    { create(:meter, :real, register_label: :consumption_common).registers.first }

  it Types::Datasource::Bubble do
    [register_prod, register_cc].each do |register|
      subject = Types::Datasource::Bubble.new(value: 123, register: register)
      expect(subject.to_json).to eq "{\"id\":#{register.id},\"label\":\"#{register.meta.label}\",\"value\":123,\"name\":\"#{register.meta.name}\"}"
      expect([subject].to_json).to eq "[{\"id\":#{register.id},\"label\":\"#{register.meta.label}\",\"value\":123,\"name\":\"#{register.meta.name}\"}]"
    end

    [register_c].each do |register|
      subject = Types::Datasource::Bubble.new(value: 123, register: register)
      expect(subject.to_json).to eq "{\"id\":#{register.id},\"label\":\"#{register.meta.label}\",\"value\":123}"
      expect([subject].to_json).to eq "[{\"id\":#{register.id},\"label\":\"#{register.meta.label}\",\"value\":123}]"
    end

  end

  context Types::Datasource::Current do

    it 'watt' do
      register = register_c
      subject = Types::Datasource::Current.new(value: 123, unit: :W, register: register)
      result = subject.to_json.sub(/p\":[0-9]+/, 'p":0')
      expect(result).to eq "{\"timestamp\":0,\"value\":123,\"resource_id\":#{register.id}}"
    end

    it 'watthour' do
      register = register_c
      subject = Types::Datasource::Current.new(value: 123, unit: :Wh, register: register)
      result = subject.to_json.sub(/:[0-9]+/, ':0')
      expect(result).to eq "{\"timestamp\":0,\"value\":123,\"resource_id\":#{register.id}}"
    end
  end
end
