require 'buzzn/builders/discovergy/substitute_ticker_builder'

describe Builders::Discovergy::SubstituteTickerBuilder do

  def self.load_json(file)
    JSON.parse(File.read(File.join(File.dirname(__FILE__), file)))
  end

  entity(:response) do
    load_json('last_readings.json')
  end

  entity(:group) { create(:group, :localpool) }

  entity!(:registers) do
    labels_map = load_json('labels.json')
    labels_map.each do |serial, labels|
      registers =
        if labels.size == 1
          [build(:register, :real, labels.first.to_sym)]
        else
          [build(:register, :real, :grid_consumption),
           build(:register, :real, :grid_feeding)]
        end
      create(:meter, :real,
             group: group,
             registers: registers,
             product_serialnumber: serial)
    end
    substitute
    group.registers
  end

  entity(:substitute) do
    meter = create(:meter, :virtual,
                   group: group,
                   registers: [build(:register, :substitute)])
    meter.registers.first
  end

  context 'watt' do
    subject(:builder) { Builders::Discovergy::SubstituteTickerBuilder.new(register: substitute, unit: :W, registers: registers) }

    it 'grid-feeding' do
      result = builder.build(response)
      # these are real numbers and timestamps are not uniform, i.e. some
      # small value close to zero is (maybe) OK
      expect(result.value).to eq 7029
    end

    it 'no grid-feeding and no grid-consumption' do
      res = response.dup
      res['EASYMETER_60099324'] = {'time' => 1519218309318, 'values' => {'power'=>0}}
      result = builder.build(res)
      expect(result.value).to eq 3525
    end

    it 'grid-consumption' do
      val = response['EASYMETER_60099324']['values']['power']
      res = response.dup
      res['EASYMETER_60099324'] = {'time' => 1519218309318, 'values' => {'power' => -val}}
      result = builder.build(res)
      expect(result.value).to eq 21
    end
  end
  context 'watt-hour' do
    subject(:builder) { Builders::Discovergy::SubstituteTickerBuilder.new(register: substitute, unit: :Wh, registers: registers) }

    it do
      result = builder.build(response)
      expect(result.value).to eq 97303533
    end
  end
end
