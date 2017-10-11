describe Me::Roda do
  
  def app
    Me::Roda # this defines the active application for this test
  end

  entity(:person) { $user.person }

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
      GET '', $user#_token
      expect(response).to have_http_status(200)
      expect(json.to_yaml).to eq person_json.to_yaml
    end
  end

  context 'PATCH' do

    let(:wrong_json) do
      {
        "errors"=>[
          {"parameter"=>"updated_at",
           "detail"=>"is missing"},
          {"parameter"=>"title",
           "detail"=>"must be one of: Dr., Prof., Prof. Dr."},
          {"parameter"=>"prefix",
           "detail"=>"must be one of: F, M"},
          {"parameter"=>"first_name",
           "detail"=>"size cannot be greater than 64"},
          {"parameter"=>"last_name",
           "detail"=>"size cannot be greater than 64"},
          {"parameter"=>"phone", "detail"=>"must be a valid phone-number"},
          {"parameter"=>"fax", "detail"=>"size cannot be greater than 64"},
          {"parameter"=>"preferred_language", "detail"=>"must be one of: de, en"}
        ]
      }
    end

    let(:updated_json) do
      {
        "id"=>person.id,
        "type"=>"person",
        "prefix"=>"M",
        "title"=>"Prof.",
        "first_name"=>"Maxima",
        "last_name"=>"Toll",
        "phone"=>"+(0)84.32 123-312 x123 #123",
        "fax"=>"08191 123312",
        "email"=>person.email,
        "preferred_language"=>"de",
        "image"=>person.image.md.url,
        'customer_number' => nil,
        "updatable"=>true,
        "deletable"=>false,
        "sales_tax_number"=>nil,
        "tax_rate"=>nil,
        "tax_number"=>nil
      }
    end

    let(:stale_json) do
      {
        "errors" => [
          {"detail"=>"Person: #{person.id} was updated at: #{person.updated_at}"}]
      }
    end

    it '403' do
      PATCH ''
      expect(response).to have_http_status(403)
      expect(json).to eq denied_json
    end

    it '409' do
      PATCH '', $user, updated_at: DateTime.now
      expect(response).to have_http_status(409)
      expect(json).to eq stale_json
    end

    it '422 wrong' do
      PATCH '', $user,
            title: 'Master' * 20,
            prefix: 'Both',
            first_name: 'Maxima' * 20,
            last_name: 'Toll' * 40,
            phone: '+(0)80 123-312.321 x123 #123 *1@2&3',
            fax: '123312' * 40,
            preferred_language: 'none'
      expect(response).to have_http_status(422)
      expect(json.to_yaml).to eq send("wrong_json").to_yaml
    end

    it '200' do
      old = person.updated_at
      PATCH '', $user,
            updated_at: person.updated_at,
            title: 'Prof.',
            prefix: 'M',
            first_name: 'Maxima',
            last_name: 'Toll',
            phone: '+(0)84.32 123-312 x123 #123',
            fax: '08191 123312',
            preferred_language: 'de'

      expect(response).to have_http_status(200)
      person.reload
      expect(person.title).to eq 'Prof.'
      expect(person.prefix).to eq 'male'
      expect(person.first_name).to eq 'Maxima'
      expect(person.last_name).to eq 'Toll'
      expect(person.phone).to eq '+(0)84.32 123-312 x123 #123'
      expect(person.fax).to eq '08191 123312'
      expect(person.preferred_language).to eq 'german'

      result = json
      # TODO fix it: our time setup does not allow
      #expect(result.delete('updated_at')).to be > old.as_json
      expect(result.delete('updated_at')).not_to eq old.as_json
      expect(result.to_yaml).to eq updated_json.to_yaml
    end
  end
end
