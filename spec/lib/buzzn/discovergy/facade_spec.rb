# coding: utf-8
require 'buzzn/discovergy/facade'

describe Buzzn::Discovergy::Facade do

  # make this specific to be sure to have this set even when running manually via rspec - could be deleted if not needed anymore.
  before :all do
    t = Time.local(2016, 7, 2, 10, 5, 0)
    Timecop.travel(t)
  end

  let(:meter) { Fabricate(:meter, manufacturer_product_serialnumber: 60009485) }
  let(:meter_2) { Fabricate(:meter, manufacturer_product_serialnumber: 60009272) }
  let(:broker) { Fabricate(:discovergy_broker, resource: meter, external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}") }
  let(:broker_with_wrong_token) { Fabricate(:discovergy_broker_with_wrong_token, resource: meter_2, external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}") }
  let(:broker_virtual) { Fabricate(:discovergy_broker, resource: meter, external_id: "VIRTUAL_00000065") }
  let(:group) do
    Fabricate(:group, registers: [
      Fabricate(:register_60118460),
      Fabricate(:register_60009441),
      Fabricate(:register_60009442),
      Fabricate(:register_60009393)
    ])
  end

  it 'registers application manually' do |spec|
    VCR.use_cassette("lib/buzzn/discovergy/#{spec.metadata[:description].downcase}") do
      facade = Buzzn::Discovergy::Facade.new
      expect(facade.consumer_key).to eq nil
      facade.do_register_application
      expect(facade.consumer_key).not_to eq nil
    end
  end

  it 'gets request token manually' do |spec|
    VCR.use_cassette("lib/buzzn/discovergy/#{spec.metadata[:description].downcase}") do
      facade = Buzzn::Discovergy::Facade.new
      facade.do_register_application
      token = facade.do_get_request_token
      expect(token).not_to eq nil
    end
  end

  it 'gets request token manually with automatically registering the application' do |spec|
    VCR.use_cassette("lib/buzzn/discovergy/#{spec.metadata[:description].downcase}") do
      facade = Buzzn::Discovergy::Facade.new
      token = facade.do_get_request_token
      expect(facade.consumer_key).not_to eq nil
      expect(token).not_to eq nil
    end
  end

  it 'gets verifier manually' do |spec|
    VCR.use_cassette("lib/buzzn/discovergy/#{spec.metadata[:description].downcase}") do
      facade = Buzzn::Discovergy::Facade.new
      facade.do_register_application
      request_token = facade.do_get_request_token
      verifier = facade.do_authorize(request_token, broker.provider_login, broker.provider_password)
      expect(verifier).not_to eq nil
    end
  end

  it 'gets verifier manually with automatically registering the application' do |spec|
    VCR.use_cassette("lib/buzzn/discovergy/#{spec.metadata[:description].downcase}") do
      facade = Buzzn::Discovergy::Facade.new
      request_token = facade.do_get_request_token
      verifier = facade.do_authorize(request_token, broker.provider_login, broker.provider_password)
      expect(verifier).not_to eq nil
    end
  end

  it 'gets access token with full process' do |spec|
    VCR.use_cassette("lib/buzzn/discovergy/#{spec.metadata[:description].downcase}") do
      facade = Buzzn::Discovergy::Facade.new
      access_token = facade.oauth1_process(broker.provider_login, broker.provider_password)
      expect(access_token).not_to eq nil
    end
  end

  it 'gets access token with full process and saves it' do |spec|
    VCR.use_cassette("lib/buzzn/discovergy/#{spec.metadata[:description].downcase}") do
      facade = Buzzn::Discovergy::Facade.new
      access_token = facade.build_access_token_from_broker_or_new(broker)
      expect(access_token).not_to eq nil
      expect(access_token.token).to eq broker.provider_token_key
      expect(access_token.secret).to eq broker.provider_token_secret
    end
  end

  it 'gets readings' do |spec|
    VCR.use_cassette("lib/buzzn/discovergy/#{spec.metadata[:description].downcase}") do
      facade = Buzzn::Discovergy::Facade.new
      interval = Buzzn::Interval.day(Time.now.to_i*1000)
      response = facade.do_readings(broker, interval, 'in')
      expect(response.code).to eq '200'
      expect(response.body).not_to eq nil
      json = MultiJson.load(response.body)
      expect(json['time']).not_to eq nil
      expect(json['values']['power']).not_to eq nil
    end
  end

  it 'builds access_token from hash' do |spec|
    VCR.use_cassette("lib/buzzn/discovergy/#{spec.metadata[:description].downcase}") do
      facade = Buzzn::Discovergy::Facade.new
      facade.do_register_application
      access_token = facade.build_access_token_from_broker_or_new(broker_with_wrong_token)
      expect(access_token.token).to eq broker_with_wrong_token.provider_token_key
      expect(access_token.secret).to eq broker_with_wrong_token.provider_token_secret
    end
  end

  it 'gets virtual meter information' do |spec|
    VCR.use_cassette("lib/buzzn/discovergy/#{spec.metadata[:description].downcase}", :record => :new_episodes) do
      facade = Buzzn::Discovergy::Facade.new
      response = facade.do_virtual_meter_info(broker_virtual)
      expect(response.code).to eq '200'
      expect(response.body).not_to eq nil
      json = MultiJson.load(response.body)
      expect(json.size).to eq 3
      expect(json.first['location']['streetNumber']).to eq "51"
    end
  end

  it 'creates virtual meter for group' do |spec|
    VCR.use_cassette("lib/buzzn/discovergy/#{spec.metadata[:description].downcase}", :record => :new_episodes) do
      facade = Buzzn::Discovergy::Facade.new
      meter_ids_plus = group.registers.inputs.collect(&:meter).uniq.compact.collect(&:manufacturer_product_serialnumber).map{|s| 'EASYMETER_' + s}
      response = facade.do_create_virtual_meter(broker, meter_ids_plus)
      expect(response.code).to eq '200'
      expect(response.body).not_to eq nil
      json = MultiJson.load(response.body)
      expect(json['type']).to eq "VIRTUAL"
      expect(json['location']['streetNumber']).to eq "0"
    end
  end



  # TODO: I don't know how to test this
  xit 'increments throughput before methods'
  xit 'decrements throughput after methods'



end
