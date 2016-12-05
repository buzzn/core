describe "Meters API" do

  let(:page_overload) { 11 }

  [:no_access_token,
   :simple_access_token].each do |token|
    it "does not get a registers with #{token}" do
      meter = Fabricate(:meter)

      if token == :no_access_token
        get_without_token "/api/v1/meters/#{meter.id}/registers"
        expect(response).to have_http_status(401)
      else
        access_token = Fabricate(token)
        get_with_token  "/api/v1/meters/#{meter.id}/registers", access_token.token
        expect(response).to have_http_status(403)
      end

    end
  end

  [:no_access_token,
   :simple_access_token,
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
        patch_without_token "/api/v1/meters/#{meter.id}", request_params
        expect(response).to have_http_status(401)
      else
        access_token = Fabricate(token)
        patch_with_token  "/api/v1/meters/#{meter.id}", request_params, access_token.token
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


  [:full_access_token, :smartmeter_access_token].each do |token|
    it "creates a meter with #{token}" do
      access_token = Fabricate(token)
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


    it "gets related registers for Meter with #{token}" do
      access_token = Fabricate(token)
      user            = User.find(access_token.resource_owner_id)
      meter           = Fabricate(:meter)
      register  = Fabricate(:in_register, meter: meter)
      user.add_role(:manager, register)

      get_with_token "/api/v1/meters/#{meter.id}/registers", access_token.token
      expect(response).to have_http_status(200)
    end

    it "gets the filtered registers for Meter with #{token}" do
      meter  = Fabricate(:meter)
      mp1    = Fabricate(:in_register, meter: meter)
      mp2    = Fabricate(:out_register, meter: meter)

      access_token  = Fabricate(token)
      user          = User.find(access_token.resource_owner_id)
      user.add_role(:manager, mp1)
      user.add_role(:manager, mp2)

      request_params = {
        filter: mp1.mode
      }

      get_with_token "/api/v1/meters/#{meter.id}/registers", request_params, access_token.token
      expect(response).to have_http_status(200)
      expect(json['data'].size).to eq(1)
      expect(json['data'].first['attributes']['mode']).to eq(mp1.mode)
    end

    it "paginates registers #{token}" do
      meter         = Fabricate(:meter)
      access_token  = Fabricate(token)
      user          = User.find(access_token.resource_owner_id)
      page_overload.times do
        mp = Fabricate([:in_register, :out_register].sample,  meter: meter)
        user.add_role(:manager, mp)
      end

      get_with_token "/api/v1/meters/#{meter.id}/registers", access_token.token
      expect(response).to have_http_status(200)
      expect(json['meta']['total_pages']).to eq(2)

      get_with_token "/api/v1/meters/#{meter.id}/registers", {per_page: 200}, access_token.token
      expect(response).to have_http_status(422)
    end

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

    json['errors'].each do |error|
      expect(error['source']['pointer']).to eq "/data/attributes/manufacturer_product_serialnumber"
      expect(error['title']).to eq 'Invalid Attribute'
      expect(error['detail']).to eq "manufacturer_product_serialnumber ist bereits vergeben"
    end
  end


  it 'does not create a meter with missing parameters' do
    access_token = Fabricate(:full_access_token_as_admin)
    meter = Fabricate(:meter)

    request_params = {
      manufacturer_name:                  meter.manufacturer_name,
      manufacturer_product_name:          meter.manufacturer_product_name,
      manufacturer_product_serialnumber:  meter.manufacturer_product_serialnumber
    }

    request_params.keys.each do |name|

      params = request_params.reject { |k,v| k == name }
      post_with_token "/api/v1/meters", params.to_json, access_token.token

      expect(response).to have_http_status(422)

      json['errors'].each do |error|
        expect(error['source']['pointer']).to eq "/data/attributes/#{name}"
        expect(error['title']).to eq 'Invalid Attribute'
        expect(error['detail']).to eq "#{name} is missing"
      end
    end
  end





  it 'does not update a meter with invalid parameters' do
    meter = Fabricate(:meter)
    access_token  = Fabricate(:full_access_token_as_admin)

    params = { manufacturer_product_serialnumber: Fabricate(:meter).manufacturer_product_serialnumber }

    patch_with_token "/api/v1/meters/#{meter.id}", params.to_json, access_token.token

    expect(response).to have_http_status(422)
    json['errors'].each do |error|
      expect(error['source']['pointer']).to eq "/data/attributes/manufacturer_product_serialnumber"
      expect(error['title']).to eq 'Invalid Attribute'
      expect(error['detail']).to eq "manufacturer_product_serialnumber ist bereits vergeben"
    end
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

    patch_with_token "/api/v1/meters/#{meter.id}", request_params, access_token.token

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


  xit 'does delete a meter and related registers with full access token' do
  end




end
