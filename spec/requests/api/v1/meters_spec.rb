describe "Meters API" do


  it 'does not gets a meter without token' do
    meter = Fabricate(:meter)
    get_without_token "/api/v1/meters/#{meter.id}"
    expect(response).to have_http_status(401)
  end


  it 'does gets a meter with manager token' do
    access_token  = Fabricate(:full_edit_access_token_as_admin)
    meter = Fabricate(:meter)
    get_with_token "/api/v1/meters/#{meter.id}", access_token.token
    expect(response).to have_http_status(200)
  end



  it 'does creates a meter with manager token' do
    access_token = Fabricate(:full_edit_access_token_as_admin)
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



  it 'does not creates a already existing meter with manager token' do
    access_token = Fabricate(:full_edit_access_token_as_admin)
    meter = Fabricate(:meter)

    request_params = {
      manufacturer_name:                  meter.manufacturer_name,
      manufacturer_product_name:          meter.manufacturer_product_name,
      manufacturer_product_serialnumber:  meter.manufacturer_product_serialnumber
    }.to_json

    post_with_token "/api/v1/meters", request_params, access_token.token

    expect(response).to have_http_status(422)
  end





  it 'does update a meter with manager_token' do
    meter = Fabricate(:meter)
    access_token  = Fabricate(:full_edit_access_token_as_admin)

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






  it 'does not update a metering_point without token' do
    meter = Fabricate(:meter)

    request_params = {
      id:                                 meter.id,
      manufacturer_name:                  meter.manufacturer_name,
      manufacturer_product_name:          "#{meter.manufacturer_product_name} updated",
      manufacturer_product_serialnumber:  meter.manufacturer_product_serialnumber
    }.to_json

    put_without_token "/api/v1/meters", request_params

    expect(response).to have_http_status(401)
  end




  it 'does delete a meter with manager_token' do
    meter = Fabricate(:meter)
    access_token  = Fabricate(:full_edit_access_token_as_admin)
    delete_with_token "/api/v1/meters/#{meter.id}", access_token.token
    expect(response).to have_http_status(204)
  end


  xit 'does delete a meter and related metering_points with manager_token' do
  end




end
