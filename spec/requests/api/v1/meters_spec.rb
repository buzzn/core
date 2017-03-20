# coding: utf-8
describe "Meters API" do

  let(:page_overload) { 11 }

  [
    :no_access_token,
    :simple_access_token
  ].each do |token|
    it "does not get a registers with #{token}" do
      meter = Fabricate(:meter)

      if token == :no_access_token
        get_without_token "/api/v1/meters/real/#{meter.id}/registers"
        expect(response).to have_http_status(401)
      else
        access_token = Fabricate(token)
        get_with_token  "/api/v1/meters/real/#{meter.id}/registers", access_token.token
        expect(response).to have_http_status(403)
      end
    end
  end

  [:no_access_token,
   :simple_access_token,
   :smartmeter_access_token].each do |token|

    [:real, :virtual].each do |type|
      it "does not get a #{type} meter with #{token}" do
        meter = Fabricate(:"#{type}_meter")
        if token == :no_access_token
          get_without_token "/api/v1/meters/#{meter.id}"
          expect(response).to have_http_status(401)
        else
          access_token = Fabricate(token)
          get_with_token  "/api/v1/meters/#{meter.id}", access_token.token
          expect(response).to have_http_status(403)
        end
      end


      it "does not update a #{type} meter with #{token}" do
        meter = Fabricate(:meter)
        request_params = {
          id:                                 meter.id,
          manufacturer_name:                  meter.manufacturer_name,
          manufacturer_product_name:          "#{meter.manufacturer_product_name} updated",
          manufacturer_product_serialnumber:  meter.manufacturer_product_serialnumber
        }.to_json

        if token == :no_access_token
          patch_without_token "/api/v1/meters/#{type}/#{meter.id}", request_params
          expect(response).to have_http_status(401)
        else
          access_token = Fabricate(token)
          patch_with_token  "/api/v1/meters/#{type}/#{meter.id}", request_params, access_token.token
          expect(response).to have_http_status(403)
        end
      end


      it "gets a #{type} meter with full accees token as admin" do
        access_token  = Fabricate(:full_access_token_as_admin)
        meter = Fabricate(:"#{type}_meter")
        get_with_token "/api/v1/meters/#{meter.id}", access_token.token
        expect(response).to have_http_status(200)
        expect(json['meta']['updatable']).to be_truthy
        expect(json['meta']['deletable']).to be_truthy
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

  [:full_access_token, :smartmeter_access_token].each do |token|
    [:input, :output, :input_output].each do |type|
      it "creates a real-meter with #{type}-register using #{token}" do
        access_token = Fabricate(token)
        meter = if type == :input_output
                  m = Fabricate.build(:input_meter)
                  m.registers << Fabricate.build(:output_register)
                  m
                else
                  Fabricate.build(:"#{type}_meter")
                end
        request_params = {
          manufacturer_name:                  meter.manufacturer_name,
          manufacturer_product_name:          meter.manufacturer_product_name,
          manufacturer_product_serialnumber:  meter.manufacturer_product_serialnumber
        }
        meter.registers.each do |register|
          request_params[:"#{register.direction}put_register"] = {
            name: register.name,
            readable: register.readable,
            uid: register.uid
          }
        end

        post_with_token "/api/v1/meters/real", request_params.to_json, access_token.token

        expect(response).to have_http_status(201)
        expect(json['data']['attributes']['manufacturer-name']).to eq(meter.manufacturer_name)
        expect(json['data']['attributes']['manufacturer-product-name']).to eq(meter.manufacturer_product_name)
        expect(json['data']['attributes']['manufacturer-product-serialnumber']).to eq(meter.manufacturer_product_serialnumber)
      end
    end

    it "creates a virtual-meter using #{token}" do
      access_token = Fabricate(:full_access_token)
      meter = Fabricate.build(:virtual_meter)
      request_params = {
        manufacturer_product_name:          meter.manufacturer_product_name,
        manufacturer_product_serialnumber:  meter.manufacturer_product_serialnumber,
        register: {
          name: meter.register.name,
          direction: [:in, :out].sample,
          readable: meter.register.readable,
        }
      }

      post_with_token "/api/v1/meters/virtual", request_params.to_json, access_token.token

      expect(response).to have_http_status(201)
      expect(json['data']['attributes']['manufacturer-product-name']).to eq(meter.manufacturer_product_name)
      expect(json['data']['attributes']['manufacturer-product-serialnumber']).to eq(meter.manufacturer_product_serialnumber)
    end

    it "gets related registers for Real-Meter with #{token}" do
      access_token    = Fabricate(token)
      user            = User.find(access_token.resource_owner_id)
      meter           = Fabricate(:real_meter)
      register        = meter.registers.first
      user.add_role(:manager, register)

      get_with_token "/api/v1/meters/real/#{meter.id}/registers", access_token.token
      expect(response).to have_http_status(200)
    end
  end

  ["input", "output"].each do |mode|

    it "does not create a #{mode} register without token" do
      register     = Fabricate.build("#{mode}_register")
      meter        = Fabricate.build(:meter)
      request_params = {
        uid:  register.uid,
        readable: register.readable,
        name: register.name
      }.to_json
      post_without_token "/api/v1/meters/real/#{meter.id}/#{mode}_register", request_params
      expect(response).to have_http_status(401)
    end


    it "does not create a #{mode} register with missing parameters" do
      register       = Fabricate.build("#{mode}_register")
      access_token   = Fabricate(:full_access_token_as_admin)
      meter          = Fabricate(:meter)
      request_params = {
        readable: register.readable,
        name: register.name
      }
      request_params.keys.each do |name|
        params = request_params.reject { |k,v| k == name }

        post_with_token "/api/v1/meters/real/#{meter.id}/#{mode}_register", params.to_json, access_token.token

        expect(response).to have_http_status(422)
        json["errors"].each do |error|
          expect(error["source"]["pointer"]).to eq "/data/attributes/#{name}"
          expect(error["title"]).to eq "Invalid Attribute"
          expect(error["detail"]).to eq "#{name} is missing"
        end
      end
    end


    it "does not create a #{mode} register with invalid parameters" do
      register       = Fabricate.build("#{mode}_register")
      access_token   = Fabricate(:full_access_token_as_admin)
      meter          = Fabricate(:meter)
      request_params = {
        readable: register.readable,
        name: register.name
      }
      request_params.keys.each do |key|
        params = request_params.dup
        params[key] = "a" * 2000

        post_with_token "/api/v1/meters/real/#{meter.id}/#{mode}_register", params.to_json, access_token.token

        expect(response).to have_http_status(422)
        json["errors"].each do |error|
          expect(error["source"]["pointer"]).to eq "/data/attributes/#{key}"
          expect(error["title"]).to eq "Invalid Attribute"
          expect(error["detail"]).to match /#{key}/
        end
      end
    end



    [:full_access_token_as_admin, :smartmeter_access_token].each do |token|
      it "creates a #{mode} register with #{token}" do
        access_token = Fabricate(token)
        register     = Fabricate.build("#{mode}_register")
        meter        = Fabricate(:meter)

        request_params = {
          uid:  register.uid,
          readable: register.readable,
          name: register.name
        }.to_json

        post_with_token "/api/v1/meters/real/#{meter.id}/#{mode}_register", request_params, access_token.token

        expect(response).to have_http_status(201)
        expect(response.headers["Location"]).to eq json["data"]["id"]

        expect(json["data"]["attributes"]["uid"]).to eq(register.uid)
        expect(json["data"]["attributes"]["direction"]).to eq(mode.sub(/put/, ''))
        expect(json["data"]["attributes"]["readable"]).to eq(register.readable)
        expect(json["data"]["attributes"]["name"]).to eq(register.name)
      end
    end

  end

  it "gets related register for Virtual-Meter with full_access_token" do
    access_token    = Fabricate(:full_access_token)
    user            = User.find(access_token.resource_owner_id)
    meter           = Fabricate(:virtual_meter)
    register        = meter.register
    user.add_role(:manager, register)

    get_with_token "/api/v1/meters/virtual/#{meter.id}/register", access_token.token
    expect(response).to have_http_status(200)
  end


  it "does not create an already existing real meter with full access token as admin" do
    access_token = Fabricate(:full_access_token_as_admin)
    meter = Fabricate(:real_meter)
    request_params = {
      manufacturer_name:                  meter.manufacturer_name,
      manufacturer_product_name:          meter.manufacturer_product_name,
      manufacturer_product_serialnumber:  meter.manufacturer_product_serialnumber
    }
    register = meter.registers.first
    request_params[:"#{register.direction}put_register"] = {
      name: register.name,
      readable: register.readable,
      uid: register.uid
    }

    post_with_token "/api/v1/meters/real", request_params.to_json, access_token.token
    expect(response).to have_http_status(422)

    errors = json['errors']

    expect(errors.size).to eq 1
    errors.each do |error|
      expect(error['title']).to eq 'Invalid Attribute'
    end
    [ "/data/attributes/manufacturer_product_serialnumber"].each do |key_path|
      expect(errors.detect { |e| e['source']['pointer'] == key_path }).not_to be_nil
    end
  end

  it "does not create an already existing virtual meter with full access token as admin" do
    access_token = Fabricate(:full_access_token_as_admin)
    meter = Fabricate(:virtual_meter)
    request_params = {
      manufacturer_product_name:          meter.manufacturer_product_name,
      manufacturer_product_serialnumber:  meter.manufacturer_product_serialnumber,
      register: {
        name: meter.register.name,
        readable: meter.register.readable,
        direction: Register::Base.directions.sample
      }
    }

    post_with_token "/api/v1/meters/virtual", request_params.to_json, access_token.token
    expect(response).to have_http_status(422)

    errors = json['errors']
    expect(errors.size).to eq 1
    expect(errors.first['title']).to eq 'Invalid Attribute'
    expect(errors.first['source']['pointer']).to eq "/data/attributes/manufacturer_product_serialnumber"
  end

  it "does not create a real meter with missing parameters" do
    access_token = Fabricate(:full_access_token_as_admin)
    meter = Fabricate(:meter)

    request_params = {
      manufacturer_name:                  meter.manufacturer_name,
      manufacturer_product_name:          meter.manufacturer_product_name,
      manufacturer_product_serialnumber:  meter.manufacturer_product_serialnumber
    }

    request_params.keys.each do |name|

      params = request_params.reject { |k,v| k == name }
      post_with_token "/api/v1/meters/real", params.to_json, access_token.token

      expect(response).to have_http_status(422)

      json['errors'].each do |error|
        expect(error['source']['pointer']).to eq "/data/attributes/#{name}"
        expect(error['title']).to eq 'Invalid Attribute'
        expect(error['detail']).to eq "#{name} is missing"
      end
    end
  end





  it 'does not update a real-meter with invalid parameters' do
    meter = Fabricate(:meter)
    access_token  = Fabricate(:full_access_token_as_admin)

    params = { manufacturer_product_serialnumber: Fabricate(:meter).manufacturer_product_serialnumber }

    patch_with_token "/api/v1/meters/real/#{meter.id}", params.to_json, access_token.token

    expect(response).to have_http_status(422)
    json['errors'].each do |error|
      expect(error['source']['pointer']).to eq "/data/attributes/manufacturer_product_serialnumber"
      expect(error['title']).to eq 'Invalid Attribute'
    end
  end

  it 'does not update a virtual-meter with invalid parameters' do
    meter = Fabricate(:virtual_meter)
    access_token  = Fabricate(:full_access_token_as_admin)

    params = { manufacturer_product_serialnumber: '1' * 400 }

    patch_with_token "/api/v1/meters/virtual/#{meter.id}", params.to_json, access_token.token

    expect(response).to have_http_status(422)
    json['errors'].each do |error|
      expect(error['source']['pointer']).to eq "/data/attributes/manufacturer_product_serialnumber"
      expect(error['title']).to eq 'Invalid Attribute'
    end
  end


  [:real, :virtual].each do |type|
    it "updates a #{type} meter with full access token as admin" do
      meter = Fabricate(:"#{type}_meter")
      access_token  = Fabricate(:full_access_token_as_admin)

      request = {
        manufacturer_product_name:          "#{meter.manufacturer_product_name} updated",
        manufacturer_product_serialnumber:  meter.manufacturer_product_serialnumber || '123123123'
      }
      request[:manufacturer_name] = meter.manufacturer_name if type == :real
      patch_with_token "/api/v1/meters/#{type}/#{meter.id}", request.to_json, access_token.token

      expect(response).to have_http_status(200)
      expect(json['data']['attributes']['manufacturer-name']).to eq(meter.manufacturer_name)  if type == :real

      expect(json['data']['attributes']['manufacturer-product-name']).to eq("#{meter.manufacturer_product_name} updated")
      expect(json['data']['attributes']['manufacturer-product-serialnumber']).to eq(meter.manufacturer_product_serialnumber)
    end


    it "deletes a #{type} meter with full access token as admin" do
      meter = Fabricate(:"#{type}_meter")
      access_token  = Fabricate(:full_access_token_as_admin)

      delete_with_token "/api/v1/meters/#{meter.id}", access_token.token

      expect(response).to have_http_status(204)
      expect(Meter::Base.where(id: meter.id)).to eq []
    end
  end

end
