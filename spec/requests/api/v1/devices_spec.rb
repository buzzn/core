describe "Devices API" do

  [:no_access_token, :public_access_token, :full_access_token, :smartmeter_access_token].each do |token|

    it "does not get a device with #{token}" do
      device = Fabricate(:device)

      if token != :no_access_token
        access_token  = Fabricate(token)
        get_with_token "/api/v1/devices/#{device.id}", access_token.token
      else
        get_without_token "/api/v1/devices/#{device.id}"
      end

      expect(response).to have_http_status(403)
    end
    
    it "does not get any device with #{token}" do
      device = Fabricate(:device)

      if token != :no_access_token
        access_token  = Fabricate(token)
        get_with_token "/api/v1/devices", access_token.token
      else
        get_without_token "/api/v1/devices"
      end

      expect(response).to have_http_status(200)
      expect(json['data'].size).to eq 0
    end

    it "gets a device with metering_point with group with #{token}" do
      device = Fabricate(:out_device_with_metering_point_with_group)

      if token != :no_access_token
        access_token  = Fabricate(token)
        get_with_token "/api/v1/devices/#{device.id}", access_token.token
      else
        get_without_token "/api/v1/devices/#{device.id}"
      end

      expect(response).to have_http_status(200)
      expect(json['data']['id']).to eq device.id
    end

  end


  it "gets a device with full access token as admin" do
    access_token  = Fabricate(:full_access_token_as_admin)
    device = Fabricate(:device)
    get_with_token "/api/v1/devices/#{device.id}", access_token.token
    expect(response).to have_http_status(200)
  end


  it "gets a device with full access token as manager" do
    access_token  = Fabricate(:full_access_token)
    device = Fabricate(:device)
    user = User.find(access_token.resource_owner_id)
    user.add_role(:manager, device)

    get_with_token "/api/v1/devices/#{device.id}", access_token.token
    expect(response).to have_http_status(200)
  end


  it "does not get a device with full access token as member" do
    access_token  = Fabricate(:full_access_token)
    device = Fabricate(:device)
    user = User.find(access_token.resource_owner_id)
    user.add_role(:member, device)

    get_with_token "/api/v1/devices/#{device.id}", access_token.token
    expect(response).to have_http_status(403)
  end


  [:no_access_token, :public_access_token, :smartmeter_access_token].each do |token|
  
    it "does not creates a device with #{token}" do
      request_params = {}.to_json

      if token != :no_access_token
        access_token = Fabricate(token)
        post_with_token "/api/v1/devices", request_params, access_token.token
        expect(response).to have_http_status(403)
      else
        post_without_token "/api/v1/devices", request_params
        expect(response).to have_http_status(401)
      end

    end
  end

  it "creates a device with full_access_token" do
    device = Fabricate.build(:device)

    access_token = Fabricate(:full_access_token)

    request_params = {
      manufacturer_name:                  device.manufacturer_name,
      manufacturer_product_name:          device.manufacturer_product_name,
      manufacturer_product_serialnumber:  device.manufacturer_product_serialnumber,
      category:                           'Elektroauto',
      watt_peak:                          49000,
      mobile:                             false,
    }.to_json
    
    post_with_token "/api/v1/devices", request_params, access_token.token

    expect(response).to have_http_status(201)
    expect(response.headers['Location']).to eq json['data']['id']

    expect(json['data']['attributes']['manufacturer-name']).to eq(device.manufacturer_name)
    expect(json['data']['attributes']['manufacturer-product-name']).to eq(device.manufacturer_product_name)
    expect(json['data']['attributes']['manufacturer-product-serialnumber']).to eq(device.manufacturer_product_serialnumber)

    user = User.find(access_token.resource_owner_id)
    device = Device.find(json['data']['id'])
    expect(user.has_role?(:manager, device)).to eq true
  end

  it "does not create a device with validation errors" do
    device = Fabricate.build(:device)

    access_token = Fabricate(:full_access_token)

    request_params = {
      manufacturer_name:                  device.manufacturer_name,
      manufacturer_product_name:          device.manufacturer_product_name,
      manufacturer_product_serialnumber:  device.manufacturer_product_serialnumber,
      category:                           'Elektroauto',
      watt_peak:                          49000,
      mobile:                             false,
    }

    [:manufacturer_name, :manufacturer_product_name].each do |k|
      params = request_params.dup
      params[k] = 'a' * 2000

      post_with_token "/api/v1/devices", params.to_json, access_token.token

      expect(response).to have_http_status(422)
      json['errors'].each do |error|
        expect(error['source']['pointer']).to eq "/data/attributes/#{k}"
        expect(error['title']).to eq 'Invalid Attribute'
        expect(error['detail']).to eq "#{k} ist zu lang (mehr als 30 Zeichen)"
      end
    end
  end

  it "does not create a device with missing parameters" do
    device = Fabricate.build(:device)

    access_token = Fabricate(:full_access_token)

    request_params = {
      manufacturer_name:                  device.manufacturer_name,
      manufacturer_product_name:          device.manufacturer_product_name,
      manufacturer_product_serialnumber:  device.manufacturer_product_serialnumber,
      category:                           'Elektroauto',
      watt_peak:                          49000,
      mobile:                             false,
    }

    [:category, :watt_peak, :mobile].each do |name|
      params = request_params.dup
      params.delete(name)

      post_with_token "/api/v1/devices", params.to_json, access_token.token

      expect(response).to have_http_status(422)
      json['errors'].each do |error|
        expect(error['source']['pointer']).to eq "/data/attributes/#{name}"
        expect(error['title']).to eq 'Invalid Attribute'
        expect(error['detail']).to eq "#{name} is missing"
      end
    end
  end

  it "does not update a device with validation errors" do
    device = Fabricate(:device)

    access_token = Fabricate(:full_access_token_as_admin)

    [:manufacturer_name, :manufacturer_product_name].each do |k|
      params = { "#{k}": 'a' * 2000 }

      patch_with_token "/api/v1/devices/#{device.id}", params.to_json, access_token.token

      expect(response).to have_http_status(422)
      json['errors'].each do |error|
        expect(error['source']['pointer']).to eq "/data/attributes/#{k}"
        expect(error['title']).to eq 'Invalid Attribute'
        expect(error['detail']).to eq "#{k} ist zu lang (mehr als 30 Zeichen)"
      end
    end
  end

  [:no_access_token, :public_access_token, :full_access_token, :smartmeter_access_token].each do |token|

    it "does not update a device with #{token}" do
      device = Fabricate(:device)

      request_params = {}.to_json

      if token != :no_access_token
        access_token  = Fabricate(token)
        patch_with_token "/api/v1/devices/#{device.id}", access_token.token
        expect(response).to have_http_status(403)
      else
        patch_without_token "/api/v1/devices/#{device.id}", request_params
        expect(response).to have_http_status(401)
      end

    end
    
    it "does not delete a device with #{token}" do
      device = Fabricate(:device)

      if token != :no_access_token
        access_token  = Fabricate(token)
        delete_with_token "/api/v1/devices/#{device.id}", access_token.token
        expect(response).to have_http_status(403)
      else
        delete_without_token "/api/v1/devices/#{device.id}"
        expect(response).to have_http_status(401)
      end

    end

  end


  [:full_access_token_as_admin, :full_access_token].each do |token|

    it "updates a device with #{token}" do
      device = Fabricate(:device)
      access_token  = Fabricate(token)

       if token == :full_access_token
         user = User.find(access_token.resource_owner_id)
         user.add_role(:manager, device)
       end

      request_params = {
        id:                                 device.id,
        manufacturer_product_name:          "updated",
      }.to_json

      patch_with_token "/api/v1/devices/#{device.id}", request_params, access_token.token

      expect(response).to have_http_status(200)
      expect(json['data']['attributes']['manufacturer-name']).to eq(device.manufacturer_name)
      expect(json['data']['attributes']['manufacturer-product-name']).to eq("updated")
      expect(json['data']['attributes']['manufacturer-product-serialnumber']).to eq(device.manufacturer_product_serialnumber)
    end


    it "deletes a device with #{token}" do
       device = Fabricate(:device)
       access_token  = Fabricate(token)

       if token == :full_access_token
         user = User.find(access_token.resource_owner_id)
         user.add_role(:manager, device)
       end

       delete_with_token "/api/v1/devices/#{device.id}", access_token.token
       expect(response).to have_http_status(204)
    end

  end

end
