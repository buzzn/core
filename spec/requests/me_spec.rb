describe MeRoda do

  def app
    MeRoda # this defines the active application for this test
  end

  entity!(:admin) { Fabricate(:admin_token) }

  entity!(:user_token) { Fabricate(:user_token) }

  entity!(:other) { Fabricate(:user_token) }

  entity(:person) { User.find(user_token.resource_owner_id).person }

  let(:denied_json) do
    {
      "errors" => [
        {
          "detail"=>"retrieve Person: permission denied for User: --anonymous--"
        }
      ]
    }
  end

  let(:person_json) do
    {
      "id"=>person.id,
      "type"=>"person",
      "prefix"=>person.attributes['prefix'],
      "title"=>person.title,
      "first_name"=>person.first_name,
      "last_name"=>person.last_name,
      "phone"=>person.phone,
      "fax"=>person.fax,
      "email"=>person.email,
      'preferred_language'=>person.attributes['preferred_language'],
      "image"=>User.where(person: person).first.image.md.url,
      "updatable"=>true,
      "deletable"=>false,
      'sales_tax_number'=>nil,
      'tax_rate'=>nil,
      'tax_number'=>nil
    }
  end

  context 'GET' do

    it '403' do
      GET ''
      expect(response).to have_http_status(403)
      expect(json).to eq denied_json
    end

    it '200' do
      GET '', user_token
      expect(response).to have_http_status(200)
      expect(json.to_yaml).to eq person_json.to_yaml
    end
  end
end
