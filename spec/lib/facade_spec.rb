# coding: utf-8
require 'buzzn/discovergy/facade'

describe Buzzn::Discovergy::Facade do

  let(:meter) { Fabricate(:meter, manufacturer_product_serialnumber: 60009485) }
  let(:meter_2) { Fabricate(:meter, manufacturer_product_serialnumber: 60009272) }
  let(:broker) { Fabricate(:discovergy_broker, resource: meter, external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}") }
  let(:broker_with_wrong_token) { Fabricate(:discovergy_broker_with_wrong_token, resource: meter_2, external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}") }

  it 'registers application manually' do |spec|
    VCR.use_cassette("lib/buzzn/discovergy/#{spec.metadata[:description].downcase}", :record => :new_episodes) do
      facade = Buzzn::Discovergy::Facade.new
      expect(facade.consumer_key).to eq nil
      facade.do_register_application
      expect(facade.consumer_key).not_to eq nil
    end
  end

  it 'gets request token manually' do |spec|
    VCR.use_cassette("lib/buzzn/discovergy/#{spec.metadata[:description].downcase}", :record => :new_episodes) do
      facade = Buzzn::Discovergy::Facade.new
      facade.do_register_application
      token = facade.do_get_request_token
      expect(token).not_to eq nil
    end
  end

  it 'gets request token manually with automatically registering the application' do |spec|
    VCR.use_cassette("lib/buzzn/discovergy/#{spec.metadata[:description].downcase}", :record => :new_episodes) do
      facade = Buzzn::Discovergy::Facade.new
      token = facade.do_get_request_token
      expect(facade.consumer_key).not_to eq nil
      expect(token).not_to eq nil
    end
  end

  it 'gets verifier manually' do |spec|
    VCR.use_cassette("lib/buzzn/discovergy/#{spec.metadata[:description].downcase}", :record => :new_episodes) do
      facade = Buzzn::Discovergy::Facade.new
      facade.do_register_application
      request_token = facade.do_get_request_token
      verifier = facade.do_authorize(request_token, broker.provider_login, broker.provider_password)
      expect(verifier).not_to eq nil
    end
  end

  it 'gets verifier manually with automatically registering the application' do |spec|
    VCR.use_cassette("lib/buzzn/discovergy/#{spec.metadata[:description].downcase}", :record => :new_episodes) do
      facade = Buzzn::Discovergy::Facade.new
      request_token = facade.do_get_request_token
      verifier = facade.do_authorize(request_token, broker.provider_login, broker.provider_password)
      expect(verifier).not_to eq nil
    end
  end

  it 'gets access token with full process' do |spec|
    VCR.use_cassette("lib/buzzn/discovergy/#{spec.metadata[:description].downcase}", :record => :new_episodes) do
      facade = Buzzn::Discovergy::Facade.new
      access_token = facade.oauth1_process(broker.provider_login, broker.provider_password)
      expect(access_token).not_to eq nil
    end
  end

  it 'gets access token with full process and saves it' do |spec|
    VCR.use_cassette("lib/buzzn/discovergy/#{spec.metadata[:description].downcase}", :record => :new_episodes) do
      facade = Buzzn::Discovergy::Facade.new
      access_token = facade.build_access_token_from_broker_or_new(broker)
      expect(access_token).not_to eq nil
      expect(access_token.token).to eq broker.provider_token_key
      expect(access_token.secret).to eq broker.provider_token_secret
    end
  end

  it 'gets readings' do |spec|
    VCR.use_cassette("lib/buzzn/discovergy/#{spec.metadata[:description].downcase}", :record => :new_episodes) do
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
    VCR.use_cassette("lib/buzzn/discovergy/#{spec.metadata[:description].downcase}", :record => :new_episodes) do
      facade = Buzzn::Discovergy::Facade.new
      facade.do_register_application
      access_token = facade.build_access_token_from_broker_or_new(broker_with_wrong_token)
      expect(access_token.token).to eq broker_with_wrong_token.provider_token_key
      expect(access_token.secret).to eq broker_with_wrong_token.provider_token_secret
    end
  end

  # TODO: I don't know to test this
  xit 'increments throughput before methods'
  xit 'decrements throughput after methods'



end