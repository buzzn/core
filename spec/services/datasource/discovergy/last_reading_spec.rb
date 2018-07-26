require_relative 'api_mock'

describe Services::Datasource::Discovergy::OptimizedGroup do

  def serialized_last_reading(power, energy, energy_out = nil)
    json = {
      time: 1513324966440,
      values: {
        power: power,
        energy: energy
      }
    }
    json[:values][:energyOut] = energy_out if energy_out
    json
  end

  let(:two_way_meter_result) do
    serialized_last_reading(-58500, 183082318054500, 105450808714000)
  end

  let(:one_way_meter_result) do
    serialized_last_reading(12502630, 38236685426000, 0)
  end

  let(:broken_meter_result) do
    ''
  end

  entity(:api) { ApiMock.new }

  entity(:meter) { create(:meter, :real, :connected_to_discovergy) }
  entity(:register) { meter.registers.first }

  entity(:last_readings) do
    Services::Datasource::Discovergy::LastReading.new(api: api)
  end

  context 'one-way-meter' do

    before { api.result = one_way_meter_result }

    it 'power' do
      result = last_readings.power(register)
      expect(result.values[:power]).to eq 12502630
      expect(api.query).to eq "/last_reading?meterId=EASYMETER_#{meter.product_serialnumber}&fields=power&each=false"
    end

    it 'energy' do
      result = last_readings.energy(register)
      expect(result.values[:energy]).to eq 38236685426000
      expect(result.values[:energyOut]).to eq 0
      expect(api.query).to eq "/last_reading?meterId=EASYMETER_#{meter.product_serialnumber}&fields=energy,energyOut&each=false"
    end
  end

  context 'two-way-meter' do

    entity!(:register2) { create(:register, :real, :production_pv, meter: meter) }

    before { api.result = two_way_meter_result }

    [:consumption, :production].each do |type|

      context type do
        it 'power' do
          register = meter.registers.select { |r| r.send("#{type}?") }.first
          result = last_readings.power(register)
          expect(result.values[:power]).to eq -58500
          expect(api.query).to eq "/last_reading?meterId=EASYMETER_#{meter.product_serialnumber}&fields=power&each=false"
        end

        it 'energy' do
          register = meter.registers.select { |r| r.send("#{type}?") }.first
          result = last_readings.energy(register)
          expect(result.values[:energy]).to eq 183082318054500
          expect(result.values[:energyOut]).to eq 105450808714000
          expect(api.query).to eq "/last_reading?meterId=EASYMETER_#{meter.product_serialnumber}&fields=energy,energyOut&each=false"
        end
      end
    end
  end

  context 'broken response' do

    before { api.result = broken_meter_result }

    it 'power' do
      expect(last_readings.power(register)).to eq ''
    end

    it 'energy' do
      expect(last_readings.energy(register)).to eq ''
    end
  end
end
