describe Admin::Roda, :request_helper do

  class TestAdminRoda < BaseRoda

    route do |r|
      r.on('test') { r.run Admin::Roda }
      r.run Me::Roda
    end

  end

  def app
    TestAdminRoda # this defines the active application for this test
  end

  let!(:localpool) { create(:group, :localpool, owner: create(:organization, :with_contact, :with_address, :with_legal_representation)) }

  let!(:contract) do
    create(:contract, :localpool_powertaker, localpool: localpool)
  end

  let(:expired_json) do
    {'error' => 'This session has expired, please login again.'}
  end

  context 'organizations-market' do

    it '401' do
      GET '/test/organizations-market', $admin
      expect(response).to have_http_status(200)

      GET '/test/organizations-market', nil
      expect(response).to have_http_status(401)

      Timecop.travel(Time.now + 30 * 60) do
        GET '/test/organizations-market', $admin

        expect(response).to have_http_status(401)
        expect(json).to eq(expired_json)
      end
    end

    it '200' do
      GET '/test/organizations-market', $admin

      expect(response).to have_http_status(200)
      expect(json['array'].size).to eq(Organization::Market.count)
      json['array'].each do |item|
        expect(item['type']).to eq('organization_market')
      end
    end

    it '200 with market_functions' do
      GET '/test/organizations-market?include=market_functions', $admin

      expect(response).to have_http_status(200)
      expect(json['array'].size).to eq(Organization::Market.count)
      json['array'].each do |item|
        expect(item['type']).to eq('organization_market')
      end
    end

  end

  context 'persons' do

    context 'GET' do

      let(:person) do
        contract.customer
      end

      it '200 all' do
        GET '/test/persons', $admin

        expect(response).to have_http_status(200)
        GET '/test/persons', $admin, include: 'contracts:[localpool,register_meta:registers]'

        expect(response).to have_http_status(200)
      end

      it '200' do
        GET "/test/persons/#{person.id}", $admin, include: 'address,contracts:[localpool,register_meta:registers]'

        expect(response).to have_http_status(200)
      end

      it '401' do
        GET '/test/persons', $admin
        expect(response).to have_http_status(200)

        GET '/test/person', nil
        expect(response).to have_http_status(401)

        Timecop.travel(Time.now + 30 * 60) do
          GET '/test/persons', $admin

          expect(response).to have_http_status(401)
          expect(json).to eq(expired_json)
        end
      end
    end
  end

  context 'organizations' do

    context 'GET' do

      let(:organizations_json) do
        Organization::General.all.collect do |organization|
          {
            'id'=>organization.id,
            'type'=>'organization',
            'created_at'=>organization.created_at.as_json,
            'updated_at'=>organization.updated_at.as_json,
            'name'=>organization.name,
            'phone'=>organization.phone,
            'fax'=>organization.fax,
            'website'=>organization.website,
            'email'=>organization.email,
            'description'=>organization.description,
            'additional_legal_representation'=>organization.additional_legal_representation,
            'updatable'=>false,
            'deletable'=>false,
            'customer_number' => nil,
          }
        end
      end

      it '200' do
        GET '/test/organizations', $admin

        expect(response).to have_http_status(200)
        expect(json['array'].to_yaml).to eq(organizations_json.to_yaml)

        GET '/test/organizations', $admin, include: 'contact:[address], legal_representation, address'

        expect(response).to have_http_status(200)
        result = json['array'].find { |s| s['address'] }
        expect(result).to has_nested_json(:address, :id)
        expect(result).to has_nested_json(:contact, :id)
        expect(result).to has_nested_json(:contact, :address, :id)
        expect(result).to has_nested_json(:legal_representation, :id)
      end

      it '401' do
        GET '/test/organizations', $admin
        expect(response).to have_http_status(200)

        GET '/test/organizations', nil
        expect(response).to have_http_status(401)

        Timecop.travel(Time.now + 30 * 60) do
          GET '/test/organizations', $admin

          expect(response).to have_http_status(401)
          expect(json).to eq(expired_json)
        end
      end
    end
  end

  context 'localpools' do

    context 'GET' do
      it '401' do
        GET '/test/localpools', $admin
        expect(response).to have_http_status(200)

        GET '/test/localpools', nil
        expect(response).to have_http_status(401)

        Timecop.travel(Time.now + 30 * 60) do
          GET '/test/localpools', $admin

          expect(response).to have_http_status(401)
          expect(json).to eq(expired_json)
        end
      end
    end
  end
end
