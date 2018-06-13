require_relative 'test_admin_localpool_roda'
require_relative 'resource_shared'

describe Admin::LocalpoolRoda, :request_helper do

  def app
    TestAdminLocalpoolRoda # this defines the active application for this test
  end

  entity!(:localpool) { create(:group, :localpool) }

  let(:path) { "/localpools/#{localpool.id}" }

  it_behaves_like 'delete', :localpool

end
