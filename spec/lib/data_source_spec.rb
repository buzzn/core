# coding: utf-8
require 'buzzn/discovergy/data_source'

describe Buzzn::Discovergy::DataSource do
  let(:meter) { Fabricate(:meter, manufacturer_product_serialnumber: 60009485) }
  let(:broker) { Fabricate(:discovergy_broker, resource: meter, external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}") }
  let(:single_meter_live_response) { "{\"time\":1480606450088,\"values\":{\"power\":1100640}}" }
  let(:single_meter_hour_response) { "[{\"time\":1480604400205,\"values\":{\"power\":1760140}},{\"time\":1480604402205,\"values\":{\"power\":1750440}}]" }
  let(:single_meter_day_response) { "[{\"time\":1480606200000,\"values\":{\"energy\":22968322444644}},{\"time\":1480607100000,\"values\":{\"energy\":22970988922089}},{\"time\":1480608000000,\"values\":{\"energy\":22973229616478}}]" }
  let(:single_meter_month_response) { "[{\"time\":1477954800000,\"values\":{\"energy\":22202408932539}},{\"time\":1478041200000,\"values\":{\"energy\":22202747771000}},{\"time\":1478127600000,\"values\":{\"energy\":22202747771000}}]" }
  let(:single_meter_year_response) { "[{\"time\":1451602800000,\"values\":{\"energy\":14386541983000}},{\"time\":1454281200000,\"values\":{\"energy\":15127308929000}},{\"time\":1456786800000,\"values\":{\"energy\":15997907091031}}]" }
  let(:virtual_meter_live_response) { "{\"EASYMETER_60009425\":{\"time\":1480614249341,\"values\":{\"power\":150950}},\"EASYMETER_60009404\":{\"time\":1480614254195,\"values\":{\"power\":161590}},\"EASYMETER_60009415\":{\"time\":1480614254563,\"values\":{\"power\":152190}}}"}

  it 'parses single meter live response' do
    data_source = Buzzn::Discovergy::DataSource.new
    response = single_meter_live_response
    interval = Buzzn::Interval.live
    mode = 'in'
    two_way_meter = false
    external_id = broker.external_id
    result = data_source.parse_aggregated_data(response, interval, mode, two_way_meter, external_id)
    expect(result[0][0].timestamp).to eq 1480606450088
    expect(result[0][0].value).to eq 1100
  end

  it 'parses single meter hour response' do
    data_source = Buzzn::Discovergy::DataSource.new
    response = single_meter_hour_response
    interval = Buzzn::Interval.hour(Time.now.to_i*1000)
    mode = 'in'
    two_way_meter = false
    external_id = broker.external_id
    result = data_source.parse_aggregated_data(response, interval, mode, two_way_meter, external_id)
    expect(result[0][0].timestamp).to eq 1480604400205
    expect(result[0][0].value).to eq 1760140
    expect(result[0][1].timestamp).to eq 1480604402205
    expect(result[0][1].value).to eq 1750440
  end

  it 'parses single meter day response' do
    data_source = Buzzn::Discovergy::DataSource.new
    response = single_meter_day_response
    interval = Buzzn::Interval.day(Time.now.to_i*1000)
    mode = 'in'
    two_way_meter = false
    external_id = broker.external_id
    result = data_source.parse_aggregated_data(response, interval, mode, two_way_meter, external_id)
    expect(result[0][0].timestamp).to eq 1480606200000
    expect(result[0][0].value).to eq 1066590.978
    expect(result[0][1].timestamp).to eq 1480607100000
    expect(result[0][1].value).to eq 896277.7556
  end

  it 'parses single meter month response' do
    data_source = Buzzn::Discovergy::DataSource.new
    response = single_meter_month_response
    interval = Buzzn::Interval.month(Time.now.to_i*1000)
    mode = 'in'
    two_way_meter = false
    external_id = broker.external_id
    result = data_source.parse_aggregated_data(response, interval, mode, two_way_meter, external_id)
    expect(result[0][0].timestamp).to eq 1477954800000
    expect(result[0][0].value).to eq 33883.8461
    expect(result[0][1].timestamp).to eq 1478041200000
    expect(result[0][1].value).to eq 0.0
  end

  it 'parses single meter year response' do
    data_source = Buzzn::Discovergy::DataSource.new
    response = single_meter_year_response
    interval = Buzzn::Interval.year(Time.now.to_i*1000)
    mode = 'in'
    two_way_meter = false
    external_id = broker.external_id
    result = data_source.parse_aggregated_data(response, interval, mode, two_way_meter, external_id)
    expect(result[0][0].timestamp).to eq 1451602800000
    expect(result[0][0].value).to eq 74076694.6
    expect(result[0][1].timestamp).to eq 1454281200000
    expect(result[0][1].value).to eq 87059816.2031
  end

  it 'parses virtual meter live response for each meter' do
    data_source = Buzzn::Discovergy::DataSource.new
    response = virtual_meter_live_response
    interval = Buzzn::Interval.live
    mode = 'in'
    two_way_meter = false
    external_id = broker.external_id
    result = data_source.parse_collected_data(response, interval)
    expect(result[0][0].timestamp).to eq 1480614249341
    expect(result[0][0].value).to eq 150950
    expect(result[1][0].timestamp).to eq 1480614254195
    expect(result[1][0].value).to eq 161590
  end
end