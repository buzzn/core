require_relative 'test_admin_localpool_roda'
require_relative 'shared_crud'

describe Admin::LocalpoolRoda, :request_helper do

  def app
    TestAdminLocalpoolRoda # this defines the active application for this test
  end

  entity!(:localpool) { create(:group, :localpool) }
  entity!(:first_localpool) { create(:group, :localpool) }
  entity!(:person) { first_localpool.owner }
  entity(:organization) { create(:organization, :with_contact) }

  shared_examples 'assign owner' do |object:|

    let(:owner) { send(object) }

    it '200' do
      POST "#{path}/#{owner.id}", $admin

      expect(response).to have_http_status(201)
      expect(json['id']).to eq(owner.id)
      expect(localpool.reload.owner).to eq(owner)
    end

  end

  context 'organization' do

    entity!(:before) do
      first_localpool.update!(owner: organization)
    end

    let(:path) { "/localpools/#{localpool.id}/organization-owner" }

    it_behaves_like 'assign owner', object: :organization
  end

  context 'person' do

    entity!(:before) do
      first_localpool.update!(owner: person)
    end

    let(:path) { "/localpools/#{localpool.id}/person-owner" }

    it_behaves_like 'assign owner', object: :person
  end

end
