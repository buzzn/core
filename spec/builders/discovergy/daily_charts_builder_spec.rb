require 'buzzn/builders/discovergy/daily_charts_builder'

describe Builders::Discovergy::DailyChartsBuilder do

  entity(:response) do
    JSON.parse(File.read(File.join(File.dirname(__FILE__), 'daily_charts_three.json')))
  end

  entity(:group) { create(:localpool) }

  entity(:registers) do
    response.collect do |id, _|
      direction, label =
        if id == 'EASYMETER_60327687'
          [:output, Register::Base.labels['production_pv']]
        else
          [:input, Register::Base.labels['consumption']]
        end
      meter = create(:meter, :real, :connected_to_discovergy,
                     group: group,
                     register_direction: direction,
                     product_serialnumber: id.sub('EASYMETER_', ''))
      register = meter.registers.first
      register.update(label: label)
      register
    end
  end

  let(:subject) { Builders::Discovergy::DailyChartsBuilder.new(registers: registers) }

  let(:expected_production) do
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 65, 67, 71, 62, 91, 128, 114, 114, 109, 101, 98, 99, 113, 138, 164, 195, 177, 194, 256, 277, 287, 307, 335, 333, 388, 370, 355, 351, 350, 396, 438, 473, 485, 468, 429, 435, 393, 393, 368, 340, 334, 298, 288, 288, 308, 307, 331, 316, 310, 307, 303, 315, 348, 378, 386, 394, 402, 395, 428, 444, 444, 441, 470, 472, 450, 432, 417, 406, 370, 333, 306, 290, 292, 264, 248, 238, 232, 243, 271, 309, 341, 336, 287, 262, 229, 212, 223, 223, 251, 270, 271, 245, 226, 204, 166, 161, 189, 240, 305, 344, 392, 399, 381, 347, 307, 278, 290, 264, 257, 326, 357, 335, 361, 357, 327, 328, 261, 186, 165, 153, 146, 145, 131, 105, 124, 113, 86, 44, 39, 43, 33, 31, 16, 8, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  end

  it 'builds response' do
    result_single = subject.build(response.slice('EASYMETER_60327687'))
    result_all = subject.build(response)

    expect(result_all[:production]).to eq result_single[:production]
    expect(result_all[:production][:data].values).to eq expected_production

    expect(result_single[:consumption][:data].size).to eq 0
    expect(result_all[:consumption][:data].size).to eq 347

    expect(result_all[:consumption][:total]).to eq 31004
    expect(result_all[:production][:total]).to eq 1816

    expect(result_single[:consumption][:total]).to eq 0
    expect(result_single[:production][:total]).to eq 1816
  end

  it 'build response when an array is bigger then other' do
    easy = response['EASYMETER_60327606']
    last = easy.last

    begin
      easy << { 'time' => last['time'] + 18000, 'values' => { 'energyOut' => 0, 'energy' => last['values']['energy'] + 123 } }

      result = subject.build(response)
    ensure
      easy.delete(easy.last)
    end

    expect(result[:consumption][:data].size).to eq 347
    expect(result[:production][:data].size).to eq 347

    expect(result[:consumption][:total]).to eq 31004
    expect(result[:production][:total]).to eq 1816
  end
end
