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
      "share_with_group"=>person.share_with_group,
      "share_publicly"=>person.share_publicly,
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

  context 'PATCH' do

    let(:wrong_json) do
      {
        "errors"=>[
          {"parameter"=>"title",
           "detail"=>"size cannot be greater than 64"},
          {"parameter"=>"prefix",
           "detail"=>"must be one of: F, M"},
          {"parameter"=>"first_name",
           "detail"=>"size cannot be greater than 64"},
          {"parameter"=>"last_name",
           "detail"=>"size cannot be greater than 64"},
          {"parameter"=>"phone", "detail"=>"size cannot be greater than 64"},
          {"parameter"=>"fax", "detail"=>"size cannot be greater than 64"},
          {"parameter"=>"share_with_group", "detail"=>"must be boolean"},
          {"parameter"=>"share_publicly", "detail"=>"must be boolean"},
          {"parameter"=>"preferred_language", "detail"=>"must be one of: de, en"}
        ]
      }
    end

    let(:updated_json) do
      {
        "id"=>person.id,
        "type"=>"person",
        "prefix"=>"M",
        "title"=>"Master",
        "first_name"=>"Maxima",
        "last_name"=>"Toll",
        "phone"=>"080 123312",
        "fax"=>"08191 123312",
        "email"=>person.email,
        "share_with_group"=>false,
        "share_publicly"=>true,
        "preferred_language"=>"de",
        "image"=>User.where(person: person).first.image.md.url,
        "updatable"=>true,
        "deletable"=>false,
        "sales_tax_number"=>nil,
        "tax_rate"=>nil,
        "tax_number"=>nil
      }
    end

    it '403' do
      PATCH ''
      expect(response).to have_http_status(403)
      expect(json).to eq denied_json
    end

    it '422 wrong' do
      PATCH '', user_token,
            title: 'Master' * 20,
            prefix: 'Both',
            first_name: 'Maxima' * 20,
            last_name: 'Toll' * 40,
            phone: '123312' * 40,
            fax: '123312' * 40,
            share_with_group: 'dunno',
            share_publicly: 'dunno',
            preferred_language: 'none'

      expect(response).to have_http_status(422)
      expect(json.to_yaml).to eq send("wrong_json").to_yaml
    end

    it '200' do
      PATCH '', user_token,
            title: 'Master',
            prefix: 'M',
            first_name: 'Maxima',
            last_name: 'Toll',
            phone: '080 123312',
            fax: '08191 123312',
            share_with_group: false,
            share_publicly: true,
            preferred_language: 'de'

      expect(response).to have_http_status(200)
      person.reload
      expect(person.title).to eq 'Master'
      expect(person.prefix).to eq 'male'
      expect(person.first_name).to eq 'Maxima'
      expect(person.last_name).to eq 'Toll'
      expect(person.phone).to eq '080 123312'
      expect(person.fax).to eq '08191 123312'
      expect(person.share_with_group).to eq false
      expect(person.share_publicly).to eq true
      expect(person.preferred_language).to eq 'german'

      expect(json.to_yaml).to eq updated_json.to_yaml
    end
  end
end
