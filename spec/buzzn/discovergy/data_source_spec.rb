# coding: utf-8
describe Buzzn::Discovergy::DataSource do

  require 'broker/discovergy'
  class Broker::Discovergy
    def validates_credentials
    end
  end

  subject { Buzzn::Discovergy::DataSource.new }

  entity(:meter) { Fabricate(:meter, product_serialnumber: 60009485) }
  entity(:broker) { Fabricate(:discovergy_broker, mode: meter.registers.first.direction, resource: meter, external_id: "EASYMETER_#{meter.product_serialnumber}") }
  entity(:small_group) do
    Fabricate(:tribe, registers: [
                Fabricate(:easymeter_60009484).output_register,
                Fabricate(:easymeter_60009386).input_register])
  end
  entity(:group) do
    Fabricate(:tribe, registers: [
      Fabricate(:easymeter_60118470).output_register, #out
      Fabricate(:easymeter_60138947).output_register, #out
      Fabricate(:easymeter_60009422).input_register, #in
      Fabricate(:easymeter_60009425).input_register, #in
      Fabricate(:easymeter_60009405).input_register  #in
    ])
  end
  entity(:empty_group) { Fabricate(:tribe) }
  entity!(:register_with_broker) do
    meter = Fabricate(:meter, registers: [Fabricate.build(:input_register, group: empty_group)])
    Fabricate(:discovergy_broker, mode: 'in', resource: meter, external_id: 'easy_123')
    meter.input_register
  end
  entity!(:register_with_group_broker) do
    register = register_with_broker
    Fabricate(:discovergy_broker, resource: register.group, external_id: 'virtual_123')
    register
  end
  entity(:virtual_register) do
    register = Fabricate(:virtual_meter).register
    Fabricate(:fp_plus, operand: Fabricate(:input_meter).input_register,
              register: register)
    Fabricate(:discovergy_broker, mode: :virtual, resource: register.meter, external_id: 'virtual_123')
    Fabricate(:discovergy_broker, resource: register.formula_parts.first.operand.meter, external_id: 'easy_123')
    register
  end
  entity(:some_group) do
    some_group = Fabricate(:localpool)
    some_group.brokers << Fabricate(:discovergy_broker, mode: 'in', resource: some_group, external_id: "EASYMETER_12345678")
    some_group.registers << Fabricate(:input_meter).input_register
    some_group
  end
  entity(:single_meter_live_response) { "{\"time\":1480606450088,\"values\":{\"power\":1100640}}" }
  entity(:single_meter_second_response) { "[{\"time\":1480604400205,\"values\":{\"energy\":22968322444644}}]" }
  entity(:single_meter_hour_response) { "[{\"time\":1480604400205,\"values\":{\"power\":1760140}},{\"time\":1480604402205,\"values\":{\"power\":1750440}}]" }
  entity(:single_meter_day_response) { "[{\"time\":1480606200000,\"values\":{\"energy\":22968322444644}},{\"time\":1480607100000,\"values\":{\"energy\":22970988922089}},{\"time\":1480608000000,\"values\":{\"energy\":22973229616478}}]" }
  entity(:single_meter_month_response) { "[{\"time\":1477954800000,\"values\":{\"energy\":22202408932539}},{\"time\":1478041200000,\"values\":{\"energy\":22202747771000}},{\"time\":1478127600000,\"values\":{\"energy\":22202747771000}}]" }
  entity(:single_meter_year_response) { "[{\"time\":1451602800000,\"values\":{\"energy\":14386541983000}},{\"time\":1454281200000,\"values\":{\"energy\":15127308929000}},{\"time\":1456786800000,\"values\":{\"energy\":15997907091031}}]" }
  entity(:single_meter_year_response2) { "[{\"time\":1451602800000,\"values\":{\"energyOut\":14386541983000}},{\"time\":1454281200000,\"values\":{\"energyOut\":15127308929000}},{\"time\":1456786800000,\"values\":{\"energyOut\":15997907091031}}]" }
  entity(:virtual_meter_live_response) { "{\"EASYMETER_60009425\":{\"time\":1480614249341,\"values\":{\"power\":150950}},\"EASYMETER_60009404\":{\"time\":1480614254195,\"values\":{\"power\":161590}},\"EASYMETER_60009415\":{\"time\":1480614254563,\"values\":{\"power\":152190}}}"}
  entity(:virtual_meter_creation_response) { "{\"serialNumber\":\"00000065\",\"location\":{\"street\":\"Virtual\",\"streetNumber\":\"0\",\"zip\":\"00000\",\"city\":\"Virtual\",\"country\":\"DE\"},\"administrationNumber\":null,\"type\":\"VIRTUAL\",\"measurementType\":\"ELECTRICITY\",\"scalingFactor\":1,\"currentScalingFactor\":1,\"voltageScalingFactor\":1,\"internalMeters\":1,\"firstMeasurementTime\":-1,\"lastMeasurementTime\":-1}" }
  entity(:empty_response) { "[]" }

  it 'parses single meter live response' do
    response = single_meter_live_response
    mode = 'in'
    two_way_meter = false
    result = subject.send(:parse_aggregated_live, response, mode, two_way_meter, 'u-i-d')
    expect(result.timestamp).to eq 1480606450.088
    expect(result.value).to eq 1100640.0
  end

  it 'parses single meter second response' do
    response = single_meter_second_response
    interval = Buzzn::Interval.second(Time.at(1480604400.205))
    mode = 'in'
    two_way_meter = false
    result = subject.send(:parse_aggregated_data, response, interval, mode, two_way_meter, 'u-i-d')
    expect(result.in[0].timestamp).to eq 1480604400.205
    expect(result.in[0].value).to eq 2296832244.4644
  end

  it 'parses single meter hour response' do
    response = single_meter_hour_response
    interval = Buzzn::Interval.hour
    mode = 'in'
    two_way_meter = false
    result = subject.send(:parse_aggregated_data, response, interval, mode, two_way_meter, 'u-i-d')
    expect(result.in[0].timestamp).to eq 1480604400.205
    expect(result.in[0].value).to eq 1760140
    expect(result.in[1].timestamp).to eq 1480604402.205
    expect(result.in[1].value).to eq 1750440
  end

  it 'parses single meter day response' do
    response = single_meter_day_response
    interval = Buzzn::Interval.day
    mode = 'in'
    two_way_meter = false
    result = subject.send(:parse_aggregated_data, response, interval, mode, two_way_meter, 'u-i-d')
    expect(result.in[0].timestamp).to eq 1480606200
    expect(result.in[0].value).to eq 1066590.978
    expect(result.in[1].timestamp).to eq 1480607100
    expect(result.in[1].value).to eq 896277.7556
  end

  it 'parses single meter month response' do
    response = single_meter_month_response
    interval = Buzzn::Interval.month
    mode = 'in'
    two_way_meter = false
    result = subject.send(:parse_aggregated_data, response, interval, mode, two_way_meter, 'u-i-d')
    expect(result.in[0].timestamp).to eq 1477954800
    expect(result.in[0].value).to eq 33883.8461
    expect(result.in[1].timestamp).to eq 1478041200
    expect(result.in[1].value).to eq 0.0
  end

  it 'parses single meter year response' do
    data_source = Buzzn::Discovergy::DataSource.new
    response = single_meter_year_response
    interval = Buzzn::Interval.year
    mode = 'in'
    two_way_meter = false
    result = data_source.send(:parse_aggregated_data, response, interval, mode, two_way_meter, 'u-i-d')
    expect(result.in[0].timestamp).to eq 1451602800
    expect(result.in[0].value).to eq 74076694.6
    expect(result.in[1].timestamp).to eq 1454281200
    expect(result.in[1].value).to eq 87059816.2031
  end

  it 'parses empty response' do
    response = empty_response
    interval = Buzzn::Interval.year
    mode = 'in'
    two_way_meter = false
    result = subject.send(:parse_aggregated_data, response, interval, mode, two_way_meter, 'u-i-d')
    expect(result).to eq nil
  end

  it 'parses virtual meter live response for each meter' do
    response = virtual_meter_live_response
    mode = 'in'
    two_way_meter = false
    result = subject.send(:parse_collected_data, response, mode, 'EASYMETER_60009425' => 'some-uid', 'EASYMETER_60009404' => 'other-uid', 'EASYMETER_60009415' => 'last-uid')
    expect(result[0].timestamp).to eq 1480614249.341
    expect(result[0].value).to eq 150950
    expect(result[1].timestamp).to eq 1480614254.195
    expect(result[1].value).to eq 161590
    expect(result.size).to eq 3
    expect(result[0].resource_id).to eq 'some-uid'
    expect(result[1].resource_id).to eq 'other-uid'
    expect(result[2].resource_id).to eq 'last-uid'
  end

  it 'parses virtual meter creation response' do
    response = virtual_meter_creation_response
    mode = ['in', 'out'].sample
    resource = group
    resource.brokers.by_data_source(subject).each { |broker| broker.destroy }
    result = subject.send(:parse_virtual_meter_creation, response, mode, resource)
    expect(group.brokers.by_data_source(subject).size).to eq 1
  end

  it 'does not create virtual meters for small group' do
    brokers = subject.create_virtual_meters_for_group(small_group)
    expect(brokers).to eq []
  end

  it 'creates virtual meter for group' do |spec|
    VCR.use_cassette("lib/buzzn/discovergy/#{spec.metadata[:description].downcase}") do
      group.brokers.each{ |broker| broker.destroy }
      existing_broker = broker
      brokers = subject.create_virtual_meters_for_group(group)
      expect(brokers).not_to eq []
      expect(group.brokers.by_data_source(subject).size).to eq 2
    end
  end

  it 'maps the external id to register ids of group' do
    empty_group.registers.each do |register|
      register.group = nil if register != register_with_broker
    end
    map = subject.send(:to_map, register_with_group_broker.group)
    expect(map).to eq('easy_123' => register_with_broker.id)
  end

  it 'maps the external id to register ids' do
    group.registers.each do |register|
      register.group = nil if register != register_with_broker
    end
    map = subject.send(:to_map, virtual_register)
    expect(map).to eq('easy_123' => virtual_register.formula_parts.first.operand.id)
  end

  class FacadeMock
    attr_accessor :result

    def result= r
      @result = r
      @results = nil
    end

    def readings(*args)
      @results = @result.dup if @results.nil? || @results.empty?
      @results.shift
    end
  end

  entity(:facade) { FacadeMock.new }

  it 'collects data from each register without group broker' do
    data_source = Buzzn::Discovergy::DataSource.new(Redis.current, facade)
    facade.result = [single_meter_live_response]
    empty_group.brokers.each{ |broker| broker.destroy }

    in_result = data_source.collection(register_with_broker.group, 'in')
    out_result = data_source.collection(register_with_broker.group, 'out')

    expect(in_result.size).to eq 1
    expect(out_result.size).to eq 0
    expect(in_result.first.resource_id).to eq register_with_broker.id
  end

  it 'collects data from each register with group broker' do
    data_source = Buzzn::Discovergy::DataSource.new(Redis.current, facade)
    facade.result = [virtual_meter_live_response]

    in_result = data_source.collection(some_group, 'in')
    out_result = data_source.collection(some_group, 'out')

    expect(in_result.size).to eq 3
    expect(out_result.size).to eq 3

    # as the facade delivers the same results back for each mode
    expect(in_result.first.value).to eq out_result.first.value
    expect(in_result.first.timestamp).to eq out_result.first.timestamp
    expect(in_result.last.value).to eq out_result.last.value
    expect(in_result.last.timestamp).to eq out_result.last.timestamp
  end

  it 'data ranges from a group' do
    data_source = Buzzn::Discovergy::DataSource.new(Redis.current, facade)
    facade.result = [single_meter_year_response, single_meter_year_response2]

    in_result = data_source.aggregated(some_group, 'in', Buzzn::Interval.year)
    out_result = data_source.aggregated(some_group, 'out', Buzzn::Interval.year)

    expect(in_result.in.size).to eq 2
    expect(in_result.out.size).to eq 0
    # we have only one broker on the group,
    # i.e. only either in-results or out-results
    expect(out_result).to be_nil

    expect(in_result.resource_id).to eq some_group.id

    expect(in_result.units).to eq :milliwatt_hour
  end

  it 'data ranges from a register' do
    data_source = Buzzn::Discovergy::DataSource.new(Redis.current, facade)
    facade.result = [single_meter_hour_response]

    in_result = data_source.aggregated(register_with_broker, 'in', Buzzn::Interval.hour)
    out_result = data_source.aggregated(register_with_broker, 'out', Buzzn::Interval.hour)

    expect(in_result.in.size).to eq 2
    expect(in_result.out.size).to eq 0
    expect(out_result.in.size).to eq 0
    expect(out_result.out.size).to eq 2

    expect(in_result.resource_id).to eq register_with_broker.id
    expect(out_result.resource_id).to eq register_with_group_broker.id

    expect(in_result.units).to eq :milliwatt
    expect(out_result.units).to eq :milliwatt
  end
end
