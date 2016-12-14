# coding: utf-8
require 'buzzn/discovergy/data_source'

describe Buzzn::Discovergy::DataSource do
  let(:meter) { Fabricate(:meter, manufacturer_product_serialnumber: 60009485) }
  let(:broker) { Fabricate(:discovergy_broker, resource: meter, external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}") }
  let(:small_group) { Fabricate(:group, registers: [Fabricate(:register_60118460), Fabricate(:register_60009441)]) }
  let(:group) do
    Fabricate(:group, registers: [
      Fabricate(:register_60118470), #out
      Fabricate(:register_60118460), #out
      Fabricate(:register_60009441), #in
      Fabricate(:register_60009442), #in
      Fabricate(:register_60009393)  #in
    ])
  end
  let(:single_meter_live_response) { "{\"time\":1480606450088,\"values\":{\"power\":1100640}}" }
  let(:single_meter_hour_response) { "[{\"time\":1480604400205,\"values\":{\"power\":1760140}},{\"time\":1480604402205,\"values\":{\"power\":1750440}}]" }
  let(:single_meter_day_response) { "[{\"time\":1480606200000,\"values\":{\"energy\":22968322444644}},{\"time\":1480607100000,\"values\":{\"energy\":22970988922089}},{\"time\":1480608000000,\"values\":{\"energy\":22973229616478}}]" }
  let(:single_meter_month_response) { "[{\"time\":1477954800000,\"values\":{\"energy\":22202408932539}},{\"time\":1478041200000,\"values\":{\"energy\":22202747771000}},{\"time\":1478127600000,\"values\":{\"energy\":22202747771000}}]" }
  let(:single_meter_year_response) { "[{\"time\":1451602800000,\"values\":{\"energy\":14386541983000}},{\"time\":1454281200000,\"values\":{\"energy\":15127308929000}},{\"time\":1456786800000,\"values\":{\"energy\":15997907091031}}]" }
  let(:virtual_meter_live_response) { "{\"EASYMETER_60009425\":{\"time\":1480614249341,\"values\":{\"power\":150950}},\"EASYMETER_60009404\":{\"time\":1480614254195,\"values\":{\"power\":161590}},\"EASYMETER_60009415\":{\"time\":1480614254563,\"values\":{\"power\":152190}}}"}
  let(:virtual_meter_creation_response) { "{\"serialNumber\":\"00000065\",\"location\":{\"street\":\"Virtual\",\"streetNumber\":\"0\",\"zip\":\"00000\",\"city\":\"Virtual\",\"country\":\"DE\"},\"administrationNumber\":null,\"type\":\"VIRTUAL\",\"measurementType\":\"ELECTRICITY\",\"scalingFactor\":1,\"currentScalingFactor\":1,\"voltageScalingFactor\":1,\"internalMeters\":1,\"firstMeasurementTime\":-1,\"lastMeasurementTime\":-1}" }
  let(:empty_response) { "[]" }

  it 'parses single meter live response' do
    data_source = Buzzn::Discovergy::DataSource.new
    response = single_meter_live_response
    mode = :in
    two_way_meter = false
    result = data_source.send(:parse_aggregated_live, response, mode, two_way_meter, 'u-i-d')
    expect(result.timestamp).to eq Time.at(1480606450.088)
    expect(result.value).to eq 1100
  end

  it 'parses single meter hour response' do
    data_source = Buzzn::Discovergy::DataSource.new
    response = single_meter_hour_response
    interval = Buzzn::Interval.hour(Time.now.to_i*1000)
    mode = :in
    two_way_meter = false
    result = data_source.send(:parse_aggregated_data, response, interval, mode, two_way_meter, 'u-i-d')
    expect(result.in[0].timestamp).to eq Time.at(1480604400.205)
    expect(result.in[0].value).to eq 1760140
    expect(result.in[1].timestamp).to eq Time.at(1480604402.205)
    expect(result.in[1].value).to eq 1750440
  end

  it 'parses single meter day response' do
    data_source = Buzzn::Discovergy::DataSource.new
    response = single_meter_day_response
    interval = Buzzn::Interval.day(Time.now.to_i*1000)
    mode = :in
    two_way_meter = false
    result = data_source.send(:parse_aggregated_data, response, interval, mode, two_way_meter, 'u-i-d')
    expect(result.in[0].timestamp).to eq Time.at(1480606200)
    expect(result.in[0].value).to eq 1066590.978
    expect(result.in[1].timestamp).to eq Time.at(1480607100)
    expect(result.in[1].value).to eq 896277.7556
  end

  it 'parses single meter month response' do
    data_source = Buzzn::Discovergy::DataSource.new
    response = single_meter_month_response
    interval = Buzzn::Interval.month(Time.now.to_i*1000)
    mode = :in
    two_way_meter = false
    result = data_source.send(:parse_aggregated_data, response, interval, mode, two_way_meter, 'u-i-d')
    expect(result.in[0].timestamp).to eq Time.at(1477954800)
    expect(result.in[0].value).to eq 33883.8461
    expect(result.in[1].timestamp).to eq Time.at(1478041200)
    expect(result.in[1].value).to eq 0.0
  end

  it 'parses single meter year response' do
    data_source = Buzzn::Discovergy::DataSource.new
    response = single_meter_year_response
    interval = Buzzn::Interval.year(Time.now.to_i*1000)
    mode = :in
    two_way_meter = false
    result = data_source.send(:parse_aggregated_data, response, interval, mode, two_way_meter, 'u-i-d')
    expect(result.in[0].timestamp).to eq Time.at(1451602800)
    expect(result.in[0].value).to eq 74076694.6
    expect(result.in[1].timestamp).to eq Time.at(1454281200)
    expect(result.in[1].value).to eq 87059816.2031
  end

  it 'parses empty response' do
    data_source = Buzzn::Discovergy::DataSource.new
    response = empty_response
    interval = Buzzn::Interval.year(Time.now.to_i*1000)
    mode = 'in'
    two_way_meter = false
    result = data_source.send(:parse_aggregated_data, response, interval, mode, two_way_meter, 'u-i-d')
    expect(result).to eq nil
  end

  it 'parses virtual meter live response for each meter' do
    data_source = Buzzn::Discovergy::DataSource.new
    response = virtual_meter_live_response
    mode = :in
    two_way_meter = false
    external_id = broker.external_id
    result = data_source.send(:parse_collected_data, response, mode, 'EASYMETER_60009425' => 'some-uid', 'EASYMETER_60009404' => 'other-uid', 'EASYMETER_60009415' => 'last-uid')
    expect(result[0].timestamp).to eq Time.at(1480614249.341)
    expect(result[0].value).to eq 150950
    expect(result[1].timestamp).to eq Time.at(1480614254.195)
    expect(result[1].value).to eq 161590
    expect(result.size).to eq 3
    expect(result[0].resource_id).to eq 'some-uid'
    expect(result[1].resource_id).to eq 'other-uid'
    expect(result[2].resource_id).to eq 'last-uid'
  end

  it 'parses virtual meter creation response' do
    data_source = Buzzn::Discovergy::DataSource.new
    response = virtual_meter_creation_response
    mode = 'virtual'
    resource = group
    result = data_source.send(:parse_virtual_meter_creation, response, mode, resource)
    expect(group.discovergy_brokers.size).to eq 1
  end

  it 'does not create virtual meters for small group' do
    data_source = Buzzn::Discovergy::DataSource.new
    brokers = data_source.create_virtual_meters_for_group(small_group)
    expect(brokers).to eq []
  end

  it 'creates virtual meter for group' do |spec|
    VCR.use_cassette("lib/buzzn/discovergy/#{spec.metadata[:description].downcase}") do
      existing_broker = broker
      data_source = Buzzn::Discovergy::DataSource.new
      brokers = data_source.create_virtual_meters_for_group(group)
      expect(brokers).not_to eq []
      expect(group.discovergy_brokers.size).to eq 2
    end
  end



  subject { Buzzn::Discovergy::DataSource.new }

  it 'maps the external id to register ids of group' do
    group = Fabricate(:group)
    Fabricate(:discovergy_broker, resource: group, external_id: 'virtual_123')
    register = Fabricate(:input_register, group: group, meter: Fabricate(:meter))
    Fabricate(:discovergy_broker, resource: register.meter, external_id: 'easy_123')
    map = subject.send(:to_map, group)
    expect(map).to eq('easy_123' => register.id)
  end

  it 'maps the external id to register ids' do
    meter = Fabricate(:meter)
    register = Fabricate(:input_register,
                         meter: Fabricate(:meter),
                         virtual: true, 
                         formula_parts: [Fabricate(:fp_plus, operand: Fabricate(:input_register, meter: meter))])
    Fabricate(:discovergy_broker, resource: register.meter, external_id: 'virtual_123')
    
    Fabricate(:discovergy_broker, resource: register.formula_parts.first.operand.meter, external_id: 'easy_123')
    
    
    map = subject.send(:to_map, register)
    expect(map).to eq('easy_123' => register.formula_parts.first.operand.id)
  end
end
