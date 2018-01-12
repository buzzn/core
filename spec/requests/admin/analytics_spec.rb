require 'dry/container/stub'
require_relative 'test_admin_localpool_roda'

describe Admin::LocalpoolRoda do

  class MockDatasource4Aggregates
    def daily_charts(group)
      {
        value: Time.now.to_f
      }
    end

    def bubbles(group)
      [
        value: Time.now.to_f
      ]
    end

    # for the dry-container to mimic the item retrieval
    def call(*)
      self
    end
  end

  def app
    TestAdminLocalpoolRoda
  end

  def container
    registry = Import.global('services.datasource.registry')
    container = registry.instance_variable_get(:@container)
    container.enable_stubs!
    container
  end

  entity!(:localpool) { Fabricate(:localpool) }

  before do
    container.stub("discovergy", MockDatasource4Aggregates.new)
  end

  after do
    container.unstub("discovergy")
  end

  context 'GET' do

    context 'bubbles' do

      it '200' do
        GET "/test/#{localpool.id}/bubbles", $admin
        expect(response).to have_http_status(200)
        headers = response.headers
        expect(headers['ETag']).not_to be_nil
        expect(headers['Cache-Control']).to eq "private, max-age=15"
        expect(DateTime.parse(headers['Expires'])).to be > (DateTime.now + 14.seconds)
        expect(DateTime.parse(headers['Expires'])).to be < (DateTime.now + 16.seconds)

        first = json

        sleep(0.5)
        GET "/test/#{localpool.id}/bubbles", $admin
        expect(json).to eq first
      end
    end
  end
end
