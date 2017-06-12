describe MeRoda do

  def app
    MeRoda # this defines the active application for this test
  end

  entity!(:admin) { Fabricate(:admin_token) }

  entity!(:user_token) { Fabricate(:user_token) }

  entity!(:other) { Fabricate(:user_token) }

  entity(:user) { User.find(user_token.resource_owner_id)}

  let(:denied_json) do
    {
      "errors" => [
        {
          "detail"=>"retrieve User: permission denied for User: --anonymous--"
        }
      ]
    }
  end

  let(:anonymous_not_found_json) do
    {
      "errors" => [
        {
          "detail"=>"User: bla-blub not found by User: #{admin.resource_owner_id}"
        }
      ]
    }
  end

  let(:empty_json) do
    []
  end

  let(:user_json) do
    {
      "id"=>user.id,
      "type"=>"user",
      "user_name"=>user.user_name,
      "title"=>user.profile.title,
      "first_name"=>user.first_name,
      "last_name"=>user.last_name,
      "gender"=>user.profile.gender,
      "phone"=>user.profile.phone,
      "email"=>user.email,
      "image"=>user.profile.image.md.url,
      "updatable"=>true,
      "deletable"=>false,
      'sales_tax_number'=>nil,
      'tax_rate'=>nil,
      'tax_number'=>nil
    }
  end

  context 'GET' do

    let(:admin_user_json) do
      json = user_json.dup
      json['deletable']=true
      json
    end

    it '403' do
      GET ''
      expect(response).to have_http_status(403)
      expect(json).to eq denied_json
    end

    it '200' do
      GET '', user_token
      expect(response).to have_http_status(200)
      expect(json.to_yaml).to eq user_json.to_yaml
    end
  end
end
