# coding: utf-8
describe "Meters API" do

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

      it "gets a #{type} meter with full accees token as admin" do
        access_token  = Fabricate(:full_access_token_as_admin)
        meter = Fabricate(:"#{type}_meter")
        get_with_token "/api/v1/meters/#{meter.id}", access_token.token
        expect(response).to have_http_status(200)
        expect(json['data']['attributes']['updatable']).to be true
        expect(json['data']['attributes']['deletable']).to be true
      end
    end
  end

  [:full_access_token, :smartmeter_access_token].each do |token|

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


  it "gets related register for Virtual-Meter with full_access_token" do
    access_token    = Fabricate(:full_access_token)
    user            = User.find(access_token.resource_owner_id)
    meter           = Fabricate(:virtual_meter)
    register        = meter.register
    user.add_role(:manager, register)

    get_with_token "/api/v1/meters/virtual/#{meter.id}/register", access_token.token
    expect(response).to have_http_status(200)
  end

end
