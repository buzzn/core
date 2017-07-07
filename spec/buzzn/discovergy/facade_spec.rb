# coding: utf-8

describe Buzzn::Discovergy::Facade do

  before :each do
    t = Time.local(2016, 7, 2, 10, 5, 0)
    Timecop.travel(t)
  end

  after :each do
    Timecop.return
  end

  entity(:meter) { Fabricate(:meter, product_serialnumber: 60009485) }
  entity(:meter_2) { Fabricate(:meter, product_serialnumber: 60009272) }
  entity(:broker) { Fabricate(:discovergy_broker, mode: meter.registers.first.direction.sub(/put/, ''), resource: meter, external_id: "EASYMETER_#{meter.product_serialnumber}") }
  entity(:broker_with_wrong_token) { Fabricate(:discovergy_broker_with_wrong_token,  mode: meter_2.registers.first.direction.sub(/put/, ''), resource: meter_2, external_id: "EASYMETER_#{meter.product_serialnumber}") }
  entity(:meter_3) { Fabricate(:easymeter_60118460) }
  entity(:broker_virtual) { Fabricate(:discovergy_broker, mode: meter_3.registers.first.direction.sub(/put/, ''), resource: meter_3, external_id: "VIRTUAL_00000065") }
  entity(:group) do
    Fabricate(:tribe, registers: [
      meter_3.registers.first,
      Fabricate(:easymeter_60009441).registers.first,
      Fabricate(:easymeter_60009442).registers.first,
      Fabricate(:easymeter_60009393).registers.first
    ])
  end

  it 'registers application manually' do |spec|
    VCR.use_cassette("lib/buzzn/discovergy/#{spec.metadata[:description].downcase}") do
      facade = Buzzn::Discovergy::Facade.new
      key_secret = facade.register_application
      expect(key_secret.size).to eq 2
    end
  end

  it 'gets request token manually' do |spec|
    VCR.use_cassette("lib/buzzn/discovergy/#{spec.metadata[:description].downcase}") do
      facade = Buzzn::Discovergy::Facade.new
      key, secret = facade.register_application
      broker.consumer_key = key
      broker.consumer_secret = secret
      broker.save
      token = facade.get_request_token(broker)
      expect(token).not_to eq nil
    end
  end

  it 'gets request token manually with automatically registering the application' do |spec|
    VCR.use_cassette("lib/buzzn/discovergy/#{spec.metadata[:description].downcase}") do
      facade = Buzzn::Discovergy::Facade.new
      token = facade.get_request_token(broker)
      expect(broker.consumer_key).not_to eq nil
      expect(broker.consumer_secret).not_to eq nil
      expect(token).not_to eq nil
    end
  end

  it 'gets verifier manually' do |spec|
    VCR.use_cassette("lib/buzzn/discovergy/#{spec.metadata[:description].downcase}") do
      facade = Buzzn::Discovergy::Facade.new
      key, secret = facade.register_application
      broker.consumer_key = key
      broker.consumer_secret = secret
      broker.save
      request_token = facade.get_request_token(broker)
      verifier = facade.authorize(broker, request_token)
      expect(verifier).not_to eq nil
    end
  end

  it 'gets verifier manually with automatically registering the application' do |spec|
    VCR.use_cassette("lib/buzzn/discovergy/#{spec.metadata[:description].downcase}") do
      facade = Buzzn::Discovergy::Facade.new
      request_token = facade.get_request_token(broker)
      verifier = facade.authorize(broker, request_token)
      expect(verifier).not_to eq nil
    end
  end

  it 'gets access token with full process', retry: 3 do |spec|
    VCR.use_cassette("lib/buzzn/discovergy/#{spec.metadata[:description].downcase}") do
      facade = Buzzn::Discovergy::Facade.new
      access_token = facade.oauth1_process(broker)
      expect(access_token).not_to eq nil
    end
  end

  it 'gets access token with full process and saves it', retry: 3  do |spec|
    VCR.use_cassette("lib/buzzn/discovergy/#{spec.metadata[:description].downcase}") do
      facade = Buzzn::Discovergy::Facade.new
      access_token = facade.build_access_token_from_broker_or_new(broker)
      expect(access_token).not_to eq nil
      expect(access_token.token).to eq broker.provider_token_key
      expect(access_token.secret).to eq broker.provider_token_secret
    end
  end

  it 'gets readings', retry: 3 do |spec|
    VCR.use_cassette("lib/buzzn/discovergy/#{spec.metadata[:description].downcase}") do
      facade = Buzzn::Discovergy::Facade.new
      interval = Buzzn::Interval.day
      response = facade.readings(broker, interval, 'in')
      expect(response).not_to eq nil
      json = MultiJson.load(response)
      expect(json['time']).not_to eq nil
      expect(json['values']['power']).not_to eq nil
    end
  end

  it 'gets single reading' do |spec|
    VCR.use_cassette("lib/buzzn/discovergy/#{spec.metadata[:description].downcase}") do
      facade = Buzzn::Discovergy::Facade.new
      interval = Buzzn::Interval.second(Time.find_zone('Berlin').local(2016, 7, 1, 0, 0, 0))
      response = facade.readings(broker, interval, 'in')
      expect(response).not_to eq nil
      json = MultiJson.load(response)
      expect(json.first['time']).not_to eq nil
      expect(json.first['values']['energy']).not_to eq nil
    end
  end

  it 'builds access_token from hash' do |spec|
    VCR.use_cassette("lib/buzzn/discovergy/#{spec.metadata[:description].downcase}") do
      facade = Buzzn::Discovergy::Facade.new
      key, secret = facade.register_application
      broker_with_wrong_token.consumer_key = key
      broker_with_wrong_token.consumer_secret = secret
      broker_with_wrong_token.save
      access_token = facade.build_access_token_from_broker_or_new(broker_with_wrong_token)
      expect(access_token.token).to eq broker_with_wrong_token.provider_token_key
      expect(access_token.secret).to eq broker_with_wrong_token.provider_token_secret
    end
  end

  it 'gets virtual meter information' do |spec|
    VCR.use_cassette("lib/buzzn/discovergy/#{spec.metadata[:description].downcase}", :record => :new_episodes) do
      facade = Buzzn::Discovergy::Facade.new
      response = facade.virtual_meter_info(broker_virtual)
      expect(response.code).to eq '200'
      expect(response.body).not_to eq nil
      json = MultiJson.load(response.body)
      expect(json.size).to eq 3
      expect(json.first['location']['streetNumber']).to eq "51"
    end
  end

  it 'creates virtual meter for group', retry: 3 do |spec|
    VCR.use_cassette("lib/buzzn/discovergy/#{spec.metadata[:description].downcase}") do
      facade = Buzzn::Discovergy::Facade.new
      meter_ids_plus = group.registers.input.collect(&:meter).uniq.compact.collect(&:product_serialnumber).map{|s| 'EASYMETER_' + s}
      response = facade.create_virtual_meter(broker, meter_ids_plus)
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
