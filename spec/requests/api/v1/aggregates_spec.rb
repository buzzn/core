describe '/api/v1/aggregates' do

  let(:discovergy_meter) do
    meter = Fabricate(:easymeter_60139082) # in_out meter
    # TODO what to do with the in-out fact ?
    Fabricate(:discovergy_broker, resource: meter, external_id: "EASYMETER_60139082")
    meter
  end

  let(:slp_meter) do
    meter = Fabricate(:meter)

    meter
  end


  describe "/present" do


    it 'does aggregate slp present as admin' do
      access_token = Fabricate(:full_access_token_as_admin)
      meter = Fabricate(:input_meter_with_input_register)
      register = meter.registers.inputs.first

      energy_a_milliwatt_hour = 0
      timestamp = Time.find_zone('Berlin').local(2016,2,1)
      (24*4).times do |i|
        Fabricate(:reading,
          source: 'slp',
          timestamp: timestamp,
          energy_milliwatt_hour: energy_a_milliwatt_hour,
          power_milliwatt: 930*1000+i
        )
        energy_a_milliwatt_hour += 1300*1000
        timestamp += 15.minutes
      end

      Timecop.freeze(Time.find_zone('Berlin').local(2016,2,1, 1,30,1)) # 6*15 minutes and 1 seconds

      request_params = { register_ids: register.id }
      get_with_token "/api/v1/aggregates/present", request_params, access_token.token
      expect(response).to have_http_status(200)
      expect(json['readings'].count).to eq(1)
      expect(json['power_milliwatt']).to eq(930*1000 + 7)
      Timecop.return
    end




    it 'aggregates Discovergy power present for register as admin' do |spec|
      VCR.use_cassette("request/api/v1/#{spec.metadata[:description].downcase}") do
        time = Time.find_zone('Berlin').local(2016,2,1, 1,30,1)
        Timecop.freeze(time)

        access_token = Fabricate(:full_access_token_as_admin)

        input_register  = discovergy_meter.input_register
        output_register = discovergy_meter.output_register

        request_params = {
          register_ids: input_register.id
        }

        get_with_token "/api/v1/aggregates/present", request_params, access_token.token

        expect(response).to have_http_status(200)
        expect(json['readings'].count).to eq(1)
        expect(json['power_milliwatt']).to eq(932370)

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


    it 'not aggregates Discovergy power present for register readable_by friends as guest' do |spec|
      register = discovergy_meter.registers.inputs.first
      register.update_attribute(:readable, 'friends')

      request_params = { register_ids: register.id }
      get_without_token '/api/v1/aggregates/present', request_params
      expect(response).to have_http_status(403)
    end


    it 'aggregates Discovergy power present for register readable_by world as guest' do |spec|
      VCR.use_cassette("request/api/v1/#{spec.metadata[:description].downcase}") do
        register = discovergy_meter.registers.inputs.first
        register.update_attribute(:readable, 'world')

        request_params = { register_ids: register.id }
        get_without_token '/api/v1/aggregates/present', request_params
        expect(response).to have_http_status(200)
      end
    end


    it 'aggregates Discovergy power present readable_by friends with manager or members' do |spec|
      VCR.use_cassette("request/api/v1/#{spec.metadata[:description].downcase}") do

        register = discovergy_meter.registers.inputs.first
        register.update(readable: :friends)

        manager_token = Fabricate(:access_token_with_friend)
        manager_user  = User.find(manager_token.resource_owner_id)
        manager_user.add_role(:manager, register)

        manager_user_friend = manager_user.friends.first
        manager_friend_token = Fabricate(:simple_access_token, resource_owner_id: manager_user_friend.id)

        member_token = Fabricate(:simple_access_token)
        member_user = User.find(member_token.resource_owner_id)
        member_user.add_role(:member, register)

        request_params = { register_ids: register.id }

        get_with_token "/api/v1/aggregates/present", request_params, manager_token.token
        expect(response).to have_http_status(200)

        get_with_token "/api/v1/aggregates/present", request_params, member_token.token
        expect(response).to have_http_status(200)

        get_with_token "/api/v1/aggregates/present", request_params, manager_friend_token.token
        expect(response).to have_http_status(200)
      end
    end


  end



  describe "/past" do

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


    it 'not aggregates Discovergy energy past for register readable_by friends as guest' do |spec|
      register = discovergy_meter.registers.inputs.first

      request_params = { register_ids: register.id, resolution: :year_to_months }
      get_without_token '/api/v1/aggregates/past', request_params
      expect(response).to have_http_status(403)
    end


    it 'aggregates Discovergy energy past for register readable_by world as guest' do |spec|
      VCR.use_cassette("request/api/v1/#{spec.metadata[:description].downcase}") do
        register = discovergy_meter.registers.inputs.first
        register.update_attribute(:readable, 'world')

        request_params = { register_ids: register.id, resolution: :year_to_months }
        get_without_token '/api/v1/aggregates/past', request_params
        expect(response).to have_http_status(200)
      end
    end


  end
end
