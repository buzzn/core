describe "Readings API" do

  # READ

  # [:no_access_token, :simple_access_token, :full_access_token, :smartmeter_access_token].each do |token|
  #
  #   it "does not get a reading with #{token}" do
  #     reading = Fabricate(:reading)
  #
  #     if token == :no_access_token
  #       get_without_token "/api/v1/readings/#{reading.id}"
  #       expect(response).to have_http_status(401)
  #     else
  #       access_token = Fabricate(token)
  #       get_with_token "/api/v1/readings/#{reading.id}", access_token.token
  #       expect(response).to have_http_status(403)
  #     end
  #   end
  #
  # end

  # it 'gets a reading with full access token as admin' do
  #   access_token  = Fabricate(:full_access_token_as_admin)
  #   reading       = Fabricate(:reading_with_easy_meter_q3d_and_input_register)
  #   get_with_token "/api/v1/readings/#{reading.id}", access_token.token
  #   expect(response).to have_http_status(200)
  # end

  it 'gets a reading with simple access token as manager' do
    reading       = Fabricate(:reading_with_easy_meter_q3d_with_input_register_and_manager)
    manager       = reading.meter.registers.first.managers.first
    access_token  = Fabricate(:simple_access_token, resource_owner_id: manager.id)
    get_with_token "/api/v1/readings/#{reading.id}", access_token.token
    expect(response).to have_http_status(200)
  end

  #
  # # CREATE
  #
  # it 'create a reading with smartmeter access token as manager' do
  #   meter         = Fabricate(:easy_meter_q3d_with_manager)
  #   manager       = meter.registers.first.managers.first
  #   access_token  = Fabricate(:smartmeter_access_token, resource_owner_id: manager.id)
  #   reading       = Fabricate.build(:reading)
  #   request_params = {
  #     meter_id: meter.id,
  #     timestamp: reading.timestamp,
  #     energy_a_milliwatt_hour: reading.energy_a_milliwatt_hour,
  #     energy_b_milliwatt_hour: reading.energy_b_milliwatt_hour,
  #     power_a_milliwatt: reading.power_a_milliwatt
  #   }.to_json
  #   post_with_token "/api/v1/readings", request_params, access_token.token
  #   expect(response).to have_http_status(201)
  #   expect(response.headers['Location']).to eq json['data']['id']
  #
  #   expect(DateTime.parse(json['data']['attributes']['timestamp'])).to eq(reading.timestamp)
  #   expect(json['data']['attributes']['energy-a-milliwatt-hour']).to eq(reading.energy_a_milliwatt_hour)
  #   expect(json['data']['attributes']['energy-b-milliwatt-hour']).to eq(reading.energy_b_milliwatt_hour)
  #   expect(json['data']['attributes']['power-a-milliwatt']).to eq(reading.power_a_milliwatt )
  # end
  #
  #
  #
  # it 'creates a correct reading with simple access token as manager' do
  #   meter         = Fabricate(:easy_meter_q3d_with_manager)
  #   manager       = meter.registers.first.managers.first
  #   access_token  = Fabricate(:full_access_token, resource_owner_id: manager.id)
  #
  #   timestamp = "Wed Apr 13 2016 14:07:35 GMT+0200 (CEST)"
  #   energy_a_milliwatt_hour = 80616
  #   power_a_milliwatt = 90
  #
  #   request_params = {
  #     meter_id: meter.id,
  #     timestamp: timestamp,
  #     energy_a_milliwatt_hour: energy_a_milliwatt_hour,
  #     power_a_milliwatt: power_a_milliwatt
  #   }.to_json
  #
  #   post_with_token "/api/v1/readings", request_params, access_token.token
  #   expect(response).to have_http_status(201)
  #   expect(response.headers['Location']).to eq json['data']['id']
  #
  #   expect(DateTime.parse(json['data']['attributes']['timestamp'])).to eq("Wed Apr 13 2016 14:07:35 GMT+0200 (CEST)")
  #   expect(json['data']['attributes']['energy-a-milliwatt-hour']).to eq(energy_a_milliwatt_hour)
  #   expect(json['data']['attributes']['power-a-milliwatt']).to eq(power_a_milliwatt)
  # end
  #
  #
  #
  # [:meter_id, :timestamp, :energy_a_milliwatt_hour,
  #  :power_a_milliwatt].each do |name|
  #
  #   it "does not create a reading without #{name}" do
  #     meter         = Fabricate(:easy_meter_q3d_with_manager)
  #     manager       = meter.registers.first.managers.first
  #     access_token  = Fabricate(:full_access_token, resource_owner_id: manager.id)
  #     reading       = Fabricate.build(:reading)
  #     request_params = {
  #       meter_id: meter.id,
  #       timestamp: reading.timestamp,
  #       energy_a_milliwatt_hour: reading.energy_a_milliwatt_hour,
  #       power_a_milliwatt: reading.power_a_milliwatt
  #     }.reject {|k,v| k == name}.to_json
  #
  #     post_with_token "/api/v1/readings", request_params, access_token.token
  #     expect(response).to have_http_status(422)
  #     json['errors'].each do |error|
  #       expect(error['source']['pointer']).to eq "/data/attributes/#{name}"
  #       expect(error['title']).to eq 'Invalid Attribute'
  #       expect(error['detail']).to eq "#{name} is missing"
  #     end
  #   end
  # end
  #
  #
  # xit 'does not update a reading' do
  # end
  #
  # xit 'does not delete a reading' do
  # end
  #



end
