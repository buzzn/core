describe "Meters API" do


  [:no_access_token,
   :public_access_token,
   :smartmeter_access_token].each do |token|
    it "does not get a meter with #{token}" do
      meter = Fabricate(:meter)

      if token == :no_access_token
        get_without_token "/api/v1/meters/#{meter.id}"
        expect(response).to have_http_status(401)
      else
        access_token = Fabricate(token)
        get_with_token  "/api/v1/meters/#{meter.id}", access_token.token
        expect(response).to have_http_status(403)
      end

    end

    

    it "does not update a meter with #{token}" do
      meter = Fabricate(:meter)

      request_params = {
        id:                                 meter.id,
        manufacturer_name:                  meter.manufacturer_name,
        manufacturer_product_name:          "#{meter.manufacturer_product_name} updated",
        manufacturer_product_serialnumber:  meter.manufacturer_product_serialnumber
      }.to_json

      if token == :no_access_token
        put_without_token "/api/v1/meters", request_params
        expect(response).to have_http_status(401)
      else
        access_token = Fabricate(token)
        put_with_token  "/api/v1/meters", request_params, access_token.token
        expect(response).to have_http_status(403)
      end
    end


    
    

    it "does not delete a meter with #{token}" do
      meter = Fabricate(:meter)

      if token == :no_access_token
        delete_without_token "/api/v1/meters/#{meter.id}"
        expect(response).to have_http_status(401)
      else
        access_token = Fabricate(token)
        delete_with_token  "/api/v1/meters/#{meter.id}", access_token.token
        expect(response).to have_http_status(403)
      end
    end
    
  end



  it 'gets a meter with full accees token as admin' do
    access_token  = Fabricate(:full_access_token_as_admin)
    meter = Fabricate(:meter)
    get_with_token "/api/v1/meters/#{meter.id}", access_token.token
    expect(response).to have_http_status(200)
  end



  it 'creates a meter with full access token as admin' do
    access_token = Fabricate(:full_access_token_as_admin)
    meter = Fabricate.build(:meter)

    request_params = {
      manufacturer_name:                  meter.manufacturer_name,
      manufacturer_product_name:          meter.manufacturer_product_name,
      manufacturer_product_serialnumber:  meter.manufacturer_product_serialnumber
    }.to_json

    post_with_token "/api/v1/meters", request_params, access_token.token

    expect(response).to have_http_status(201)
    expect(json['data']['attributes']['manufacturer-name']).to eq(meter.manufacturer_name)
    expect(json['data']['attributes']['manufacturer-product-name']).to eq(meter.manufacturer_product_name)
    expect(json['data']['attributes']['manufacturer-product-serialnumber']).to eq(meter.manufacturer_product_serialnumber)
  end



  it 'does not create an already existing meter with full access token as admin' do
    access_token = Fabricate(:full_access_token_as_admin)
    meter = Fabricate(:meter)

    request_params = {
      manufacturer_name:                  meter.manufacturer_name,
      manufacturer_product_name:          meter.manufacturer_product_name,
      manufacturer_product_serialnumber:  meter.manufacturer_product_serialnumber
    }.to_json

    post_with_token "/api/v1/meters", request_params, access_token.token

    expect(response).to have_http_status(422)
  end





  it 'updates a meter with full access token as admin' do
    meter = Fabricate(:meter)
    access_token  = Fabricate(:full_access_token_as_admin)

    request_params = {
      id:                                 meter.id,
      manufacturer_name:                  meter.manufacturer_name,
      manufacturer_product_name:          "#{meter.manufacturer_product_name} updated",
      manufacturer_product_serialnumber:  meter.manufacturer_product_serialnumber
    }.to_json

    put_with_token "/api/v1/meters", request_params, access_token.token

    expect(response).to have_http_status(200)
    expect(json['data']['attributes']['manufacturer-name']).to eq(meter.manufacturer_name)
    expect(json['data']['attributes']['manufacturer-product-name']).to eq("#{meter.manufacturer_product_name} updated")
    expect(json['data']['attributes']['manufacturer-product-serialnumber']).to eq(meter.manufacturer_product_serialnumber)
  end







  it 'deletes a meter with full access token as admin' do
    meter = Fabricate(:meter)
    access_token  = Fabricate(:full_access_token_as_admin)
    delete_with_token "/api/v1/meters/#{meter.id}", access_token.token
    expect(response).to have_http_status(204)
  end


  xit 'does delete a meter and related metering_points with full access token' do
  end




end
