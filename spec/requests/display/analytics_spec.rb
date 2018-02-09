require 'dry/container/stub'

describe Display::GroupRoda do

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
    Display::GroupRoda # this defines the active application for this test
  end

  def container
    registry = Import.global('services.datasource.registry')
    container = registry.instance_variable_get(:@container)
    container.enable_stubs!
    container
  end

  entity!(:localpool) { Fabricate(:localpool, show_display_app: true) }

  before do
    container.stub('discovergy', MockDatasource4Aggregates.new)
  end

  after do
    container.unstub('discovergy')
  end

  context 'GET' do
    context 'charts' do

      it '200' do
        GET "/#{localpool.id}/charts", nil
        expect(response).to have_http_status(200)
        headers = response.headers
        expect(headers['ETag']).not_to be_nil
        expect(headers['Cache-Control']).to eq 'public, max-age=900'
        expect(DateTime.parse(headers['Expires'])).to be > (DateTime.now + 14.minutes)
        expect(DateTime.parse(headers['Expires'])).to be < (DateTime.now + 16.minutes)

        first = json

        sleep(0.5)
        GET "/#{localpool.id}/charts", nil
        expect(json).to eq first
      end
    end

    context 'bubbles' do

      it '200' do
        GET "/#{localpool.id}/bubbles", nil
        expect(response).to have_http_status(200)
        headers = response.headers
        expect(headers['ETag']).not_to be_nil
        expect(headers['Cache-Control']).to eq 'public, max-age=15'
        expect(DateTime.parse(headers['Expires'])).to be > (DateTime.now + 14.seconds)
        expect(DateTime.parse(headers['Expires'])).to be < (DateTime.now + 16.seconds)

        first = json

        sleep(0.5)
        GET "/#{localpool.id}/bubbles", nil
        expect(json).to eq first
      end
    end
  end
end
