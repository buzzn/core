describe "smartmeter setup using API" do

  [:full_access_token, :smartmeter_access_token].each do |token|

    {
      #discovergy: { contract: :mpoc_justus, meter: :easymeter_1124001747 },
      # wrong_password: { orga: :discovergy, meter: :meter},
      # mysmartgrid: { contract: :mpoc_ferraris_0001_amperix, meter: :ferraris_001_amperix },
      # wrong_password: { orga: :mysmartgrid, meter: :meter},
      # TODO add mpoc_buzzn_metering
    }.each do |organization, meta|

      it "creates a register for #{meta[:orga] || organization} with #{meta[:contract] || 'no' } contract and #{token}" do |spec|
        VCR.use_cassette("api/v1/smartmeter_setup/#{spec.metadata[:description].downcase}") do
          orga         = Fabricate(meta[:orga] || organization)
          access_token = Fabricate(token)

          # create meter
          meter          = Fabricate.build(meta[:meter])
          request_params = meter.attributes.dup.compact.reject { |k,v| v.is_a? Boolean }
          post_with_token "/api/v1/meters", request_params.to_json, access_token.token
          expect(response).to have_http_status(201)
          meter_id = json['data']['id']

          # create register
          register = Fabricate.build(:register)
          request_params = {
            uid:  register.uid,
            mode: register.mode,
            readable: register.readable,
            name: register.name,
            meter_id: meter_id
          }.to_json
          post_with_token "/api/v1/registers", request_params, access_token.token
          expect(response).to have_http_status(201)
          register_id = json['data']['id']

          # create contract
          contract          = Fabricate.build(meta[:contract] || :contract)
          request_params    = contract.attributes.dup.compact.reject do |k,v|
            v.is_a?(DateTime) || k =~ /\Aprice/ ||
              ['running', 'valid_credentials'].include?(k)
          end
          request_params[:username]          = contract.username || 'user'
          request_params[:password]          = contract.password || 'pwd'
          request_params[:register_id] = register_id
          request_params[:organization_id]   = orga.id
          request_params[:mode]            ||= 'metering_point_operator_contract'
          post_with_token "/api/v1/contracts", request_params.to_json, access_token.token
          expect(response).to have_http_status(201)
          contract = Contract.find(json['data']['id'])
          expect(contract.valid_credentials).to eq !!(meta[:contract].to_s =~ /^mpoc_/)
        end
      end
    end
  end

end
