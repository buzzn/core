require_relative 'test_admin_localpool_roda'
require_relative 'shared_crud'

describe Admin::LocalpoolRoda, :request_helper do

  def app
    TestAdminLocalpoolRoda # this defines the active application for this test
  end

  entity!(:localpool) { create(:group, :localpool) }

  let(:path) { "/localpools/#{localpool.id}" }

  it_behaves_like 'delete', :localpool, path: :path

  it 'create' do
    POST '/localpools', $admin, address: {}

    expect(json).to eq("name"=>["is missing"],
                       "address"=> {
                         "street"=>["is missing"],
                         "zip"=>["is missing"],
                         "city"=>["is missing"],
                         "country"=>["is missing"]
                       })
  end
end
