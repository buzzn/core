require_relative 'test_admin_localpool_roda'
require_relative 'shared_crud'

describe Admin::LocalpoolRoda, :request_helper do

  def app
    TestAdminLocalpoolRoda # this defines the active application for this test
  end

  entity!(:localpool) { create(:group, :localpool) }
  entity!(:person) { create(:person) }
  entity(:organization) { create(:organization) }

  # FIXME permissions hack on /organizations and /persons
  entity!(:permissions_hack) do
    create(:group, :localpool, owner: organization)
    create(:group, :localpool, owner: person)
  end

  let(:organization_path) { "/localpools/#{localpool.id}/organization-owner" }
  let(:person_path) { "/localpools/#{localpool.id}/person-owner" }

  shared_examples 'assign owner' do |first:, second:|

    let(:first_owner) { send(first) }
    let(:second_owner) { send(second) }
    let(:first_path) { send("#{first}_path") }
    let(:second_path) { send("#{second}_path") }

    context '201', :order => :defined do
      it first do
        POST "#{first_path}/#{first_owner.id}", $admin

        expect(response).to have_http_status(201)
        expect(json['id']).to eq(first_owner.id)
        expect(localpool.reload.owner).to eq(first_owner)
      end

      it second do
        POST "#{second_path}/#{second_owner.id}", $admin

        expect(response).to have_http_status(201)
        expect(json['id']).to eq(second_owner.id)
        expect(localpool.reload.owner).to eq(second_owner)
      end
    end
  end

  shared_examples 'create/update organization and assign person' do |method|

    it "201 - #{method}" do
      POST organization_path, $admin,
           name: "is there anybody out there: #{method}",
           method => { id: person.id }

      expect(response).to have_http_status(201)
      expect(localpool.reload.owner.send(method)).to eq(person)
    end

    it "200 - #{method}" do
      PATCH organization_path, $admin,
            updated_at: localpool.owner.updated_at.as_json,
            method => { id: person.id }

      expect(response).to have_http_status(200)
      expect(localpool.reload.owner.send(method)).to eq(person)
    end

  end

  context 'organization' do

    entity!(:before) do
      localpool.update!(owner: organization)
    end

    it_behaves_like 'assign owner', first: :person, second: :organization
    it_behaves_like 'create/update organization and assign person', :contact
    it_behaves_like 'create/update organization and assign person', :legal_representation

  end

  context 'person' do

    entity!(:before) do
      localpool.update!(owner: person)
    end

    let(:path) { "/localpools/#{localpool.id}/person-owner" }

    it_behaves_like 'assign owner', first: :organization, second: :person
  end

end
