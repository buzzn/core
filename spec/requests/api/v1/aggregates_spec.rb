


  #   _____  _
  #  |  __ \(_)
  #  | |  | |_ ___  ___ _____   _____ _ __ __ _ _   _
  #  | |  | | / __|/ __/ _ \ \ / / _ \ '__/ _` | | | |
  #  | |__| | \__ \ (_| (_) \ V /  __/ | | (_| | |_| |
  #  |_____/|_|___/\___\___/ \_/ \___|_|  \__, |\__, |
  #                                        __/ | __/ |
  #                                       |___/ |___/


describe 'Discovergy' do
  describe "/api/v1/aggregate/present" do

    let(:discovergy_meter) do
      meter = Fabricate(:easymeter_60139082) # in_out meter
      DiscovergyBroker.create!(
        mode: :in,
        external_id: 'EASYMETER_' + meter.manufacturer_product_serialnumber,
        provider_login: 'team@localpool.de',
        provider_password: 'Zebulon_4711',
        resource: meter
      )
      meter
    end

    it 'does aggregate Discovergy power present for out register as admin' do |spec|
      VCR.use_cassette("request/api/v1/#{spec.metadata[:description].downcase}") do
        access_token = Fabricate(:full_access_token_as_admin)
        
        input_register  = discovergy_meter.registers.inputs.first
        output_register = discovergy_meter.registers.outputs.first

        request_params = {
          register_id: input_register.id
        }

        get_with_token "/api/v1/aggregates/present", request_params, access_token.token

        expect(response).to have_http_status(200)
        expect(json['readings'].count).to eq(1)
        expect(json['power_milliwatt']).to eq(932.0)

        request_params = {
          register_id: output_register.id
        }

        get_with_token "/api/v1/aggregates/present", request_params, access_token.token

        expect(response).to have_http_status(200)
        expect(json['readings'].count).to eq(1)
        expect(json['power_milliwatt']).to eq(0)
        Timecop.return
      end
    end

    it 'can not read data without permissions' do
      request_params = {
        register_id: discovergy_meter.registers.inputs.first.id
      }

       get_without_token '/api/v1/aggregates/present', request_params
       expect(response).to have_http_status(403)
    end
  end
end
