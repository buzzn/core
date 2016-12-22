


  #   _____  _
  #  |  __ \(_)
  #  | |  | |_ ___  ___ _____   _____ _ __ __ _ _   _
  #  | |  | | / __|/ __/ _ \ \ / / _ \ '__/ _` | | | |
  #  | |__| | \__ \ (_| (_) \ V /  __/ | | (_| | |_| |
  #  |_____/|_|___/\___\___/ \_/ \___|_|  \__, |\__, |
  #                                        __/ | __/ |
  #                                       |___/ |___/


describe 'Discovergy' do

  let(:discovergy_meter) do
    meter = Fabricate(:easymeter_60139082) # in_out meter
    if meter.discovergy_broker.nil?
      DiscovergyBroker.create!(
        mode: :in,
        external_id: 'EASYMETER_' + meter.manufacturer_product_serialnumber,
        provider_login: 'team@localpool.de',
        provider_password: 'Zebulon_4711',
        resource: meter
      )
    end
    meter
  end

  describe "/api/v1/aggregate/present" do
    it 'aggregates Discovergy power present for register as admin' do |spec|
      VCR.use_cassette("request/api/v1/#{spec.metadata[:description].downcase}") do
        time = Time.find_zone('Berlin').local(2016,2,1, 1,30,1)
        Timecop.freeze(time)

        access_token = Fabricate(:full_access_token_as_admin)

        input_register  = discovergy_meter.registers.inputs.first
        output_register = discovergy_meter.registers.outputs.first

        request_params = {
          register_ids: input_register.id
        }

        get_with_token "/api/v1/aggregates/present", request_params, access_token.token

        expect(response).to have_http_status(200)
        expect(json['readings'].count).to eq(1)
        expect(json['power_milliwatt']).to eq(932000)

        request_params = {
          register_ids: output_register.id
        }

        get_with_token "/api/v1/aggregates/present", request_params, access_token.token

        expect(response).to have_http_status(200)
        expect(json['readings'].count).to eq(1)
        expect(json['power_milliwatt']).to eq(0)
        expect(response.headers['Expires']).not_to be_nil
        expect(response.headers['Cache-Control']).to eq "private, max-age=15"
        expect(response.headers['ETag']).not_to be_nil
        expect(response.headers['Last-Modified']).not_to be_nil

        request_params = {
          register_ids: output_register.id,
          timestamp: time
        }

        get_with_token "/api/v1/aggregates/present", request_params, access_token.token

        expect(response).to have_http_status(200)
        expect(json['readings'].count).to eq(1)
        expect(json['power_milliwatt']).to eq(0)
        expect(response.headers['Expires']).to be_nil
        expect(response.headers['Cache-Control']).not_to be_nil
        expect(response.headers['Last-Modified']).to be_nil
        expect(response.headers['ETag']).not_to be_nil
        Timecop.return
      end
    end

    it 'can not read data without permissions' do
      request_params = {
        register_ids: discovergy_meter.registers.inputs.first.id
      }

       get_without_token '/api/v1/aggregates/present', request_params
       expect(response).to have_http_status(403)
    end
  end

  describe "/api/v1/aggregate/past" do

    it 'aggregates Discovergy power past for register as admin' do |spec|
      VCR.use_cassette("request/api/v1/#{spec.metadata[:description].downcase}") do
        time = Time.find_zone('Berlin').local(2016,2,1, 1,30,1)
        Timecop.freeze(time)

        access_token = Fabricate(:full_access_token_as_admin)

        input_register  = discovergy_meter.registers.inputs.first
        output_register = discovergy_meter.registers.outputs.first

        request_params = {
          register_ids: input_register.id,
          resolution: :day_to_minutes
        }

        get_with_token "/api/v1/aggregates/past", request_params, access_token.token

        expect(response).to have_http_status(200)
        expect(json.size).to eq(1)
        expect(json[0]['power_milliwatt']).to eq(0)

        request_params = {
          register_ids: output_register.id,
          resolution: :day_to_minutes
        }

        get_with_token "/api/v1/aggregates/past", request_params, access_token.token

        expect(response).to have_http_status(200)
        expect(json.size).to eq(1)
        expect(json[0]['power_milliwatt']).to eq(0)

        request_params = {
          register_ids: output_register.id,
          resolution: :day_to_minutes,
          timestamp: time
        }

        get_with_token "/api/v1/aggregates/past", request_params, access_token.token

        expect(response).to have_http_status(200)
        expect(json.size).to eq(1)
        expect(json[0]['power_milliwatt']).to eq(0)
        Timecop.return
      end
    end

    it 'can not read data without permissions' do
      request_params = {
        register_ids: discovergy_meter.registers.inputs.first.id,
        resolution: :year_to_months
      }

       get_without_token '/api/v1/aggregates/past', request_params
       expect(response).to have_http_status(403)
    end
  end
end
