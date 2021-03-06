describe Me::Roda, :request_helper do

  def app
    Me::Roda # this defines the active application for this test
  end

  entity(:person) { $user.person.reload }

  let(:expired_json) do
    {'error' => 'This session has expired, please login again.' }
  end

  let(:person_json) do
    {
      'id'=>person.id,
      'type'=>'person',
      'created_at'=>person.created_at.as_json,
      'updated_at'=>person.updated_at.as_json,
      'prefix'=>person.attributes['prefix'],
      'title'=>person.attributes['title'],
      'first_name'=>person.first_name,
      'last_name'=>person.last_name,
      'phone'=>person.phone,
      'fax'=>person.fax,
      'email'=>person.email,
      'preferred_language'=>person.attributes['preferred_language'],
      'image'=>person.image.medium.url,
      'customer_number' => nil,
      'email_backend_host' => nil,
      'email_backend_port' => nil,
      'email_backend_user' => nil,
      'email_backend_encryption' => nil,
      'email_backend_active' => false,
      'email_backend_signature' => nil,
      'updatable'=>true,
      'deletable'=>false,
    }
  end

  context 'ping' do
    context 'GET' do

      it '200' do
        GET '/ping', $user
        expect(response).to have_http_status(200)
        expect(response.body).to eq 'pong'
      end

      it '401' do
        GET '/ping', $user
        Timecop.travel(Time.now + 30 * 60) do
          GET '/ping', $user

          expect(response).to have_http_status(401)
          expect(json).to eq(expired_json)
        end
      end
    end
  end

  context 'GET' do

    it '401' do
      GET '', $user
      Timecop.travel(Time.now + 30 * 60) do
        GET '', $user

        expect(response).to have_http_status(401)
        expect(json).to eq(expired_json)
      end
    end

    it '403' do
      GET ''
      expect(response).to have_http_status(403)
    end

    it '200' do
      GET '', $user
      expect(response).to have_http_status(200)
      expect(json.to_yaml).to eq person_json.to_yaml
    end
  end

  context 'PATCH' do

    let(:wrong_json) do
      { 'errors'=>{
        'updated_at'=>['is missing'],
        'prefix'=>['must be one of: F, M'],
        'first_name'=>['size cannot be greater than 64'],
        'last_name'=>['size cannot be greater than 64'],
        'preferred_language'=>['must be one of: , de, en'],
        'title'=>['must be one of: , Prof., Dr., Prof. Dr.'],
        'phone'=>['must be a valid phone-number'],
        'fax'=>['size cannot be greater than 64']}
      }
    end

    let(:updated_json) do
      {
        'id'=>person.id,
        'type'=>'person',
        'prefix'=>'M',
        'title'=>'Prof.',
        'first_name'=>'Maxima',
        'last_name'=>'Toll',
        'phone'=>'+(0)84.32 123-312 x123 #123',
        'fax'=>'08191 123312',
        'email'=>person.email,
        'preferred_language'=>'de',
        'image'=>person.image.medium.url,
        'customer_number' => nil,
        'email_backend_host' => nil,
        'email_backend_port' => nil,
        'email_backend_user' => nil,
        'email_backend_encryption' => nil,
        'email_backend_active' => false,
        'email_backend_signature' => nil,
        'updatable'=>true,
        'deletable'=>false
      }
    end

    it '401' do
      GET '', $user
      Timecop.travel(Time.now + 30 * 60) do
        PATCH '', $user

        expect(response).to have_http_status(401)
      end
    end

    it '403' do
      PATCH ''
      expect(response).to have_http_status(403)
    end

    it '409' do
      PATCH '', $user, updated_at: DateTime.now + 2.seconds
      expect(response).to have_http_status(409)
    end

    it '422' do
      PATCH '', $user,
            title: 'Master' * 20,
            prefix: 'Both',
            first_name: 'Maxima' * 20,
            last_name: 'Toll' * 40,
            phone: '+(0)80 123-312.321 x123 #123 *1@2&3',
            fax: '123312' * 40,
            preferred_language: 'none'
      expect(response).to have_http_status(422)
      expect(json.to_yaml).to eq wrong_json.to_yaml
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
      expect(result.delete('created_at')).not_to be_nil
      expect(result.to_yaml).to eq updated_json.to_yaml
    end

    it '200 - with delete' do
      old = person.updated_at
      PATCH '', $user,
            updated_at: person.updated_at,
            title: nil,
            prefix: 'M',
            first_name: 'Maxima',
            last_name: 'Toll',
            phone: nil,
            fax: nil,
            preferred_language: nil

      expect(response).to have_http_status(200)
      person.reload
      expect(person.title).to be_nil
      expect(person.prefix).to eq 'male'
      expect(person.first_name).to eq 'Maxima'
      expect(person.last_name).to eq 'Toll'
      expect(person.phone).to be_nil
      expect(person.fax).to be_nil
      expect(person.preferred_language).to be_nil

      result = json
      # TODO fix it: our time setup does not allow
      #expect(result.delete('updated_at')).to be > old.as_json
      expect(result.delete('updated_at')).not_to eq old.as_json
      expect(result.delete('created_at')).not_to be_nil
      expected = updated_json.merge('title' => nil, 'phone' => nil, 'fax' => nil, 'preferred_language' => nil)
      expect(result.to_yaml).to eq expected.to_yaml
    end
  end
end
