require 'buzzn/discovergy/bubble_builder'

describe Discovergy::BubbleBuilder do

  def self.load_json(file)
    JSON.parse(File.read(File.join(File.dirname(__FILE__), file)))
  end

  entity(:response) do
    load_json('last_readings.json')
  end

  entity(:group) { create(:localpool) }

  entity!(:registers) do
    labels_map = load_json('labels.json')
    labels_map.each do |serial, labels|
      registers =
        if labels.size == 1
          [build(:register, :real, label: labels.first)]
        else
          [build(:register, :real, :input, label: :grid_consumption),
           build(:register, :real, :output, label: :grid_feeding)]
        end
      create(:meter, :real,
             group: group,
             registers: registers,
             product_serialnumber: serial)
    end
    group.registers
  end

  context 'without substitute' do

    subject(:builder) { Discovergy::BubbleBuilder.new(registers: registers) }

    let(:expected_values) { [190, 58, 0, 9, 3957, 157, 14] }

    it do
      result = builder.build(response)
      expect(result.size).to eq 7
      expect(result.collect(&:value)).to eq(expected_values)
    end

    context 'with substitute' do

      subject(:builder) { Discovergy::BubbleBuilder.new(registers: group.registers.reload) }

      before do
        meter = create(:meter, :virtual,
                       group: group,
                       registers: [build(:register, :substitute)])
        meter.registers.first
      end

      it do
        result = builder.build(response)
        expect(result.size).to eq 8
        expect(result.collect(&:value)).to eq(expected_values + [21])
      end
    end
  end
end
