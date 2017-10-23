describe Admin::Roda do

  class TestAdminRoda < BaseRoda
    route do |r|
      r.on('test') { r.run Admin::Roda }
      r.run Me::Roda 
    end
  end

  def app
    TestAdminRoda # this defines the active application for this test
  end

  entity!(:localpool) do
    localpool = Fabricate(:localpool)
    Fabricate(:metering_point_operator_contract, localpool: localpool)
    localpool
  end

  let(:expired_json) do
    {"error" => "This session has expired, please login again."}
  end

  context 'persons' do

    context 'GET' do

      let(:person) do
        localpool.metering_point_operator_contract.customer
      end

      let(:persons_json) do
        [
          {
            "id"=>person.id,
            "type"=>"person",
            'updated_at'=>person.updated_at.as_json,
            "prefix"=>person.attributes['prefix'],
            "title"=>person.attributes['title'],
            "first_name"=>person.first_name,
            "last_name"=>person.last_name,
            "phone"=>person.phone,
            "fax"=>person.fax,
            "email"=>person.email,
            'preferred_language'=>person.attributes['preferred_language'],
            "image"=>person.image.md.url,
            'customer_number' => nil,
            "updatable"=>false,
            "deletable"=>false,
          }
        ]
      end

      it '200' do
        GET "/test/persons", $admin

        expect(response).to have_http_status(200)
        expect(json['array'].to_yaml).to eq(persons_json.to_yaml)
      end

      it '401' do
        GET "/test/persons", $admin
        Timecop.travel(Time.now + 30 * 60) do
          GET "/test/persons", $admin

          expect(response).to have_http_status(401)
          expect(json).to eq(expired_json)
        end
      end
    end
  end

  context 'organizations' do

    context 'GET' do

      let(:organization) do
        localpool.metering_point_operator_contract.contractor
      end

      let(:organizations_json) do
        [
          {
            "id"=>organization.id,
            "type"=>"organization",
            'updated_at'=>organization.updated_at.as_json,
            "name"=>organization.name,
            "phone"=>organization.phone,
            "fax"=>organization.fax,
            "website"=>organization.website,
            "email"=>organization.email,
            "description"=>organization.description,
            # FIXME this is now stored on association OrganizationMarketFunction
            'customer_number' => nil,
            "updatable"=>false,
            "deletable"=>false,
          }
        ]
      end

      it '200' do
        GET "/test/organizations", $admin

        expect(response).to have_http_status(200)
        expect(json['array'].to_yaml).to eq(organizations_json.to_yaml)
      end

      it '401' do
        GET "/test/organizations", $admin
        Timecop.travel(Time.now + 30 * 60) do
          GET "/test/organizations", $admin

          expect(response).to have_http_status(401)
          expect(json).to eq(expired_json)
        end
      end
    end
  end
end
